---
name: learn
description: Consolidation pass — distill journal entries into USER.md, factory/essential/SOUL.md, and factory/<topic>.md (T1 autonomous). Propose T2 graduations to foundation/SOUL.md, foundation/PRINCIPLE.md, new skills, new rules. Owner ratifies T2 per item.
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

| Signal type | T1 target (autonomous) | T2 target (propose-ratify) |
|---|---|---|
| Owner preference / decision pattern | `factory/essential/USER.md` | — |
| Owner-stance / identity-shift signal | `factory/essential/SOUL.md` (Observations / Owner-signals sections) | propose graduation → `4-control/foundation/SOUL.md` |
| Synthesized domain observation | `factory/<topic>.md` (lazy create) | — |
| Cross-session pattern → spec-level | — | propose update → `4-control/foundation/PRINCIPLE.md` |
| Procedure ≥5 tool calls, reusable | — | propose new `3-playbook/act/skill/<name>/SKILL.md` |
| Mechanical task ≥2 occurrences | — | propose new `3-playbook/act/script/<name>` |
| Hard constraint | — | propose new `4-control/rule/<topic>.md` |

## Procedure

### 1. Surgical signal gather

Read sources:
- Today's journal entry (just written by `session-end`)
- Last 1–2 prior journal entries (cross-session pattern detection)
- `factory/essential/SOUL.md` Observations / Owner-signals sections
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
- Check size: if ≥80 lines (80% of 100 cap), CONSOLIDATE first.
  Merge near-duplicate entries, drop superseded items.
- Then append new entries with citations.

**factory/essential/SOUL.md**:
- Observations / Owner-signals sections grow without cap (cap is
  managed by graduation + Graduated section).
- Append observations with citations.

**factory/<topic>.md** (for synthesized domain notes):
- Create lazily on second occurrence of the same topic
- Cite source journal entries
- No fixed cap; `audit` handles consolidation

### 4. Prepare T2 graduation proposals

For each candidate (foundation/SOUL graduation / PRINCIPLE update /
new skill / new rule / new script):
- Draft the change as a diff
- Present to Owner with context: "This pattern recurred in journals
  X, Y, Z. Propose adding to <target>. Accept?"
- Wait for per-item Owner decision

### 5. Apply ratified T2 changes

For each accepted item:
- Apply the diff to the target file
- For factory/essential/SOUL.md → foundation/SOUL.md graduations:
  mark the source entry in factory/essential/SOUL.md as
  `[graduated YYYY-MM-DD → foundation/SOUL.md]` and move to
  Graduated section (preserves R3 source trail)

### 6. Update today's journal entry footer

Append to "Consolidations applied" section of today's journal:
- T1 writes (file path + brief description per item)
- T2 proposals (ratified + applied vs deferred / declined)

## Pitfalls

- **Full-rescan instead of surgical grep**: wasteful, blurs signal.
  Always narrow to specific patterns first.
- **Creating thin skills**: <5 tool calls = a note in USER.md or
  journal-only, not a skill. Resist premature codification.
- **Writing to foundation/SOUL.md or PRINCIPLE.md without ratify**:
  that's a T2 violation. ALL canonical-store changes go through Owner
  ratify gate.
- **Skipping source citations**: R3 source-monitoring requires
  citation. A synthesized claim without traceable source is anti-
  pattern.
- **Overflowing USER.md without consolidate-on-error**: must
  consolidate at 80% (80 lines) before append. R1 capacity discipline.
- **Loading factory/essential/SOUL.md at session-start**: that's NOT
  loaded normally; only `learn` reads it. Don't trigger
  cache-invalidating loads.

## Verification

- All sourced signals categorized to a target (or explicitly deferred)
- USER.md ≤100 lines; consolidate-on-error fired if needed
- All written entries have `(journal <YYYY-MM-DD-runtime-NNN>)`
  citations
- T2 proposals presented with diffs; Owner ratified per item
- Ratified T2 changes applied; rejected ones not written
- Today's journal entry footer updated with applied/deferred record
