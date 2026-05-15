#!/usr/bin/env bash
# Generate per-runtime MCP server config derivations from the
# canonical LLM-agnostic registry at 4-control/external/mcp/registry.json.
#
# Outputs:
#   - 4-control/external/mcp/codex.toml   (Codex [mcp_servers] table)
#   - 4-control/external/mcp/gemini.json  (Gemini mcpServers object)
#   (Claude consumes registry.json directly via the .mcp.json symlink.)
#
# After generation, the adopter merges each derivation into the
# runtime's native config:
#   Codex:  copy [mcp_servers.*] tables into .codex/config.toml
#   Gemini: merge "mcpServers" key into .gemini/settings.json
#
# Requires: jq (for JSON parsing).
#
# Usage:
#   ./3-playbook/act/script/mcp-sync.sh           Generate derivations
#   ./3-playbook/act/script/mcp-sync.sh --quiet   Suppress non-error output

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "${REPO_ROOT}"

QUIET=0
for arg in "$@"; do
  case "${arg}" in
    --quiet) QUIET=1 ;;
    --help|-h)
      sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "unknown arg: ${arg}" >&2; exit 1 ;;
  esac
done

log() { [[ "${QUIET}" -eq 1 ]] || echo "$@"; }

REGISTRY="4-control/external/mcp/registry.json"
CODEX_OUT="4-control/external/mcp/codex.toml"
GEMINI_OUT="4-control/external/mcp/gemini.json"

if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq not found in PATH (required for JSON parsing)" >&2
  exit 1
fi

if [[ ! -f "${REGISTRY}" ]]; then
  echo "error: registry not found at ${REGISTRY}" >&2
  exit 2
fi

# --- Codex TOML derivation ---
{
  echo "# Generated from ${REGISTRY} by mcp-sync.sh — do not edit by hand."
  echo "# Merge each [mcp_servers.<name>] table into .codex/config.toml."
  echo
  jq -r '.mcpServers | to_entries[] |
    "[mcp_servers.\(.key)]\n" +
    (if .value.command then "command = \"\(.value.command)\"\n" else "" end) +
    (if .value.args then "args = " + (.value.args | tojson) + "\n" else "" end) +
    (if .value.url then "url = \"\(.value.url)\"\n" else "" end) +
    (if .value.env then "env = " + (.value.env | tojson) + "\n" else "" end)
  ' "${REGISTRY}"
} > "${CODEX_OUT}"

log "wrote: ${CODEX_OUT}"

# --- Gemini JSON derivation ---
jq '{mcpServers: .mcpServers}' "${REGISTRY}" > "${GEMINI_OUT}"
log "wrote: ${GEMINI_OUT}"

# --- Claude is automatic via .mcp.json symlink to registry.json ---
log "claude:  uses registry.json directly via .mcp.json symlink (no derivation needed)"

log ""
log "Next steps:"
log "  - Codex:  copy [mcp_servers.*] tables from ${CODEX_OUT} into .codex/config.toml"
log "  - Gemini: merge mcpServers key from ${GEMINI_OUT} into .gemini/settings.json"
log ""
log "ok"
