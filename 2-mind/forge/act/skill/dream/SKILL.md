---
name: dream
description: Sleep-consolidation pass — replay journal entries to distill them into garden/essential/USER.md, garden/essential/SOUL.md, garden/<topic>.md, and new procedures in forge/ (all T1 autonomous within capacity). Propose T2 graduations to 3-control/foundation/SOUL.md, 3-control/foundation/PRINCIPLE.md, and 3-control/rule/ for Owner ratification. Named after sleep-consolidation (McGaugh replay; Anthropic Auto Dream).
---

# dream

## When to use

Three modes:

- **Chained**: after `session-end` of a substantive session (default).
- **Mid-session**: on Hermes-style triggers — ≥5 tool calls in a
  non-trivial workflow, error recovery, Owner correction, novel
  workflow.
- **Explicit**: Owner invokes `/dream` directly.

Operational instance of R1 (consolidation under capacity) + R4
(dual-store graduation). Named for the sleep-consolidation metaphor
that R1/R2 are grounded in (McGaugh hippocampus→cortex replay;
Anthropic Auto Dream); session-end → dream → session-start completes
a sleep cycle (lay down memory → consolidate during quiescence →
wake to refined context).

## Requires

Requires `3-control/foundation/SOUL.md`,
`3-control/foundation/PRINCIPLE.md`, and `2-mind/garden/essential/`
to exist. If any are missing, run `init` instead of continuing.

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

### 2. Categorize signals (use Quick reference table)

Match each signal to a target. Apply R3 source-monitoring: every
derived entry MUST cite its source journal as
`(journal <YYYY-MM-DD>-<runtime>-<NNN>)`.

### 3. Apply T1 writes

**USER.md** — memory caps are token-primary. Use
`2-mind/forge/act/script/token-count.sh` to compare the file against
the active tier from `3-control/runtime/profile.md`; line counts are
advisory report context only. At or above the tier's consolidate
threshold, run CONSOLIDATE (below) before append.

Operational token tier summary. Numeric cap values must match
`3-control/foundation/runtime-flexibility.md`; columns may differ for
operator convenience.

| Tier | USER (hard / consol) | NEXT | journal/<entry> | garden-topic |
|---|---|---|---|---|
| `lean` | 500 / 400 | 170 | 1200 | 2000 |
| `standard` | 800 / 640 | 240 | 2000 | 3200 |
| `extended` | 1600 / 1280 | 400 | 4000 | 6400 |

**CONSOLIDATE procedure** (R1 write-time enforcement):

1. **Identify near-duplicates** — entries with overlapping subject +
   semantically similar claim. Heuristic: same §section AND
   ≥50% lexical overlap on the descriptor (excluding citation
   suffix), OR explicit Owner restatement of an earlier point.
2. **Identify superseded entries** — entry X is superseded by entry
   Y when: (a) Y is newer AND on the same topic AND contradicts X
   (Owner correction); OR (b) Y explicitly subsumes X ("we used to
   X, now we do Y"); OR (c) Owner has retracted X.
3. **Merge near-duplicates** — produce one consolidated entry
   carrying *all* source citations (R3): `<merged descriptor>
   (journal A, B, C)`. Never drop citations on merge — preserves
   source trail.
4. **Drop superseded entries** — remove from USER.md but record the
   removal in the journal entry's *Consolidations applied* section
   (R3: removal trail preserved in episodic store even if removed
   from semantic store).
5. **Verify post-consolidation**: USER.md is ≤ its token hard cap
   according to `token-count.sh`; line count is recorded only as an
   advisory. Every remaining entry still has its `(journal …)`
   citation(s), with no information loss against the journal entries
   that fed it (the journal entries are unchanged).
6. **If consolidation can't reduce below cap** — all entries are
   distinct and current. Two paths:
   - If the new entry is itself a near-duplicate / supersedes
     something → still apply consolidation, may reduce by 1.
   - Otherwise → escalate to Owner: "USER.md at cap; no
     consolidation candidates. Bump tier? Manual prune? Add a new
     §section?". Do NOT silently relax the cap or reject the write.

Then append the new entry with its `(journal …)` citation.

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
- **Skipping consolidate-on-error**: USER.md must consolidate at the
  active tier's token threshold before append. Line counts are
  advisory and must not decide memory-cap compliance.
- **Dropping citations on merge**: merging two USER entries on the
  same topic must carry forward *both* journal citations. Losing one
  breaks R3 source trail.
- **Silently relaxing the cap**: if no consolidation candidates exist
  at the cap, escalate to Owner — do not auto-bump the cap or reject
  the write.

## Verification

- All sourced signals categorized to a target (or explicitly deferred)
- USER.md within its effective token hard cap (R1 × R2 tier via
  `token-count.sh`); if consolidation ran, the post-consolidation file
  is ≤cap, all remaining entries retain their citations, no
  information loss against feeding journal entries
- All written entries have `(journal <YYYY-MM-DD>-<runtime>-<NNN>)`
  citations (merged entries carry *all* source citations)
- T2 proposals presented with diffs; Owner ratified per item
- Ratified T2 changes applied; rejected ones not written
- Today's journal entry footer updated: T1 writes + T2 proposals +
  any superseded-entry removals (R3 trail)
