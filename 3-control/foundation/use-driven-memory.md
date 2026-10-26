# Use-driven memory

Cognitive-architecture spec for workspace.md auto-growth — the
operational machinery behind the *use-driven evolution* design value.

## Scope

workspace.md specifies the **file scaffold** for the Memory System
of a self-growing-agent stack. Deliberately out of scope: Optimizer
(fine-tuning, exploration) and Environment & Feedback (LLM-as-judge,
reward systems). The workspace provides the files; the runtime
drives the loop.

## 7 memory stores + cognitive analogs

| Store | Location | Tier | Cognitive analog |
|---|---|---|---|
| Self canonical | `3-control/foundation/SOUL.md` | T2 | Conway core self-schema |
| Self working | `2-mind/garden/essential/SOUL.md` | T1 | Conway working-self observations |
| Semantic person | `2-mind/garden/essential/USER.md` (R1 natural cap; R2 tier-adjusted) | T1 | Conway external person-schema |
| Working buffer | `2-mind/garden/essential/NEXT.md` (single-consumption, append-only blocks) | T1 | Baddeley 2000 episodic buffer |
| Episodic | `2-mind/garden/essential/journal/<YYYY-MM-DD>-<runtime>-<sid>.md` | T1 | Tulving 1972 episodic store |
| Semantic domain | `2-mind/garden/` (whole folder; sub-org per lazy-structure) | T1 | Tulving semantic store |
| Procedural | `2-mind/forge/` (whole layer) | T1 | Schacter-Tulving 1994 procedural |

Garden = declarative memory in full (semantic + episodic + working);
`essential/` is the bounded fast-access portion. Forge = procedural
memory; agent creates new skills, scripts, role specs, triggers when
patterns recur.

**Harness-native memory (T0 — inbox, not a store).** Harnesses keep
their own memories outside the repo (Claude Code auto memory at
`~/.claude/projects/<project>/memory/`, Codex `~/.codex/memories/`,
subagent `memory:` dirs). These are *not canonical* and *not loaded by
the spec's read order*: `dream` ingests them like a transcript — items
promote into T1 stores with an `(auto-memory <runtime> <YYYY-MM-DD>)`
citation and may then be removed at the source. Adopters may disable
harness memory instead (adapter notes in `3-control/runtime/`). The
runtime transcript plays the same pre-consolidation role — searched on
demand, never loaded at session-start.

## 2 write-tiers

- **T1 — agent autonomous within capacity**: `2-mind/garden/` +
  `2-mind/forge/`. Agent writes without ratification, bounded by
  per-store capacity rules (R1).
- **T2 — agent-proposes, Owner-ratifies**: all of `3-control/` —
  `foundation/`, `rule/`, `external/`, `runtime/` — plus
  `2-mind/atelier/` when content exists, plus **any runtime-native
  config that executes** (`.claude/settings.json` hooks,
  `.codex/config.toml`, `.agents/mcp_config.json`, `.mcp.json`
  target). Agent presents a diff; Owner accepts per item.

There is no T3 (Owner-only-no-touch). Even canonical SOUL.md permits
agent-proposed graduations; the firewall is *ratification*.

**Tier-by-location heuristic**: 2-mind/garden/ + 2-mind/forge/ = T1;
3-control/ + 2-mind/atelier/ + executing native configs = T2.

### Ratification channels

1. **Interactive** — agent presents the diff in-session; Owner accepts
   per item (default).
2. **Pull request** — for headless / cloud / scheduled sessions: the
   agent commits T2 changes to a branch and opens a PR; **merge = ratify**.
   Pending proposals are also recorded in
   `1-active/proposals/<YYYY-MM-DD>_<slug>.md` (lazy; status
   `proposed | ratified | declined`) so nothing is lost between runs.

## 5 operating rules

> **Namespace reservation.** `R1`–`R5` are reserved for the memory
> rules below; adopter rules in `3-control/rule/` use a distinct prefix
> (`ACME-1`, `TRUST-1`…). See `WORKSPACE.md §Rule placement`.

### R1 — Consolidation under capacity

Every store has a capacity bound rooted in cognitive usability — how
much content a store can hold before it stops *being* memory
(scan-ability drops, signal dilutes, near-duplicates accumulate).
Reaching the bound triggers in-place consolidation (merge
near-duplicates / drop superseded), never write-rejection. `dream`
replays independently of size pressure. Caps are **runtime-
independent**; tier adjustment is R2's concern. Caps are
**token-primary**; line counts are advisory (line-only caps overflow
for CJK content, ~2–3× tokens/line). Measure with
`2-mind/forge/act/script/token-count.sh`.

Small, consolidated stores are a feature, not a compromise: 2026
agent-memory work (Auto-Dreamer) reports a memory bank an order of
magnitude smaller than baselines *outperforming* them.

#### Two cap classes

- **Memory caps** (use-grown — hard, enforced by `dream`
  consolidate-on-error; **tokens**): `USER.md`, `NEXT.md`, journal
  entries, `garden/<topic>.md`.
