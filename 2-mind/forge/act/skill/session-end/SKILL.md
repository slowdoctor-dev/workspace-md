---
name: session-end
description: Close a session — summarize changes, suggest commits, write a journal entry (episodic trace), write fresh NEXT.md (handoff). Chains to learn for substantive sessions.
---

# session-end

## When to use

Before disconnecting (end of work block, switching workspaces, etc.).
Every session ends with a journal entry — the episodic trace per R3.

## Quick reference

| Step | Reads | Writes |
|---|---|---|
| 1. Summarize | git diff/log + session transcript | — |
| 2. Suggest commits | (per workspace convention) | Owner-accepted commits |
| 3. Write journal entry | session transcript, decisions | `garden/essential/journal/<YYYY-MM-DD>-<runtime>-<NNN>.md` |
| 4. Write fresh NEXT.md | outstanding work + open items | `garden/essential/NEXT.md` |
| 5. Chain to learn (optional) | (handoff) | — |

## Procedure

### 1. Summarize what changed

```
git diff --stat
git log --since="<session-start-time>" --oneline
git status --short
```

Show the Owner a digest: "This session added X, modified Y, did Z."

### 2. Suggest commits

For each meaningful uncommitted work unit, propose a commit message
in the workspace's convention (`YYYY-MM-DD <short English summary>`
default). Wait for Owner confirm before committing.

### 3. Write journal entry

Path: `2-mind/garden/essential/journal/<YYYY-MM-DD>-<runtime>-<NNN>.md`
- `YYYY-MM-DD` = today
- `<runtime>` = `claude` / `codex` / `gemini` / `cron` / etc.
- `<NNN>` = zero-padded ordinal within day-runtime combo (`001`,
  `002`, etc. — check existing entries today to determine)

Use the structure in `garden/essential/journal/ENTRY-TEMPLATE.md`:
- Header (Started / Closed / Runtime / Working dir)
- Summary (2-3 sentences)
- Decisions (architecture / naming / design choices)
- Learnings (new insights / surprising findings / corrections)
- Procedural changes (new skills / scripts / rules)
- Open / NEXT (transfer to fresh NEXT.md too)
- Owner-signals (Owner preferences observed; for `learn` to graduate)
- Consolidations applied (left empty; filled by `learn` if it runs)

### 4. Write fresh NEXT.md

Replace any content in `garden/essential/NEXT.md` (which should
already be cleared by session-start of this session) with fresh
content based on the Open / NEXT items from the journal entry:
- Outstanding (in-progress, paused mid-task)
- Open questions (decisions deferred for Owner)
- Next-session priorities (what to tackle first)

### 5. Chain to learn (substantive sessions)

If the session was substantive (multiple decisions / non-trivial work
/ ≥5 tool calls / error recovery / Owner correction / novel workflow),
invoke `/learn` — consolidates journal signals into T1 stores and
proposes T2 graduations for Owner ratification.

For trivial sessions (single quick fix), skip `learn`; the journal
entry alone suffices as episodic trace.

## Pitfalls

- **Committing without Owner accept**: always wait for explicit
  accept, even under fast workspace conventions.
- **Skipping the journal entry**: every session writes one — the
  episodic trace per R3 is non-negotiable.
- **Wrong filename format**: `YYYY-MM-DD-<runtime>-<NNN>.md`; NNN
  increments within today's runtime-matched entries.
- **Auto-running learn on trivial sessions**: produces thin USER.md
  entries. Only chain when substantive.
- **Not transferring Open / NEXT to fresh NEXT.md**: loses handoff
  context for the next session.

## Verification

- `git status` reflects only Owner-accepted commits
- New journal entry exists at correct path with all sections filled
- `garden/essential/NEXT.md` has fresh content matching Open / NEXT
  in the journal entry
- For substantive sessions: `learn` has run (check
  "Consolidations applied" footer of journal entry)
