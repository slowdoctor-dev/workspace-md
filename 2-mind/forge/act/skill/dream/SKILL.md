---
name: dream
description: Sleep-consolidation pass — replay journal entries and the harness-memory inbox to distill them into garden/essential/USER.md, garden/essential/SOUL.md, garden/<topic>.md, and new procedures in forge/ (T1, within capacity). Reconsolidate T1 items found wrong in use. Propose T2 graduations for Owner ratification (in-session or by PR). Named after sleep-consolidation (McGaugh replay; Anthropic Auto Dream).
---

# dream

## When to use

- **Chained**: after `session-end` of a substantive session (default).
- **Mid-session**: Hermes-style triggers — ≥5 tool calls in a
  non-trivial workflow, error recovery, Owner correction, novel
  workflow — and **reconsolidation**: a `USER.md` / garden item used
  this session turned out wrong or stale.
- **Explicit**: Owner invokes `/dream`.

Run from the **integration branch / primary checkout** (R5). Prefer a
**forked subagent** so the calling session's cache prefix is untouched
(harness-specific; e.g. Claude Code `context: fork` — set it in the
delegation, not in this file's frontmatter, which stays portable).

Operational instance of R1 (consolidation under capacity), R3
(source trail + reconsolidation), R4 (dual-store graduation).
session-end → dream → session-start completes a sleep cycle. 2026
results (Auto-Dreamer) support the shape: fast per-session capture,
slow cross-session consolidation, small memory banks outperform.

## Requires

Requires `3-control/foundation/SOUL.md`,
`3-control/foundation/PRINCIPLE.md`, and `2-mind/garden/essential/`
to exist. If any are missing, run `init` instead of continuing.

## Quick reference

| Signal type | Target | Tier |
|---|---|---|
| Owner preference / decision pattern | `garden/essential/USER.md` | **T1** |
| Owner-stance / identity-shift signal | `garden/essential/SOUL.md` (*Observations* / *Owner-signals*) | **T1** |
| → graduation of identity to canonical | `3-control/foundation/SOUL.md` | **T2** |
| Synthesized domain observation | `garden/<topic>.md` (lazy create) | **T1** |
| Procedure ≥5 tool calls, reusable | new `2-mind/forge/act/skill/<name>/SKILL.md` | **T1** |
| Mechanical task ≥2 occurrences | new `2-mind/forge/act/script/<name>` | **T1** |
| Recurring lifecycle need | `2-mind/forge/cue/lifecycle.md` row (+ re-render) | **T2** (renders execute) |
| Cross-session pattern → spec-level principle | `3-control/foundation/PRINCIPLE.md` | **T2** |
| Hard constraint to enforce | `3-control/rule/<topic>.md` | **T2** |

T1 applies immediately (within R1 caps). T2 requires per-item Owner
ratification — in-session, or by PR merge when headless
(`use-driven-memory.md §Ratification channels`).

## Procedure

### 1. Surgical signal gather

Read:
- Today's journal entry (written by `session-end`)
- Last 1–2 prior journal entries (cross-session patterns)
- `garden/essential/SOUL.md` *Observations* / *Owner-signals*
- **Harness-memory inbox (T0)** when present: Claude Code
  `~/.claude/projects/<project>/memory/MEMORY.md` (+ topic files),
  Codex `~/.codex/memories/`, subagent `memory:` dirs. Treat as raw
  observations, same as a transcript.

Do NOT full-rescan the transcript. Look for: Owner corrections
("no, instead X"), explicit saves ("remember this"), recurring themes
(≥2 across entries), decisions, failures + recoveries, Owner-declared
stances (1st-person quotable).

### 2. Categorize signals (Quick reference)

Apply R3: every derived entry cites its source —
`(journal <filename-stem>)`, `(auto-memory <runtime> <YYYY-MM-DD>)`,
or `(owner <YYYY-MM-DD>)`. Items from the inbox that merely restate
the codebase, or that `USER.md` already holds, are dropped, not
promoted. Promoted inbox items may be deleted at the source so the two
do not drift (adopter choice; note it in `3-control/runtime/<harness>.md`).

### 3. Apply T1 writes

**USER.md** — caps are token-primary: compare with
`2-mind/forge/act/script/token-count.sh` against the active tier in
`3-control/runtime/profile.md`. At or above the consolidate threshold,
run CONSOLIDATE before append. `USER.md` records **style, format and
procedure preferences**, never facts that outrank evidence (R3).

Operational tier summary — numeric values must match
`3-control/foundation/runtime-flexibility.md`:

| Tier | USER (hard / consol) | NEXT | journal/<entry> | garden-topic |
|---|---|---|---|---|
| `lean` | 500 / 400 | 170 | 1200 | 2000 |
| `standard` | 800 / 640 | 240 | 2000 | 3200 |
| `extended` | 1600 / 1280 | 400 | 4000 | 6400 |

**CONSOLIDATE** (R1 write-time enforcement):
1. **Near-duplicates** — same §section AND ≥50% lexical overlap on the
   descriptor (excluding citations), OR explicit Owner restatement.
2. **Superseded** — Y newer, same topic, contradicts X (Owner
   correction); or Y explicitly subsumes X; or Owner retracted X.
3. **Merge near-duplicates** into one entry carrying *all* citations.
4. **Drop superseded** entries; record the removal in the journal's
   *Consolidations applied* (R3 removal trail).
5. **Verify** post-consolidation: ≤ token hard cap; every entry still
   cited; no information loss against the feeding journals.
6. **Cannot reduce below cap** → escalate to Owner ("bump tier? prune?
   new §section?"). Never silently relax the cap or reject the write.

Then append the new entry with its citation.

**Reconsolidation on retrieval** (mid-session mode): when a T1 item
was used and found wrong, edit it in place now; keep the old citation,
append the new one `(journal <today>)`; log the change in today's
*Consolidations applied*.

**garden/essential/SOUL.md** — *Observations* / *Owner-signals* grow
without cap (managed by graduation + *Graduated*). Append with
citations.

**garden/<topic>.md** — create on second occurrence of a topic; cite
sources; `audit` flags/splits at the tiered threshold.

**New skills/scripts in forge/** — ≥5-tool-call reusable pattern →
`act/skill/<name>/SKILL.md` (portable-six frontmatter only);
mechanical task ≥2 occurrences → `act/script/<name>`. No ratify gate;
`audit` prunes low-utility periodically.

### 4. Prepare T2 graduation proposals

Targets: `3-control/foundation/SOUL.md`, `PRINCIPLE.md`,
`3-control/rule/<topic>.md`, `2-mind/forge/cue/lifecycle.md` (+
rendered hooks). Draft each as a diff with context ("Pattern recurred
in journals X, Y, Z. Propose adding to <target>. Accept?").

- **Interactive**: present per item; wait for the decision.
- **Headless / cloud / CI**: write
  `1-active/proposals/<YYYY-MM-DD>_<slug>.md` (target, diff, citations,
  `status: proposed`), commit to a branch, open a PR. Merge = ratify;
  the next interactive `dream` updates the proposal's status.

### 5. Apply ratified T2 changes

Apply each accepted diff. For `garden/essential/SOUL.md` →
`3-control/foundation/SOUL.md` graduations: mark the source entry
`[graduated YYYY-MM-DD → 3-control/foundation/SOUL.md]` and move it to
*Graduated* (R3 trail).

### 6. Update journal footer

Append to today's *Consolidations applied*: T1 writes (path + brief
description), reconsolidations, inbox items promoted/dropped, T2
proposals (ratified + applied / queued / declined).

## Pitfalls

- **Full-rescan instead of surgical gather**: wasteful, blurs signal.
- **Premature codification**: <5 tool calls or single-shot = note, not
  skill.
- **T2 boundary violations**: writing 3-control/ or a hook file
  without ratify; skipping citations; loading working SOUL.md at
  session-start.
- **Running from a worktree**: strands garden writes (R5).
- **Promoting inbox items verbatim**: harness memories duplicate the
  codebase and `AGENTS.md` often; distil, cite, or drop.
- **Letting preferences become facts**: a remembered preference that
  contradicts the code or data is surfaced, not applied (R3).
- **Dropping citations on merge**; **silently relaxing the cap**.

## Verification

- All gathered signals categorized to a target (or explicitly deferred)
- `USER.md` within its effective token cap; all entries cited;
  merged entries carry all citations; no information loss
- Reconsolidated items carry both old and new citations
- T2 items either ratified in-session or queued as proposal + PR
- Journal *Consolidations applied* footer filled
