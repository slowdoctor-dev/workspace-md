#!/usr/bin/env bash
# Optional helper for the detect-runtime skill (objective checks only).
#
# Emits JSON on stdout:
#   {
#     "harness":              "<claude-code|codex-cli|antigravity|gemini-cli|cursor|hermes|opencode|continue|custom>",
#     "backend_provider":     "<anthropic|openai|google|ollama|lm-studio|mlx|llama-cpp|vllm|custom>",
#     "backend_endpoint":     "<URL>",
#     "backend_model":        "<model id>",
#     "model_class":          "<hosted-frontier|hosted-small|local-large|local-small|uncertain>",
#     "effective_context":    <integer tokens, 0 = unknown>,
#     "recommended_tier":     "<lean|standard|extended>",
#     "signal_disagreements": [<strings>]
#   }
#
# It cannot perform agent self-introspection (SKILL.md Step 0); the
# running agent supplies that primary signal and reconciles. One
# reference implementation — adopters may replace it or run the skill
# procedure manually. Requirements: bash + jq; curl optional.

set -eu

profile_path="3-control/runtime/profile.md"
profile_value() { [ -f "$profile_path" ] && sed -n "s/^\*\*$1\*\*: //p" "$profile_path" | head -n 1 || true; }
profile_tier="$(profile_value active_tier)"

signals="[]"
add_signal() { signals="$(printf '%s' "$signals" | jq -c --arg m "$1" '. + [$m]')"; }

# --- Sub-step 1: harness ---
agy="false"
if env | grep -q '^AGY_' || command -v agy >/dev/null 2>&1 || [ -d "${HOME}/.config/agy" ]; then agy="true"; fi
gemini="false"
if [ -n "${GEMINI_PROJECT_DIR:-}" ] || [ -d ".gemini" ]; then gemini="true"; fi
[ "$agy" = "true" ] && [ "$gemini" = "true" ] && add_signal "WARNING: gemini-cli and antigravity signals both present; see 3-control/runtime/antigravity-cli.md"

harness="custom"
if   [ -n "${CLAUDE_PROJECT_DIR:-}" ] || [ -d ".claude" ]; then harness="claude-code"
elif [ -n "${CODEX_PROJECT_DIR:-}" ] || [ -f ".codex/config.toml" ]; then harness="codex-cli"
elif [ "$agy" = "true" ]; then harness="antigravity"
elif [ "$gemini" = "true" ]; then harness="gemini-cli"
elif [ -d ".cursor" ]; then harness="cursor"
elif [ -f "${HOME}/.hermes/config.yaml" ]; then harness="hermes"
elif [ -f ".config/opencode/opencode.json" ]; then harness="opencode"
elif [ -f ".continue/config.yaml" ]; then harness="continue"
fi

# --- Sub-step 2: backend ---
provider="custom"; endpoint=""; model=""; ctx=0
probe() {  # $1 = URL of /models; sets endpoint/model on success
  local r
  r=$(curl -s -m 2 "$1" 2>/dev/null) || return 1
  printf '%s' "$r" | jq -e '.data' >/dev/null 2>&1 || return 1
  endpoint="$1"; model=$(printf '%s' "$r" | jq -r '.data[0].id // empty')
  ctx=$(printf '%s' "$r" | jq -r --arg m "$model" '.data[] | select(.id==$m) | (.context_length // .max_model_len // .n_ctx // 0)' 2>/dev/null || echo 0)
  return 0
}
base="${OPENAI_BASE_URL:-${ANTHROPIC_BASE_URL:-}}"
if [ -n "$base" ] && probe "${base%/}/models"; then provider="custom"; fi
if [ -z "$endpoint" ]; then
  for p in 11434:ollama 1234:lm-studio 8080:llama-cpp 8000:vllm; do
    if probe "http://localhost:${p%%:*}/v1/models"; then provider="${p#*:}"; break; fi
  done
fi
if [ -z "$endpoint" ]; then
  case "$harness" in
    claude-code) provider="anthropic"; endpoint="https://api.anthropic.com" ;;
    codex-cli)   provider="openai";    endpoint="https://api.openai.com" ;;
    antigravity|gemini-cli) provider="google"; endpoint="https://generativelanguage.googleapis.com" ;;
  esac
fi
[ "$ctx" -gt 0 ] 2>/dev/null || ctx=0

# --- Sub-step 3: model class (heuristic; agent reconciles) ---
class="uncertain"
m="$(printf '%s' "$model" | tr '[:upper:]' '[:lower:]')"
case "$provider" in
  anthropic|openai|google)
    case "$m" in
      "") class="uncertain" ;;
      *haiku*|*mini*|*nano*|*flash*|*lite*) class="hosted-small" ;;
      *) class="hosted-frontier" ;;
    esac ;;
  *)
    params=$(printf '%s' "$m" | grep -oE '[0-9]+(\.[0-9]+)?b' | head -n1 | tr -d b)
    if [ -n "$params" ]; then
      if   awk "BEGIN{exit !($params>=30)}"; then class="local-large"
      elif awk "BEGIN{exit !($params<=13)}"; then class="local-small"
      else add_signal "mid-size local model (${params}B): Owner decides local-large vs local-small"; fi
    elif [ -n "$model" ]; then add_signal "could not parse parameter count from model id '$model'"; fi ;;
esac
[ -z "$model" ] && add_signal "detection uncertain: no model id; profile.md tier applies when present"

# --- Sub-step 4: tier ---
case "$class" in
  hosted-frontier) tier="extended" ;;
  local-small)     tier="lean" ;;
  hosted-small|local-large) tier="standard" ;;
  *) case "$profile_tier" in lean|standard|extended) tier="$profile_tier" ;; *) tier="standard" ;; esac ;;
esac
if [ "$ctx" -gt 0 ] && [ "$ctx" -le 16384 ]; then
  tier="lean"; add_signal "effective_context ${ctx} ≤16K: local window likely misconfigured (Ollama default); lean forced"
fi

jq -n --arg h "$harness" --arg p "$provider" --arg e "$endpoint" --arg m "$model" \
      --arg c "$class" --argjson x "$ctx" --arg t "$tier" --argjson s "$signals" \
  '{harness:$h, backend_provider:$p, backend_endpoint:$e, backend_model:$m,
    model_class:$c, effective_context:$x, recommended_tier:$t, signal_disagreements:$s}'
