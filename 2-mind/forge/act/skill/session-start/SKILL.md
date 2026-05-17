---
name: session-start
description: Load read order into agent context at every session begin. Consume + clear NEXT.md (the working buffer). Brief Owner on state. Not the one-time bootstrap (use init for that).
---

# session-start

## When to use

At the beginning of every working session. Not the first-time
bootstrap (use `init` for that).

## Quick reference

| Step | Reads | Writes |
|---|---|---|
| 1. Quick integrity | repo structure + `3-control/runtime/profile.md` | — |
| 2. Load read order | 7 files (see Procedure §2) | — |
| 3. Consume NEXT | `garden/essential/NEXT.md` | clears NEXT.md content |
| 4. Brief Owner | (compiled from loaded files) | — |
| 5. Confirm direction | (Owner reply) | — |

## Procedure

### 1. Lightweight integrity check

Confirm 4 top folders + `2-mind/garden/` + `2-mind/forge/` +
`3-control/foundation/{SOUL,PRINCIPLE}.md` are present. If broken,
escalate to `init`.

If `3-control/runtime/profile.md` is absent, default `active_tier =
lean` for this session and remind Owner that `init` should run to
ratify the proper tier.

### 2. Load read order (7 items, in sequence)

1. `AGENTS.md` — workspace entry + per-runtime mapping
2. `WORKSPACE.md` — topology spec
3. `3-control/foundation/PRINCIPLE.md` — operating principles
4. `3-control/foundation/SOUL.md` — canonical identity
5. `2-mind/garden/essential/USER.md` — semantic person-model
6. `2-mind/garden/essential/NEXT.md` — working buffer (step 3 below)
7. `2-mind/garden/essential/journal/<most-recent>.md` — recent
   session continuity (find by `ls -t` on journal/, exclude
   ENTRY-TEMPLATE.md and entries >30 days old to avoid stale context)

Do NOT load `garden/essential/SOUL.md` — that's working observations,
read only by `learn`.

### 3. Consume + clear NEXT.md

Read NEXT.md, integrate into working context, then rewrite the file
to the empty template (sections retained, content removed). Single-
consumption per Baddeley episodic-buffer discipline — `session-end`
writes fresh content for the next session.

### 4. Brief the Owner

Compile a 3-5 line brief:
- Where last session paused (from consumed NEXT)
- Anything stale or open (USER patterns, recent journal)
- Structural changes since (`git log` since last session)

### 5. Confirm direction

Ask "What do we work on this session?" — wait for Owner's reply
before starting.

## Pitfalls

- **Loading `garden/essential/SOUL.md`**: that's the working store,
  not canonical. R4 says it's NOT in session-start load.
- **Forgetting to clear NEXT.md**: leaving content makes the next
  session double-process the handoff. Single-consumption is the rule.
- **Loading a stale most-recent journal entry**: if the most-recent
  entry is months old, it's not "recent continuity" — skip it (load
  only if last 30 days).
- **Changing read order**: order matters for cache stability. Locked
  per R2 unless deliberate spec-level revision.

## Verification

- All 7 read-order files have been loaded (or explicitly skipped per
  the rules above)
- NEXT.md is empty (template structure remains, content cleared)
- Owner has confirmed session direction
- No structural integrity warnings
