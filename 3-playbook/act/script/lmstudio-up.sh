#!/usr/bin/env bash
# Bootstrap LM Studio as a local LLM backend for this workspace.
#
# Workspace convention:
#   - Canonical presets at 4-control/runtime/lmstudio/presets/*.json
#   - Canonical MCP config at 4-control/runtime/lmstudio/mcp.json
#
# LM Studio does not auto-discover repo-level configs; this script
# bridges by starting the server, optionally loading a configured
# model, and applying a preset.
#
# Usage:
#   ./3-playbook/act/script/lmstudio-up.sh [model-identifier] [port]
#
# Requires: `lms` CLI installed (ships with LM Studio).
# Source: https://lmstudio.ai
#
# Exit codes:
#   0 — server up
#   1 — missing dependency
#   2 — server failed to start
#   3 — model load failed

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
LMSTUDIO_DIR="${REPO_ROOT}/4-control/runtime/lmstudio"
MODEL="${1:-}"
PORT="${2:-1234}"

if ! command -v lms >/dev/null 2>&1; then
  echo "error: lms CLI not found in PATH." >&2
  echo "  Install LM Studio (https://lmstudio.ai) and launch it once" >&2
  echo "  to register the CLI." >&2
  exit 1
fi

# Start server if not already running.
if lms server status --quiet 2>/dev/null; then
  echo "lms server already running on port ${PORT}"
else
  echo "starting lms server on port ${PORT} (CORS enabled)"
  if ! lms server start --port "${PORT}" --cors; then
    echo "error: lms server start failed" >&2
    exit 2
  fi
fi

# Optionally load a model.
if [[ -n "${MODEL}" ]]; then
  echo "loading model: ${MODEL}"
  if ! lms load "${MODEL}"; then
    echo "error: lms load failed for ${MODEL}" >&2
    exit 3
  fi
fi

# Inform about workspace-level presets / MCP if present.
if [[ -d "${LMSTUDIO_DIR}/presets" ]]; then
  echo "workspace presets available at: ${LMSTUDIO_DIR}/presets/"
fi
if [[ -f "${LMSTUDIO_DIR}/mcp.json" ]]; then
  echo "workspace MCP config: ${LMSTUDIO_DIR}/mcp.json"
  echo "  apply via LM Studio: Program tab → Install → Edit mcp.json"
fi

echo "ready:"
echo "  OpenAI-compat:        http://localhost:${PORT}/v1"
echo "  Anthropic-compat:     http://localhost:${PORT}  (Claude Code: ANTHROPIC_BASE_URL=http://localhost:${PORT}, ANTHROPIC_AUTH_TOKEN=lmstudio)"
echo "  Native LM Studio API: http://localhost:${PORT}/api/v1"
