---
name: session-end
description: Close a session — summarize changes, suggest commits, write a journal entry (episodic trace), append a NEXT.md handoff block. Chains to `dream` for substantive sessions. Also writes the PreCompact checkpoint block when invoked by that cue.
---

# session-end

## When to use

- Before disconnecting (end of work block, switching workspaces).
- **Checkpoint mode** — invoked by the `context.precompact` cue
  (`2-mind/forge/cue/lifecycle.md`): write only the `NEXT.md`
  *Outstanding* block, no journal.

Every session ends with a journal entry — the episodic trace per R3.

## Requires

Requires `3-control/foundation/SOUL.md`,
`3-control/foundation/PRINCIPLE.md`, and `2-mind/garden/essential/`
to exist. If any are missing, run `init` instead of continuing.

## Quick reference

| Step | Reads | Writes |
|---|---|---|
| 1. Summarize | git diff/log + session transcript | — |
| 2. Suggest commits | workspace convention | Owner-accepted commits |
| 3. Write journal entry | transcript, decisions | `garden/essential/journal/<YYYY-MM-DD>-<runtime>-<sid>.md` |
| 4. Append NEXT.md block | outstanding work + open items | `garden/essential/NEXT.md` (append-only) |
| 5. Chain to `dream` (substantive sessions) | handoff | — |

Checkpoint mode runs step 4 only (*Outstanding* section).

## Procedure

### 1. Summarize what changed

```
git diff --stat
git log --since="<session-start-time>" --oneline
git status --short
```

Show the Owner a digest: "This session added X, modified Y, did Z."

### 2. Suggest commits

Propose a commit message per meaningful unit in the workspace's
convention (`YYYY-MM-DD <short English summary>` default). Wait for
Owner confirm. **In a worktree / feature branch** (R5): commit journal
+ `NEXT.md` separately from code, message prefixed `memory:`, so the
Owner can merge memory first. Headless runs commit without asking and
open a PR (T2 by merge).

### 3. Write journal entry

Path: `2-mind/garden/essential/journal/<YYYY-MM-DD>-<runtime>-<sid>.md`
- `YYYY-MM-DD` = today
- `<runtime>` = slug from the registry below
- `<sid>` = session id: first 6 chars of the harness session id if
  exposed, else `HHMMSS` of session start. Strictly sequential
  single-session workspaces may keep the legacy `NNN` ordinal
  (`001`, `002`, …) — pick one scheme per workspace and record it in
  `ENTRY-TEMPLATE.md`'s comment.

Fill the structure from `garden/essential/journal/ENTRY-TEMPLATE.md`.
*Open / NEXT* items also go into the `NEXT.md` block (step 4);
*Consolidations applied* stays empty until `dream` runs (step 5).

#### Runtime slug registry

| Slug | Runtime |
|---|---|
| `claude` | Claude Code (terminal, desktop) |
| `codex` | Codex CLI |
| `antigravity` | Antigravity CLI (`agy`) |
| `cursor` | Cursor |
| `cloud` | remote interactive session (Claude Code on the web, Codex cloud) |
| `cron` | headless scheduled run |
| `ci` | CI / pipeline run |
| `gemini` | Gemini CLI — *legacy* (retired 2026-06-18 outside Enterprise) |
| `other` | any runtime not yet registered |

Add a lowercase ASCII slug when a runtime recurs and `other` stops
being informative.

### 4. Append the NEXT.md handoff block

`NEXT.md` is **append-only** (R5). Never rewrite or merge other
blocks. Append:

```
### <runtime>/<sid> @ <YYYY-MM-DDTHH:MM>
**Outstanding**: …           (in progress, exactly where it stopped)
**Open questions**: …        (decisions deferred for the Owner)
**Next-session priorities**: …
```

Keep the block within the tier's NEXT cap share (240 tok total at
`standard` across all unconsumed blocks); terse — handoff, not
journal. **Checkpoint mode** writes the block with *Outstanding* only
and the suffix `(checkpoint — pre-compaction)`.

### 5. Chain to `dream` (substantive sessions)

Substantive = multiple decisions / non-trivial work / ≥5 tool calls /
error recovery / Owner correction / novel workflow → invoke `/dream`
(prefer a forked subagent so this session's cache prefix is
untouched). **From a worktree or feature branch, skip `dream`** — T1
consolidation runs from the primary checkout (R5); the journal entry
carries the signals. Trivial sessions skip `dream`.

## Pitfalls

- **Committing without Owner accept** (interactive sessions).
- **Skipping the journal entry**: non-negotiable (R3).
- **Wrong filename**: `<YYYY-MM-DD>-<runtime>-<sid>.md`; two concurrent
  sessions must not share a `<sid>`.
- **Rewriting NEXT.md**: append a block; another session may be
  writing too. `session-start` is the only consumer.
- **Running `dream` from a worktree**: strands garden writes on a
  branch (R5).
- **Auto-running `dream` on trivial sessions**: thin USER.md entries.
- **Dropping the checkpoint**: on `PreCompact` write the block — the
  summary may lose the handoff otherwise.

## Verification

- `git status` reflects only Owner-accepted commits (or a `memory:`
  commit / PR in headless and worktree cases)
- Journal entry exists at the correct path with all sections filled
- `NEXT.md` has a new block whose items match *Open / NEXT*
- Substantive sessions on the integration branch: `dream` has run
  (*Consolidations applied* footer filled)
