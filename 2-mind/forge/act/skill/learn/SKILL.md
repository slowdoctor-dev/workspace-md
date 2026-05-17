---
name: learn
description: Consolidation pass — distill journal entries into garden/essential/USER.md, garden/essential/SOUL.md, garden/<topic>.md, and new procedures in forge/ (all T1 autonomous within capacity). Propose T2 graduations to 3-control/foundation/SOUL.md, 3-control/foundation/PRINCIPLE.md, and 3-control/rule/ for Owner ratification.
---

# learn

## When to use

Three invocation modes:

- **Chain from session-end**: after `session-end` of a substantive
  session (default).
- **Mid-session trigger**: when one of Hermes-style triggers fires:
  ≥5 tool calls in a non-trivial workflow / error recovery / Owner
  correction / novel workflow discovered.
- **Explicit `/learn`**: Owner invokes directly.

Operational instance of *use-driven evolution* + *R1 consolidation
under capacity* + *R4 dual-store graduation*.

## Quick reference

| Signal type | Target | Tier |
|---|---|---|
| Owner preference / decision pattern | `garden/essential/USER.md` | **T1** autonomous |
| Owner-stance / identity-shift signal | `garden/essential/SOUL.md` (Observations / Owner-signals sections) | **T1** autonomous |
| → graduation of identity to canonical | `3-control/foundation/SOUL.md` | **T2** Owner-ratify |
| Synthesized domain observation | `garden/<topic>.md` (lazy create) | **T1** autonomous |
| Procedure ≥5 tool calls, reusable | new `2-mind/forge/act/skill/<name>/SKILL.md` | **T1** autonomous (procedural memory) |
| Mechanical task ≥2 occurrences | new `2-mind/forge/act/script/<name>` | **T1** autonomous |
| Cross-session pattern → spec-level principle | `3-control/foundation/PRINCIPLE.md` | **T2** Owner-ratify |
| Hard constraint to enforce | `3-control/rule/<topic>.md` | **T2** Owner-ratify |

T1 changes apply immediately (within capacity bounds R1). T2 changes
require Owner per-item ratification — these are the
**3-control/ governance boundary**.

## Procedure

### 1. Surgical signal gather

Read sources:
- Today's journal entry (just written by `session-end`)
- Last 1–2 prior journal entries (cross-session pattern detection)
- `garden/essential/SOUL.md` Observations / Owner-signals sections
  (working identity state)

DO NOT full-rescan transcript. Look for:
- Owner corrections ("no, instead X" / "don't do Y")
- Explicit saves ("remember this" / "always do Z")
- Recurring themes (same pattern 2+ times across recent entries)
- Decisions (architecture / naming / library / convention choices)
- Failures + recoveries (the recovery is the lesson)
- Owner-declared stances (1st-person quotable for SOUL graduation)

### 2. Categorize signals to targets (use Quick Reference table)

For each signal, decide its target. Apply *R3 source-monitoring*:
each derived entry MUST cite back to the source journal entry
(format: `(journal <YYYY-MM-DD-runtime-NNN>)`).

### 3. Apply T1 writes (autonomous within capacity)

**USER.md**:
- Check size against active tier cap (read
  `3-control/runtime/profile.md` for active_tier; default `lean`).
  If ≥80% of the tier's hard cap (lean: 50 / standard: 80 /
  extended: 160), CONSOLIDATE first — merge near-duplicate entries,
  drop superseded items.
- Then append new entries with citations.

**garden/essential/SOUL.md**:
- Observations / Owner-signals sections grow without cap (cap is
  managed by graduation + Graduated section).
- Append observations with citations.

**garden/<topic>.md** (for synthesized domain notes):
- Create lazily on second occurrence of the same topic
- Cite source journal entries
- No fixed cap; `audit` handles consolidation

**New skills/scripts in forge/** (T1 autonomous):
- When ≥5-tool-calls trigger fires + pattern is reusable, create
  `2-mind/forge/act/skill/<name>/SKILL.md` directly
- Mechanical task recurring ≥2 times → `2-mind/forge/act/script/<name>`
- No Owner ratify gate — but `audit` skill prunes low-utility skills
  periodically

### 4. Prepare T2 graduation proposals (3-control/ only)

For each candidate that targets the 3-control/ governance boundary:
- `3-control/foundation/SOUL.md` (canonical identity graduation)
- `3-control/foundation/PRINCIPLE.md` (spec-level principle)
- `3-control/rule/<topic>.md` (new enforceable rule)

Procedure:
- Draft the change as a diff
- Present to Owner with context: "This pattern recurred in journals
  X, Y, Z. Propose adding to <target>. Accept?"
- Wait for per-item Owner decision

### 5. Apply ratified T2 changes

For each accepted item:
- Apply the diff to the target file
- For garden/essential/SOUL.md → 3-control/foundation/SOUL.md
  graduations: mark the source entry in garden/essential/SOUL.md
  as `[graduated YYYY-MM-DD → 3-control/foundation/SOUL.md]` and
  move to Graduated section (preserves R3 source trail)

### 6. Update today's journal entry footer

Append to "Consolidations applied" section of today's journal:
- T1 writes (file path + brief description per item)
- T2 proposals (ratified + applied vs deferred / declined)

## Pitfalls

- **Full-rescan instead of surgical grep**: wasteful, blurs signal.
  Always narrow to specific patterns first.
- **Creating thin skills**: <5 tool calls = a note in USER.md or
  journal-only, not a skill. Resist premature codification.
- **Writing to 3-control/ without Owner ratify**: that's a T2
  violation. ALL 3-control/ changes (foundation/, rule/, external/,
  runtime/) require Owner ratify gate. The folder boundary is the
  tier boundary.
- **Skipping source citations**: R3 source-monitoring requires
  citation. A synthesized claim without traceable source is anti-
  pattern.
- **Overflowing USER.md without consolidate-on-error**: must
  consolidate at 80% of the active tier's hard cap before append
  (see `3-control/runtime/profile.md`). R1 capacity discipline.
- **Loading garden/essential/SOUL.md at session-start**: that's NOT
  loaded normally; only `learn` reads it. Don't trigger
  cache-invalidating loads.

## Verification

- All sourced signals categorized to a target (or explicitly deferred)
- USER.md within active tier's hard cap; consolidate-on-error fired
  if needed
- All written entries have `(journal <YYYY-MM-DD-runtime-NNN>)`
  citations
- T2 proposals presented with diffs; Owner ratified per item
- Ratified T2 changes applied; rejected ones not written
- Today's journal entry footer updated with applied/deferred record
