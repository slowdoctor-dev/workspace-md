#!/usr/bin/env bash
# Verify workspace.md structure integrity — folders, symlinks, secrets.
#
# Usage:
#   check-workspace.sh             Full verification (verbose)
#   check-workspace.sh --quick     Quick check (folder presence only)
#   check-workspace.sh --repair    Recreate broken/missing canonical symlinks
#   check-workspace.sh --quiet     Suppress non-error output

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "${REPO_ROOT}"

QUICK=0
REPAIR=0
QUIET=0
for arg in "$@"; do
  case "${arg}" in
    --quick)  QUICK=1 ;;
    --repair) REPAIR=1 ;;
    --quiet)  QUIET=1 ;;
    --help|-h)
      sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "unknown arg: ${arg}" >&2; exit 1 ;;
  esac
done

errors=0
warnings=0

log()  { [[ "${QUIET}" -eq 1 ]] || echo "$@"; }
ok()   { log "ok:   $*"; }
warn() { log "warn: $*"; warnings=$((warnings+1)); }
fail() { echo "fail: $*" >&2; errors=$((errors+1)); }

# Top-level folders (the 5-layer topology)
for d in 0-storage 1-active 2-mind 3-playbook 4-control; do
  [[ -d "${d}" ]] && ok "folder ${d}/" || fail "missing folder ${d}/"
done

if [[ "${QUICK}" -eq 1 ]]; then
  [[ "${errors}" -eq 0 ]] && log "workspace ok" || echo "workspace has ${errors} error(s)"
  exit "${errors}"
fi

# 2-mind subfolders (fixed taxonomy)
for d in 2-mind/atelier 2-mind/factory; do
  [[ -d "${d}" ]] && ok "folder ${d}/" || fail "missing ${d}/"
done

# 3-playbook subfolders (fixed taxonomy; act/rule optional per spec)
for d in 3-playbook/role 3-playbook/cue 3-playbook/act/skill 3-playbook/act/script; do
  [[ -d "${d}" ]] && ok "folder ${d}/" || fail "missing ${d}/"
done

# 4-control subfolders (fixed taxonomy)
for d in 4-control/principle 4-control/rule 4-control/runtime 4-control/external; do
  [[ -d "${d}" ]] && ok "folder ${d}/" || fail "missing ${d}/"
done

# Canonical symlinks
check_symlink() {
  local link="$1" expected_target="$2"
  if [[ -L "${link}" ]]; then
    local actual
    actual="$(readlink "${link}")"
    if [[ "${actual}" == "${expected_target}" ]]; then
      ok "symlink ${link} -> ${actual}"
    else
      warn "symlink ${link} -> ${actual} (expected ${expected_target})"
    fi
  elif [[ -e "${link}" ]]; then
    warn "${link} exists but is not a symlink (expected symlink to ${expected_target})"
  else
    warn "${link} missing (expected symlink to ${expected_target})"
    if [[ "${REPAIR}" -eq 1 ]]; then
      ln -s "${expected_target}" "${link}"
      ok "repaired: ${link} -> ${expected_target}"
    fi
  fi
}

check_symlink "CLAUDE.md" "AGENTS.md"
check_symlink "GEMINI.md" "AGENTS.md"
check_symlink ".mcp.json" "4-control/external/mcp/registry.json"

# Required files
for f in WORKSPACE.md AGENTS.md README.md LICENSE; do
  [[ -f "${f}" ]] && ok "file ${f}" || fail "missing ${f}"
done

# Secret leak check (tracked files only)
if git rev-parse --git-dir >/dev/null 2>&1; then
  if git ls-files -z 2>/dev/null | xargs -0 grep -lE '(AKIA[0-9A-Z]{16}|sk-[a-zA-Z0-9]{32,})' 2>/dev/null | head -1 | grep -q .; then
    fail "potential secret pattern found in tracked files — review immediately"
  else
    ok "no obvious secrets in tracked files"
  fi
fi

if [[ "${errors}" -eq 0 ]]; then
  log "workspace ok${warnings:+ (${warnings} warning(s))}"
  exit 0
else
  echo "workspace has ${errors} error(s)${warnings:+ + ${warnings} warning(s)}" >&2
  exit "${errors}"
fi
