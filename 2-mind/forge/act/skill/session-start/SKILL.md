---
name: session-start
description: Load the hot read order at every session begin. Full mode on startup (drift check via `detect-runtime`, consume + clear NEXT.md, brief Owner); re-entry mode after compaction / resume / fork (hot load only). Not the one-time bootstrap (use `init`).
---

# session-start

## When to use

- **Full mode** — a new context window begins (`startup`).
- **Re-entry mode** — the harness rebuilt context mid-work
  (`compact`, `resume`, `fork`; see `2-mind/forge/cue/lifecycle.md`).

Not the first-time bootstrap (use `init`).

## Requires

Requires `3-control/foundation/SOUL.md`,
`3-control/foundation/PRINCIPLE.md`, and `2-mind/garden/essential/`
to exist. If any are missing, run `init` instead of continuing.

## Quick reference

| Step | Full | Re-entry | Reads | Writes |
|---|---|---|---|---|
| 1. Integrity + drift check | ✓ | — | repo structure, `3-control/runtime/profile.md`, `detect-runtime` | — |
| 2. Load hot read order | ✓ | ✓ (items 1–3, 5) | 5 files (Procedure §2) | — |
| 3. Consume NEXT | ✓ | — | `garden/essential/NEXT.md` | clears NEXT.md |
| 4. Brief Owner | ✓ | — | compiled | — |
| 5. Confirm direction | ✓ | — | Owner reply | — |

## Procedure

### 1. Lightweight integrity check + runtime drift detection (full mode)

Confirm 4 top folders + `2-mind/garden/` + `2-mind/forge/` +
`3-control/foundation/{SOUL,PRINCIPLE}.md` are present. If broken,
escalate to `init`.

Invoke `detect-runtime` in drift-check mode and compare against
`3-control/runtime/profile.md`:
- **present + matches** → silent pass; use its `active_tier`
- **present + `harness`, `backend_model`, or `model_class` differs** →
  surface diff + propose re-ratify; continue with profile.md's tier
- **absent** → `active_tier = standard`; remind Owner to run `/init`
- **detection fails / uncertain** → continue silently with profile.md's
  tier (or `standard`); note it for the next `audit`

### 2. Load hot read order (5 items, in sequence)

Canonical: `3-control/foundation/use-driven-memory.md §Read order`.
Keep this list numerically in sync with that source.

1. `AGENTS.md` — operational card
2. `3-control/foundation/SOUL.md` — canonical identity
3. `2-mind/garden/essential/USER.md` — person-model (style, not facts)
4. `2-mind/garden/essential/NEXT.md` — working buffer (step 3)
5. `2-mind/garden/essential/journal/<most-recent>.md` — continuity
   (`ls -t` on journal/, exclude ENTRY-TEMPLATE.md; skip if >30 days)

**Re-entry mode**: re-inject 1, 2, 3, 5 *as they were at startup* (R2
Part A — do not pick up T1 writes made this session). Skip item 4:
`NEXT.md` was already consumed, and any checkpoint block written at
`PreCompact` belongs to this session's own handoff. Skip steps 3–5.

Do NOT load `garden/essential/SOUL.md` (working store, `dream` only),
`WORKSPACE.md`, or `PRINCIPLE.md` (reference set — read on demand).

### 3. Consume + clear NEXT.md (full mode)

Read every `### <runtime>/<sid> @ <time>` block, integrate into
working context, then rewrite the file to the empty template (header
retained, blocks removed). Single-consumption per Baddeley episodic-
buffer discipline — `session-end` appends fresh blocks.

If the file holds blocks from several concurrent sessions, consume
them all; the Owner brief (step 4) notes which sessions contributed.

### 4. Brief the Owner (full mode)

3–5 lines: where the last session(s) paused (from NEXT), anything
stale or open (USER patterns, recent journal), structural changes
since (`git log` since the last journal entry), tier in effect.

### 5. Confirm direction (full mode)

Ask "What do we work on this session?" — wait for the Owner's reply.
In headless runs, take direction from the invoking prompt instead.

## Pitfalls

- **Loading reference docs at startup**: `WORKSPACE.md` and
  `PRINCIPLE.md` are spec text; loading them every session dilutes
  attention (R2 Part B). Cite sections when needed.
- **Loading `garden/essential/SOUL.md`**: R4 — `dream` only.
- **Consuming NEXT.md on re-entry**: double-processes the handoff and
  destroys the `PreCompact` checkpoint. Re-entry never touches NEXT.
- **Re-reading this session's T1 writes on re-entry**: breaks R2 Part A
  (reacting to one's own just-written claims).
- **Loading a stale most-recent journal**: months old ≠ continuity;
  skip beyond 30 days.
- **Changing read order**: order matters for cache stability. Locked
  per R2 unless deliberate spec-level revision.
- **Blocking on detect-runtime failure**: drift detection is
  best-effort; never block session-start on it.
- **Silently changing active tier on drift**: drift → re-ratify
  proposal; the session continues with the recorded tier.

## Verification

- Full mode: 5 hot items loaded (or explicitly skipped per rules);
  `NEXT.md` cleared to template; Owner confirmed direction; no
  integrity warnings
- Re-entry mode: items 1–3 and 5 re-injected; `NEXT.md` untouched;
  no brief, no direction prompt