- **Spec caps** (Owner-curated, growth-by-edit — advisory flags from
  `audit`; **lines**, English): the spec docs listed below.

#### Natural memory caps (R1 baseline = `standard` tier)

| Store | Hard cap (tokens) | Consolidate at | Line advisory | Rationale |
|---|---|---|---|---|
| `USER.md` | 800 | 640 | ~100 | ~10 Miller-chunked categories (7±2 entries × 3 sections) with headroom |
| `NEXT.md` | 240 soft (total at consumption) | n/a | ~30 | one screen; handoff, not journal |
| journal entry | 2000 soft | n/a | ~200 | one session's decisions + learnings at reading pace |
| garden `<topic>.md` | flag at 3200 | split or consolidate | ~300 | single subject cohesive without internal sectioning |

Working `SOUL.md` (garden): no cap; *Graduated* entries >6 months
pruned by `audit`. Journal entries >3 months → `garden/archive/<YYYY-MM>/`
(archival is not deletion — still grep-searchable). The numbers are
*defensibly grounded* but not *empirically validated*; `audit` now
logs store sizes per pass so adopter data can recalibrate them.

#### Spec caps (advisory flags, lines)

`README.md` 150 · `AGENTS.md` 80 · `WORKSPACE.md` 200 ·
`PRINCIPLE.md` 250 · canonical `SOUL.md` 100 · this file 300 ·
`runtime-flexibility.md` 200 · `adoption.md` 200. Growth-by-edit;
flag for Owner review when exceeded, never auto-consolidated.

*Theory*: McGaugh consolidation; Miller 1956; Ebbinghaus.

### R2 — Session-boundary discipline

A **session is one context-window lifetime**, not one terminal
lifetime. Boundaries: `startup` (full session-start), and
**re-entries** — `compact`, `resume`, `fork` — where the harness
rebuilds context mid-work. Hook-capable harnesses expose these as
events (`2-mind/forge/cue/lifecycle.md`); hook-less ones rely on the
skills' declarative discipline.

#### Part A — Writes settle between sessions

Memory writes appear in the **next full session's** loaded context,
never the current one: preserves prompt-cache stability, mirrors
sleep consolidation, prevents reacting to one's own just-written
claims. **Re-entry** re-injects the hot load *as it was at startup*
(do not re-read T1 stores written this session) and does **not**
consume `NEXT.md`. Before compaction, write a `NEXT.md` checkpoint
block (Outstanding only) so the handoff survives the summary.

#### Part B — Session-start load fits the attention budget

The 5-item hot load must stay small enough not to dilute attention:
≈6K tokens at `standard` (tier table in `runtime-flexibility.md`).
Raw context size is **not** the constraint — every current hosted
model has ≥1M — attention quality, cost, and cache stability are.
Reference docs are read on demand, never at startup. *Theory*:
context rot (quality degrades well below the advertised window);
sleep-boundary consolidation.

### R3 — Timestamped episodic, synthesized semantic

