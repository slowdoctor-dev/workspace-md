---
name: session-start
description: Run at the beginning of every working session in a workspace.md workspace. Reports current state (recent changes, dirty files, stale ephemerals), brings any local LLM backend up if needed, and briefs the user on direction.
---

# Session — regular start

## When to use

At the beginning of every working session. Not the first-time init
(use `session-init` for that).

## Steps

### 1. Lightweight integrity check

    ./3-playbook/act/script/check-workspace.sh --quick

If errors, escalate to full `session-init` flow.

### 2. Report recent activity

Show what happened since last session:

    git log --since="7 days ago" --oneline
    git status --short

If there are uncommitted changes, surface them and ask:

- "These are from last session — commit, stash, or discard?"

### 3. Check ephemeral content

`1-active/` is the disposable working area. After a few sessions it
accumulates drafts and `_trash/`. Surface anything older than 7 days:

    find 1-active/ -type f -mtime +7 2>/dev/null | head -20

Ask the user whether to keep, archive (graduate to `2-mind/`), or
discard.

### 4. Local LLM backend (if used)

If this workspace uses a local LLM, verify the backend is reachable:

- Ollama: `ollama list` (running?) — if not, run
  `./3-playbook/act/script/ollama-up.sh <model>`.
- LM Studio: `lms server status` — if not running, run
  `./3-playbook/act/script/lmstudio-up.sh <model>`.

### 5. Read NEXT / TODO / session-log

If the workspace has a `NEXT.md`, `TODO.md`, or
`2-mind/factory/session-log.md`, read the latest entries and brief the
user.

### 6. Confirm direction

Ask: "What do we work on this session?" — confirm before starting work.

## Done criteria

- Workspace integrity verified
- Uncommitted state addressed (committed / stashed / acknowledged)
- Stale ephemerals addressed
- Backend reachable (if used)
- Session direction agreed
