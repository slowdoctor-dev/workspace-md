#!/usr/bin/env bash
# Count tokens for workspace memory-cap enforcement.
#
# Reads backend hints from 3-control/runtime/profile.md, then tries the
# best available tokenizer:
# - Anthropic Messages count_tokens API
# - Gemini countTokens API
# - local /api/tokenize endpoint
# - tiktoken fallback (o200k_base for newer OpenAI models, else cl100k_base)
# - last-resort rough estimate if tiktoken is not installed
#
# The rough estimate is non-canonical/advisory only. Install tiktoken or
# use a provider/local tokenizer for cap-enforcement decisions.
#
# Usage:
#   token-count.sh [file ...]
#   printf '%s' "text" | token-count.sh

set -eu

profile_path="${WORKSPACE_PROFILE:-3-control/runtime/profile.md}"

profile_value() {
  field="$1"
  if [ -f "$profile_path" ]; then
    sed -n "s/^\*\*${field}\*\*: //p" "$profile_path" | head -n 1
  fi
}

backend_provider="$(profile_value "backend_provider" || true)"
backend_endpoint="$(profile_value "backend_endpoint" || true)"
backend_model="$(profile_value "backend_model" || true)"

read_input() {
  if [ "$#" -gt 0 ]; then
    for path in "$@"; do
      [ -f "$path" ] && sed -n '1,$p' "$path"
      [ "$#" -gt 1 ] && printf '\n'
    done
    return 0
  else
    cat
  fi
}

json_string() {
  jq -Rs .
}

count_with_anthropic() {
  [ -n "${ANTHROPIC_API_KEY:-}" ] || return 1
  [ -n "$backend_model" ] || return 1
  [ -n "$text" ] || return 1

  body=$(printf '%s' "$text" | jq -Rs --arg model "$backend_model" '{
    model: $model,
    messages: [{role: "user", content: .}]
  }')

  response=$(curl -sS -m 8 \
    -H "x-api-key: ${ANTHROPIC_API_KEY}" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d "$body" \
    "https://api.anthropic.com/v1/messages/count_tokens" 2>/dev/null) || return 1

  printf '%s' "$response" | jq -er '.input_tokens'
}

count_with_gemini() {
  api_key="${GEMINI_API_KEY:-${GOOGLE_API_KEY:-}}"
  [ -n "$api_key" ] || return 1
  [ -n "$backend_model" ] || return 1
  [ -n "$text" ] || return 1

  model="${backend_model#models/}"
  body=$(printf '%s' "$text" | jq -Rs '{contents: [{parts: [{text: .}]}]}')
  response=$(curl -sS -m 8 \
    -H "content-type: application/json" \
    -d "$body" \
    "https://generativelanguage.googleapis.com/v1beta/models/${model}:countTokens?key=${api_key}" 2>/dev/null) || return 1

  printf '%s' "$response" | jq -er '.totalTokens'
}

count_with_local_api() {
  [ -n "$backend_endpoint" ] || return 1
  [ -n "$text" ] || return 1

  base="$backend_endpoint"
  base="${base%/v1/models}"
  base="${base%/models}"
  base="${base%/v1}"
  base="${base%/}"

  body=$(printf '%s' "$text" | jq -Rs --arg model "$backend_model" '{
    model: $model,
    prompt: .
  }')

  response=$(curl -sS -m 8 \
    -H "content-type: application/json" \
    -d "$body" \
    "${base}/api/tokenize" 2>/dev/null) || return 1

  printf '%s' "$response" | jq -er '
    if .tokens then (.tokens | length)
    elif .token_count then .token_count
    elif .count then .count
    else empty
    end'
}

count_with_tiktoken() {
  printf '%s' "$text" | TOKEN_COUNT_MODEL="$backend_model" python3 -c '
import os
import sys

text = sys.stdin.read()
model = (os.environ.get("TOKEN_COUNT_MODEL") or "").lower()
encoding_name = "o200k_base" if any(x in model for x in ("gpt-4o", "gpt-5", "o1", "o3", "o4")) else "cl100k_base"

try:
    import tiktoken
except Exception as exc:
    sys.stderr.write("token-count.sh: tiktoken fallback unavailable: %s\n" % exc)
    sys.exit(1)

encoding = tiktoken.get_encoding(encoding_name)
print(len(encoding.encode(text)))
'
}

count_with_rough_estimate() {
  printf '%s' "$text" | python3 -c '
import re
import sys

text = sys.stdin.read()
words = re.findall(r"\w+|[^\w\s]", text, flags=re.UNICODE)
print(max(1, int(len(words) * 1.33)) if text else 0)
'
}

text="$(read_input "$@")"

case "$backend_provider" in
  anthropic)
    count_with_anthropic && exit 0
    ;;
  google)
    count_with_gemini && exit 0
    ;;
  ollama|lm-studio|mlx|llama-cpp|vllm|custom)
    count_with_local_api && exit 0
    ;;
esac

if count_with_tiktoken; then
  exit 0
fi

printf '%s\n' "token-count.sh: WARNING: using rough estimate; install tiktoken for canonical fallback" >&2
count_with_rough_estimate