Episodic stores (journal entries) are **recorded at the time, not
re-synthesized** — per-session digests with timestamp, runtime tag,
and citations to commits/decisions. **T1 semantic stores** hold
**synthesized** content; each item cites its source as
`(journal <filename-stem>)`, `(auto-memory <runtime> <date>)`, or
`(owner <date>)` for a direct Owner statement. **T2 foundation docs**
change by Owner-ratified diff and cite theory or a graduation trail,
not journals (so `audit`'s citation-gap scan covers T1 only).

**Reconsolidation on retrieval**: when a T1 item is *used* in-session
and found wrong or stale, correct it in place at that moment, keep the
old citation, add the new one. A synthesized claim is always traceable
to its raw observation. *Theory*: Loftus 1974; Johnson 1993.

**Person-model is not evidence**: `USER.md` governs style, format and
procedure. It never outranks the codebase, data, or a current Owner
statement; on conflict present the evidence and let the Owner decide
(memory over-personalization is a documented 2026 failure mode).

### R4 — Two-tier authority with mirrored identity

Identity uses **dual-store**: working observations
(`garden/essential/SOUL.md`, T1) accumulate freely; canonical identity
(`3-control/foundation/SOUL.md`, T2) updates only via Owner-ratified
graduation. The working store is **not** loaded at session-start —
`dream` reads it only when preparing graduations. *Theory*: Conway
self-memory system; Hermes Agent SOUL contract (relaxed to permit
T2-ratified updates).

### R5 — Concurrency: memory lives on the integration branch

Parallel sessions (worktrees, subagents, cloud runs) are the norm.

- **Branch**: `2-mind/garden/` writes belong to the integration branch
  (`main`). A worktree / feature-branch session writes **only its
  journal entry** and a `NEXT.md` block; `dream`'s T1 consolidation
  runs from the primary checkout (or lands via a `memory:`-prefixed
  commit the Owner merges first). `audit` scans unmerged branches for
  stranded garden writes.
- **Identity**: journal filenames carry a session id
  (`<sid>` = harness session-id prefix or `HHMMSS`); `NNN` ordinals
  remain valid for strictly sequential single-session use.
- **Buffer**: `NEXT.md` is **append-only blocks** (`### <runtime>/<sid>
  @ <ISO>`), never rewritten by a writer; `session-start` consumes
  all blocks then clears. Blocks merge cleanly in git.
- **Subagents**: role specs live in `2-mind/forge/role/<name>/`
  (canonical) and are exposed at harness-native paths
  (`.claude/agents/<name>.md` etc.). Subagent harness memory is T0.
  Heavy passes (`dream`, `audit`) should run as a **forked subagent**
  so the main session's cache prefix stays intact.

## Read order at session-start

**Canonical home for the hot read order.** `AGENTS.md §Reading order`
mirrors it; `init`/`session-start` cite *this* list.

Hot load (every full session start, in sequence):

1. `AGENTS.md` — operational card (entry + hot order + T1/T2 line)
2. `3-control/foundation/SOUL.md` — canonical identity
3. `2-mind/garden/essential/USER.md` — semantic person-model
4. `2-mind/garden/essential/NEXT.md` — working buffer (consume + clear)
5. `2-mind/garden/essential/journal/<most-recent>.md` — continuity
   (skip if >30 days old)

Progression: **entry → identity → user → state → recent**.

Reference set (on demand, never at startup): `WORKSPACE.md`,
`3-control/foundation/PRINCIPLE.md`, this file,
`runtime-flexibility.md`, `adoption.md`, `3-control/rule/*`. Skills
cite the section they need. Not loaded: `garden/essential/SOUL.md`
(`dream` only), older journals (grep), garden `<topic>.md` (by
relevance), skills (by description match), harness memory (T0).

## 6 lifecycle skills

| Skill | When | Role |
|---|---|---|
| `init` | Once after clone (or major restructure) | Verify structure; `detect-runtime`; ratify profile.md; expose native aliases |
| `session-start` | Every session begin (`startup`); light mode on re-entry | Load hot order; drift check; consume + clear `NEXT.md`; brief |
| `session-end` | Every session close | Journal entry + `NEXT.md` block; chain `dream` for substantive sessions |
| `dream` | Chained, mid-session triggers, or `/dream` | **R1 primary enforcer**; replay journal + T0 inbox → T1; reconsolidate on retrieval; propose T2 graduations |
| `audit` | Monthly, limit-breach, or `/audit` | One canonical home + use-driven pruning; **R1/R3/R5 backstop**; metrics line; audit-log |
| `detect-runtime` | From `init`, `session-start`, or `/detect-runtime` | Detect (harness, backend, model_class); recommend tier |

Detail per skill at `2-mind/forge/act/skill/<name>/SKILL.md`.

## Dual-store identity graduation pipeline

```
session → journal (episodic) → dream → garden/essential/SOUL.md (T1 working)
       → dream, periodic → 3-control/foundation/SOUL.md (T2, Owner-ratified)
```

On ratify the source entry is marked `[graduated YYYY-MM-DD →
3-control/foundation/SOUL.md]` and moved to *Graduated* (R3 trail).

## Cross-runtime continuity

Memory stores are **workspace-canonical** — written to and read from
the repo, not runtime cache. Sessions in Claude Code, Codex CLI, and
Antigravity CLI share the same `USER.md`, `NEXT.md`, and `journal/`
(entries distinguished by `<runtime>` tag). Every harness reads
`AGENTS.md` (natively or via its fallback file) and from there the hot
read order.

## References

Cognitive theory: Schacter & Tulving 1994 *Memory Systems*; Tulving
1972; Baddeley 2000 *TiCS* 4(11); Conway 2005 *JML* 53(4); McGaugh 2000
*Science* 287; Miller 1956; Ebbinghaus 1885; Loftus & Palmer 1974;
Johnson, Hashtroudi & Lindsay 1993.

LLM-agent systems:
- Hermes Agent (Nous Research): <https://hermes-agent.nousresearch.com/docs/>
- Letta MemFS (git-backed markdown memory): <https://docs.letta.com/concepts/memfs>
- Claude Code memory & auto memory: <https://code.claude.com/docs/en/memory>
- Reflexion (Shinn 2023): <https://arxiv.org/abs/2303.11366>; MemGPT (Packer 2023): <https://arxiv.org/abs/2310.08560>
- Generative Agents (Park 2023): <https://arxiv.org/abs/2304.03442>; Mem0 (2024): <https://arxiv.org/abs/2504.19413>; A-MEM (Xu 2025): <https://arxiv.org/abs/2502.12110>
- Auto-Dreamer (2026): <https://arxiv.org/abs/2605.20616>; Human-Inspired Memory Architecture (2026): <https://arxiv.org/abs/2605.08538>
- Context rot (Chroma 2025): <https://research.trychroma.com/context-rot>; AGENTS.md evaluation (ETH 2026): <https://arxiv.org/abs/2602.11988>
