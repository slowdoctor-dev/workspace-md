---
name: session-init
description: First-time setup of a workspace.md workspace after cloning. Verifies structure, detects installed LLM runtimes, repairs broken canonical symlinks, briefs the user on the reading order. Run once after `git clone`.
---

# Session — first-time init

## When to use

Run once immediately after cloning a workspace.md-compliant workspace,
or after any major filesystem reorganization (e.g., moving the repo
between machines, restoring from backup).

## Steps

### 1. Verify structure

    ./3-playbook/act/script/check-workspace.sh

If anything fails or warns:

- Folders missing → restore from spec (`git checkout HEAD -- <path>`)
  or re-clone.
- Symlinks broken (common on Windows native or after file copies that
  did not preserve symlinks) → run `--repair`:

      ./3-playbook/act/script/check-workspace.sh --repair

### 2. Detect installed LLM runtimes

For each of `claude`, `codex`, `gemini`, `ollama`, `lms`, `mlx_lm`,
check with `command -v <name>` whether it's in PATH. Report:

    detected:    <list>
    missing:     <list> — install separately if desired

### 3. Verify each detected runtime can read workspace configs

| Runtime | Verification command | Expected |
|---|---|---|
| Claude Code | `claude --version` then `/memory` inside Claude | shows `CLAUDE.md` and `.claude/settings.json` loaded |
| Codex CLI | `codex status` | shows trust state + active config layers (project may need to be marked trusted on first run) |
| Gemini CLI | `gemini --version` then `/memory` inside Gemini | shows `GEMINI.md` and `.gemini/settings.json` loaded |
| Ollama | `ollama list` | server reachable; or run `./3-playbook/act/script/ollama-up.sh` |
| LM Studio | `lms server status` | server state; or run `./3-playbook/act/script/lmstudio-up.sh` |

### 4. Brief the user on the reading order

Point the user at:

1. `README.md` — orientation
2. `WORKSPACE.md` — the spec
3. `4-control/principle/principle.md` — operating principles
4. `4-control/principle/runtime-integration.md` — runtime specifics
5. `2-mind/factory/getting-started.md` — adoption walkthrough

### 5. Note any local-LLM bootstrap that's still needed

If Ollama or LM Studio is detected but no model/preset is configured at
the workspace canonical location (`4-control/runtime/ollama/Modelfile`,
`4-control/runtime/lmstudio/presets/*`), suggest the user write one
before invoking `ollama-up.sh` / `lmstudio-up.sh`.

## Done criteria

- `check-workspace.sh` exits 0
- User has been told which runtimes are connected and which are not
- Reading-order list has been delivered
- User has acknowledged readiness to proceed
