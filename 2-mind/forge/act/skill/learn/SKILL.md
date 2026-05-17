---
name: learn
description: Consolidation pass — distill journal entries into garden/essential/USER.md, garden/essential/SOUL.md, garden/<topic>.md, and new procedures in forge/ (all T1 autonomous within capacity). Propose T2 graduations to 3-control/foundation/SOUL.md, 3-control/foundation/PRINCIPLE.md, and 3-control/rule/ for Owner ratification.
---

# learn

## When to use

Three modes:

- **Chained**: after `session-end` of a substantive session (default).
- **Mid-session**: on Hermes-style triggers — ≥5 tool calls in a
  non-trivial workflow, error recovery, Owner correction, novel
  workflow.
- **Explicit**: Owner invokes `/learn` directly.

Operational instance of R1 (consolidation under capacity) + R4
(dual-store graduation).

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

T1 applies immediately (within R1 capacity bounds). T2 requires
per-item Owner ratification — the 3-control/ governance boundary.

## Procedure

### 1. Surgical signal gather

Read:
- Today's journal entry (written by `session-end`)
- Last 1–2 prior journal entries (cross-session pattern detection)
- `garden/essential/SOUL.md` *Observations* / *Owner-signals*

Do NOT full-rescan the transcript. Look for:
- Owner corrections ("no, instead X" / "don't do Y")
- Explicit saves ("remember this" / "always do Z")
- Recurring themes (≥2 occurrences across recent entries)
- Decisions (architecture / naming / library / convention)
- Failures + recoveries (the recovery is the lesson)
- Owner-declared stances (1st-person quotable for SOUL graduation)

### 2. Categorize signals (use Quick Reference table)

Match each signal to a target. Apply R3 source-monitoring: every
derived entry MUST cite its source journal as
`(journal <YYYY-MM-DD-runtime-NNN>)`.

### 3. Apply T1 writes

**USER.md** — R1 natural cap = 100 lines / consolidate at 80. R2
runtime-tier (read `3-control/runtime/profile.md`; default
`standard` = R1 unchanged) may scale: lean → 60/50, extended →
200/160. At ≥80% of the effective hard cap, CONSOLIDATE before
append: merge near-duplicates, drop superseded items.

**garden/essential/SOUL.md** — *Observations* / *Owner-signals* grow
without cap (managed by graduation + *Graduated* section). Append
with citations.

**garden/<topic>.md** — create on second occurrence of a topic; cite
sources; no fixed cap; `audit` consolidates.

**New skills/scripts in forge/** — on ≥5-tool-call trigger + reusable
pattern → `2-mind/forge/act/skill/<name>/SKILL.md`. Mechanical task
≥2 occurrences → `2-mind/forge/act/script/<name>`. No ratify gate;
`audit` prunes low-utility periodically.

### 4. Prepare T2 graduation proposals

Targets at the 3-control/ governance boundary:
- `3-control/foundation/SOUL.md` (canonical identity graduation)
- `3-control/foundation/PRINCIPLE.md` (spec-level principle)
- `3-control/rule/<topic>.md` (new enforceable rule)

For each: draft the change as a diff, present with context ("Pattern
recurred in journals X, Y, Z. Propose adding to <target>. Accept?"),
wait for per-item decision.

### 5. Apply ratified T2 changes

For each accepted item, apply the diff. For
`garden/essential/SOUL.md` → `3-control/foundation/SOUL.md`
graduations: mark the source entry
`[graduated YYYY-MM-DD → 3-control/foundation/SOUL.md]` and move it
to *Graduated* (R3 source trail preserved).

### 6. Update journal footer

Append to today's journal *Consolidations applied* section:
- T1 writes (file path + brief description per item)
- T2 proposals (ratified + applied vs deferred / declined)

## Pitfalls

- **Full-rescan instead of surgical grep**: wasteful, blurs signal.
  Narrow to patterns first.
- **Premature codification**: <5 tool calls or single-shot pattern =
  note, not skill. Resist new skill files until the pattern recurs.
- **T2 boundary violations**: writing 3-control/ without ratify,
  skipping `(journal …)` citations, or loading
  `garden/essential/SOUL.md` at session-start — each breaks a rule
  (R4 / R3 / R4 respectively).
- **Skipping consolidate-on-error**: USER.md must consolidate at 80%
  of its effective cap (R1 natural × R2 tier scale) before append.

## Verification

- All sourced signals categorized to a target (or explicitly deferred)
- USER.md within active tier's hard cap; consolidate-on-error fired
  if needed
- All written entries have `(journal <YYYY-MM-DD-runtime-NNN>)`
  citations
- T2 proposals presented with diffs; Owner ratified per item
- Ratified T2 changes applied; rejected ones not written
- Today's journal entry footer updated with applied/deferred record
