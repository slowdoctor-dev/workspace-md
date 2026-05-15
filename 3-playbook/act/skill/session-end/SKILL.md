---
name: session-end
description: Run before disconnecting from a workspace.md workspace. Summarizes session changes, suggests commit messages, updates the session log, prunes ephemerals, and optionally stops local LLM backends.
---

# Session — close

## When to use

Before disconnecting from the workspace (end of work day, switching
between workspaces, etc.).

## Steps

### 1. Summarize what changed this session

    git diff --stat
    git log --since="<session-start-time>" --oneline
    git status --short

Show the user a digest: "This session added X, modified Y, did Z."

### 2. Suggest commits

For each meaningful unit of uncommitted work, propose a commit message
in the workspace's convention. The default suggested form (per
workspace.md `4-control/rule/contribution.md`):

    YYYY-MM-DD <short English summary>

Offer to commit; only commit after the user confirms.

### 3. Update session log

If the workspace has a session log (commonly
`2-mind/factory/session-log.md`), append a brief entry:

    ## YYYY-MM-DD HH:MM session
    - what was done: <bullets>
    - what's next:   <bullets>
    - state at close: <branch>, <dirty?>

If no session log exists, ask the user whether to create one — it's a
useful long-term habit for workspace.md workspaces.

### 4. Prune ephemerals

`1-active/_trash/` accumulates date-folded ephemerals. Surface
anything older than 30 days and ask whether to delete:

    find 1-active/_trash/ -type d -mtime +30 2>/dev/null | head -20

### 5. Stop local LLM backends (if started by this session)

If Ollama or LM Studio was started during this session and is no
longer needed:

    # Ollama
    pkill -f 'ollama serve' 2>/dev/null || true
    # LM Studio
    lms server stop 2>/dev/null || true

(Skip if the user keeps backends always-on.)

### 6. Final integrity check

    ./3-playbook/act/script/check-workspace.sh --quick

Should exit 0 before the session is considered closed cleanly.

### 7. Report session summary

Give the user a brief: "Session closed. Committed N changes. Session
log updated. State at close: <branch> clean."

## Done criteria

- All meaningful changes are either committed or explicitly acknowledged
  as work-in-progress
- Session log entry appended (or user has declined)
- Ephemerals reviewed for pruning
- Backends quiesced if appropriate
- Workspace integrity verified (`check-workspace.sh --quick` passes)
