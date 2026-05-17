#!/usr/bin/env bash
# Optional helper for the detect-runtime skill.
#
# Emits a JSON object on stdout:
#   {
#     "harness":              "<claude-code|codex-cli|gemini-cli|cursor|hermes|opencode|continue|custom>",
#     "backend_provider":     "<anthropic|openai|google|ollama|lm-studio|mlx|llama-cpp|vllm|custom>",
#     "backend_endpoint":     "<URL>",
#     "backend_model":        "<model id>",
#     "effective_context":    <integer tokens>,
#     "recommended_tier":     "<lean|standard|extended>",
#     "signal_disagreements": [<list of strings, may be empty>]
#   }
#
# This is one reference implementation. The skill at
# 2-mind/forge/act/skill/detect-runtime/SKILL.md describes the
# procedure; adopters may use this script, replace it, or execute
# the procedure manually.
#
# Requirements: bash, curl, jq. Falls back gracefully if a tool is
# missing.

set -eu

# --- Sub-step 1: Detect harness ---
harness="custom"
if [ -n "${CLAUDE_PROJECT_DIR:-}" ] || [ -d ".claude" ]; then
  harness="claude-code"
elif [ -n "${CODEX_PROJECT_DIR:-}" ] || [ -f ".codex/config.toml" ]; then
  harness="codex-cli"
elif [ -n "${GEMINI_PROJECT_DIR:-}" ] || [ -d ".gemini" ]; then
  harness="gemini-cli"
elif [ -d ".cursor" ]; then
  harness="cursor"
elif [ -f "${HOME}/.hermes/config.yaml" ]; then
  harness="hermes"
elif [ -f ".config/opencode/opencode.json" ]; then
  harness="opencode"
elif [ -f ".continue/config.yaml" ]; then
  harness="continue"
fi

# --- Sub-step 2: Detect backend ---
backend_provider="custom"
backend_endpoint=""
backend_model=""

# Local-port probe (covers most local-LLM cases regardless of harness)
for port in 11434 1234 8080 8000; do
  url="http://localhost:${port}/v1/models"
  if response=$(curl -s -m 2 "$url" 2>/dev/null) && [ -n "$response" ]; then
    if echo "$response" | jq -e '.data' >/dev/null 2>&1; then
      backend_endpoint="$url"
      case "$port" in
        11434) backend_provider="ollama" ;;
        1234)  backend_provider="lm-studio" ;;
        8080)  backend_provider="llama-cpp" ;;
        8000)  backend_provider="vllm" ;;
      esac
      backend_model=$(echo "$response" | jq -r '.data[0].id // empty')
      break
    fi
  fi
done

# Hosted detection if no local backend found
if [ -z "$backend_endpoint" ]; then
  case "$harness" in
    claude-code) backend_provider="anthropic"; backend_endpoint="https://api.anthropic.com" ;;
    codex-cli)   backend_provider="openai";    backend_endpoint="https://api.openai.com" ;;
    gemini-cli)  backend_provider="google";    backend_endpoint="https://generativelanguage.googleapis.com" ;;
  esac
fi

# --- Sub-step 3: Determine effective_context ---
effective_context=0
case "$backend_provider" in
  anthropic) effective_context=200000 ;;
  openai)    effective_context=128000 ;;
  google)    effective_context=1000000 ;;
  ollama|lm-studio|llama-cpp|vllm)
    if [ -n "$backend_endpoint" ] && [ -n "$backend_model" ]; then
      # Try common context fields in /v1/models response
      models_response=$(curl -s -m 2 "$backend_endpoint" 2>/dev/null || echo "{}")
      effective_context=$(echo "$models_response" \
        | jq -r --arg m "$backend_model" \
            '.data[] | select(.id==$m) | (.context_length // .max_model_len // .n_ctx // 0)' \
        2>/dev/null || echo 0)
    fi
    # Clamp to attention-quality cliff per heuristic (defensive default for local)
    if [ "$effective_context" -eq 0 ] || [ "$effective_context" -gt 16384 ]; then
      # Without explicit knowledge of model size, default to lean-safe
      effective_context=16384
    fi
    ;;
esac

# --- Sub-step 4: Derive tier ---
recommended_tier="standard"
if [ "$effective_context" -le 16384 ]; then
  recommended_tier="lean"
elif [ "$effective_context" -le 65536 ]; then
  recommended_tier="standard"
else
  # > 64K — hosted-large gets extended; hosted-modest stays standard
  case "$backend_model" in
    *sonnet*|*opus*|*gpt-4*|*gemini-pro*|*gemini-flash*) recommended_tier="extended" ;;
    *haiku*|*gpt-4o-mini*) recommended_tier="standard" ;;
    *) recommended_tier="standard" ;;
  esac
fi

# --- Emit JSON ---
jq -n \
  --arg harness "$harness" \
  --arg bp "$backend_provider" \
  --arg be "$backend_endpoint" \
  --arg bm "$backend_model" \
  --argjson ec "$effective_context" \
  --arg rt "$recommended_tier" \
  '{
    harness: $harness,
    backend_provider: $bp,
    backend_endpoint: $be,
    backend_model: $bm,
    effective_context: $ec,
    recommended_tier: $rt,
    signal_disagreements: []
  }'
