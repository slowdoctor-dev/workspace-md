---
name: session-start
description: Load read order into agent context at every session begin. Invoke `detect-runtime` in drift-check mode and propose re-ratify on runtime mismatch with profile.md. Consume + clear NEXT.md (the working buffer). Brief Owner on state. Not the one-time bootstrap (use `init` for that).
---

# session-start

## When to use

At the beginning of every working session. Not the first-time
bootstrap (use `init` for that).

## Requires

Requires `3-control/foundation/SOUL.md`,
`3-control/foundation/PRINCIPLE.md`, and `2-mind/garden/essential/`
to exist. If any are missing, run `init` instead of continuing.

## Quick reference

| Step | Reads | Writes |
|---|---|---|
| 1. Quick integrity + runtime drift check | repo structure + `3-control/runtime/profile.md` + `detect-runtime` result | — |
| 2. Load read order | 7 files (see Procedure §2) | — |
| 3. Consume NEXT | `garden/essential/NEXT.md` | clears NEXT.md content |
| 4. Brief Owner | (compiled from loaded files) | — |
| 5. Confirm direction | (Owner reply) | — |

## Procedure

### 1. Lightweight integrity check + runtime drift detection

Confirm 4 top folders + `2-mind/garden/` + `2-mind/forge/` +
`3-control/foundation/{SOUL,PRINCIPLE}.md` are present. If broken,
escalate to `init`.

Invoke `detect-runtime` skill in drift-check mode (cheap re-detect
using cached self-introspection where possible). Compare against
active `3-control/runtime/profile.md`:

- **profile.md present + detection matches** → silent pass; use
  profile.md's active_tier
- **profile.md present + `harness`, `backend_model`, or
  `effective_context` differs** → surface diff to Owner + propose
  re-ratify; default behavior = continue with profile.md's tier for
  this session
- **profile.md absent** → default `active_tier = standard` (R1
  baseline) for this session; remind Owner to run `/init` to create
  active `profile.md` from `3-control/runtime/profile.example.md`
- **detect-runtime fails or returns uncertain** (no shell access,
  headless, network unreachable) → continue silently with profile.md's
  tier (or `standard` if absent); record the failure in the audit-log
  next time `audit` runs

### 2. Load read order (7 items, in sequence)

Canonical: `3-control/foundation/use-driven-memory.md` §Read order.
Keep this operational list numerically in sync with that source.

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
read only by `dream`.

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
- **Blocking session on detect-runtime failure**: drift detection is
  best-effort. If `detect-runtime` errors (no shell, no network,
  uncertain), continue silently with profile.md's tier — do NOT
  block session-start on detection.
- **Silently changing active tier on drift**: drift surfaces a
  re-ratify proposal; the session continues with profile.md's
  recorded tier. Tier change requires Owner ratify, not auto-apply.

## Verification

- All 7 read-order files have been loaded (or explicitly skipped per
  the rules above)
- NEXT.md is empty (template structure remains, content cleared)
- Owner has confirmed session direction
- No structural integrity warnings
