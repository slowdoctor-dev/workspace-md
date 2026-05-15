#!/usr/bin/env bash
# Bootstrap Ollama as a local LLM backend for this workspace.
#
# Workspace convention: canonical Modelfile lives at
#   4-control/runtime/ollama/Modelfile
# Optional env overrides at
#   4-control/runtime/ollama/env
#
# Ollama itself does not auto-discover repo-level configs, so this
# script bridges the convention.
#
# Usage:
#   ./3-playbook/act/script/ollama-up.sh [model-name]
#
# Requires: `ollama` CLI installed. Source: https://ollama.com
#
# Exit codes:
#   0 — success
#   1 — missing dependency
#   2 — Modelfile not found
#   3 — model build failed

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
MODELFILE="${REPO_ROOT}/4-control/runtime/ollama/Modelfile"
ENV_FILE="${REPO_ROOT}/4-control/runtime/ollama/env"
MODEL_NAME="${1:-workspace-default}"

if ! command -v ollama >/dev/null 2>&1; then
  echo "error: ollama CLI not found in PATH. Install from https://ollama.com" >&2
  exit 1
fi

if [[ ! -f "${MODELFILE}" ]]; then
  echo "error: no Modelfile at ${MODELFILE}" >&2
  echo "hint: create one. See WORKSPACE.md and runtime-integration.md." >&2
  exit 2
fi

# Load env overrides (OLLAMA_HOST, OLLAMA_MODELS, OLLAMA_KEEP_ALIVE, etc.)
if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

# Ensure server is reachable.
if ! ollama list >/dev/null 2>&1; then
  echo "ollama server not reachable; starting via 'ollama serve' in background." >&2
  ollama serve >/tmp/ollama-serve.log 2>&1 &
  sleep 2
fi

# Build the model from canonical Modelfile.
echo "building model '${MODEL_NAME}' from ${MODELFILE}"
if ! ollama create "${MODEL_NAME}" -f "${MODELFILE}"; then
  echo "error: ollama create failed" >&2
  exit 3
fi

echo "ready: ollama run ${MODEL_NAME}"
echo "       OpenAI-compat: http://${OLLAMA_HOST:-localhost:11434}/v1"
echo "       Anthropic-compat (Claude Code): http://${OLLAMA_HOST:-localhost:11434}"
