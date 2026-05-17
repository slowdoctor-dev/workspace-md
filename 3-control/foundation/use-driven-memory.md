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
| Working buffer | `2-mind/garden/essential/NEXT.md` (single-consumption) | T1 | Baddeley 2000 episodic buffer |
| Episodic | `2-mind/garden/essential/journal/<YYYY-MM-DD>-<runtime>-<NNN>.md` | T1 | Tulving 1972 episodic store |
| Semantic domain | `2-mind/garden/` (whole folder; sub-org per lazy-structure) | T1 | Tulving semantic store |
| Procedural | `2-mind/forge/` (whole layer) | T1 | Schacter-Tulving 1994 procedural |

Garden = declarative memory in full (semantic + episodic + working);
`essential/` is the bounded fast-access portion. Forge = procedural
memory; agent creates new skills, scripts, role specs, triggers when
patterns recur.

The runtime's turn-by-turn transcript (e.g., Claude Code's session
SQLite) plays the role of pre-consolidation hippocampal trace —
searched on demand, not loaded at session-start.

## 2 write-tiers

- **T1 — agent autonomous within capacity**: `2-mind/garden/`
  (declarative memory) + `2-mind/forge/` (procedural memory). Agent
  writes without ratification, bounded by per-store capacity rules
  (R1).
- **T2 — agent-proposes, Owner-ratifies**: all of `3-control/` —
  `foundation/` (canonical identity + operating principles +
  architecture detail), `rule/` (enforceable rules), `external/`
  (MCP/OpenAPI/webhook configs), `runtime/` (local LLM adapters) —
  plus `2-mind/atelier/` when content exists (Owner-stance bin;
  optional). Agent presents a diff; Owner accepts per item.

There is no T3 (Owner-only-no-touch). Even canonical SOUL.md (T2)
permits agent-proposed graduations; the firewall is *ratification*,
not *no-touch*.

**Tier-by-location heuristic**: 2-mind/garden/ + 2-mind/forge/ = T1;
3-control/ + 2-mind/atelier/ = T2. Folder location answers "do I need
to ratify?" — atelier is the one exception that crosses the 2-mind/3-
control boundary (it is Owner-stance content placed inside the mind
layer for cultivation-craft adjacency).

## 4 operating rules

### R1 — Consolidation under capacity

Every store has a capacity bound rooted in cognitive usability —
how much content a memory store can hold before it stops *being*
memory (scan-ability drops, signal dilutes in noise, near-duplicates
accumulate). Reaching the bound triggers in-place consolidation
(merge near-duplicates / drop superseded entries), never
write-rejection. Regular replay via `dream` consolidates
independently of size pressure.

R1 caps are **runtime-independent** — they describe what makes a
store usable *as memory*, not what fits a particular runtime.
Runtime-tier adjustment is R2's concern.

#### Two cap classes

- **Memory caps** (use-grown — hard, enforced by `dream` /
  consolidate-on-error): `USER.md`, `NEXT.md`, journal entries,
  `garden/<topic>.md`.
- **Spec caps** (Owner-curated, growth-by-edit — advisory flags
  only, reported by `audit`): `AGENTS.md`, `WORKSPACE.md`,
  `PRINCIPLE.md`, canonical `SOUL.md`, `use-driven-memory.md`.

#### Natural memory caps (R1 baseline)

| Store | Hard cap | Consolidate at | Cognitive rationale |
|---|---|---|---|
| `USER.md` | 100 lines | 80 | ~10 × Miller-chunked categories (≈ 7±2 entries per § Preferences / § Patterns / § Tells × 3 sections), with 30-line headroom for section headers + new entries before next consolidate trigger |
| `NEXT.md` | 30 lines soft | n/a (single-consumption) | one screen worth — agent should read it without scrolling; handoff, not journal |
| journal entry | 200 lines soft per entry | n/a (per-entry shape) | ~one session's decisions + learnings at human reading pace (8–10 min); long enough for substantive content, short enough to skim |
| garden `<topic>.md` | flag at 300 lines | split or consolidate | single subject still cohesive without internal sectioning; past 300 → split into `<topic>/<sub>.md` |

Working `SOUL.md` (in garden): no cap; *Graduated* entries older
than 6 months pruned by `audit` (source-trail discipline per R3).

*Theory*: McGaugh consolidation (hippocampus → cortex via replay);
Miller 1956 7±2 working-memory capacity; Ebbinghaus forgetting curve.

The numbers are *defensibly grounded* but not *empirically validated*
— this is a pre-stable spec; first real adopter workloads will
surface whether the natural caps need adjustment.

#### Spec caps (advisory flags)

| File | Flag at |
|---|---|
| `AGENTS.md` | 80 lines (entry doc — keep terse) |
| `WORKSPACE.md` | 200 lines |
| `PRINCIPLE.md` | 250 lines |
| `SOUL.md` (canonical) | 100 lines (Hermes-style sectioned) |
| `use-driven-memory.md` | 300 lines |
| `runtime-flexibility.md` | 200 lines |

These are growth-by-edit, not use-grown — flag for Owner review
when exceeded; never auto-consolidated.

### R2 — Session-boundary discipline

The session boundary is the workspace's sync point. Two parts:

#### Part A — Writes settle between sessions

Memory writes appear in the **next session's** loaded context, never
the current one. This:
- Preserves prompt-cache stability (no mid-session cache thrash)
- Mirrors sleep consolidation (writes settle during quiescence)
- Prevents the agent from reacting to its own just-written claims

Agent writes to T1 stores any time during a session (typically via
`session-end` and `dream`); the *loaded-context effect* manifests
only at the next `session-start`.

#### Part B — Session-start load fits runtime budget

The 7-item session-start load must fit the runtime's *effective*
context. "Runtime" is a pair (harness, backend); tier is driven by
backend `effective_context`. See
`3-control/foundation/runtime-flexibility.md` for the full mechanism
— two-axis framing, three patterns, tier system + derivation rule,
detection procedure, graceful degradation, freshness discipline.

Quick reference: `lean` for ≤16K effective; `standard` 16-64K
(= R1 baseline); `extended` >64K hosted-large. Default if
`profile.md` absent: `standard`.

*Theory*: sleep-boundary consolidation in the standard model of
declarative memory.

### R3 — Verbatim episodic, synthesized semantic

Episodic stores (journal entries) preserve **verbatim** records with
timestamp, runtime tag, and citations to the session's commits and
decisions. Semantic stores (`USER.md`, garden `<topic>.md`, foundation
docs) hold **synthesized** content; each item carries an explicit
citation back to its source journal entry in the form
`(journal <YYYY-MM-DD-runtime-NNN>)`.

A synthesized claim is always traceable to its raw observation. This
prevents source-attribution errors and compression-driven drift.

*Theory*: Loftus 1974 reconstructive memory + misinformation effect;
Johnson 1993 source monitoring framework.

### R4 — Two-tier authority with mirrored identity

T1 / T2 as above. Identity content uses **dual-store**: the agent's
working observations (`garden/essential/SOUL.md`, T1) accumulate
freely; canonical identity (`3-control/foundation/SOUL.md`, T2)
updates only via Owner-ratified graduation from the working store.
The working store is **not** loaded at session-start — `dream` reads
it only when preparing graduation proposals.

This mirrors Conway's self-memory system: the working self
(contextual, observational) is distinct from the core self (stable,
protected), and updates the core only through deliberate consolidation.

*Theory*: Conway self-memory system; Hermes Agent verbatim-SOUL
contract (relaxed here to permit T2-ratified updates).

## Read order at session-start

Loaded into the agent's prompt in this sequence:

1. `AGENTS.md` — workspace entry + per-runtime mapping
2. `WORKSPACE.md` — topology spec
3. `3-control/foundation/PRINCIPLE.md` — operating principles
4. `3-control/foundation/SOUL.md` — canonical identity
5. `2-mind/garden/essential/USER.md` — semantic person-model
6. `2-mind/garden/essential/NEXT.md` — working buffer (consume + clear)
7. `2-mind/garden/essential/journal/<most-recent>.md` — recent-session continuity

Progression: **spec → principle → identity → user → state → recent**.

Not loaded at session-start (read on demand):
- `garden/essential/SOUL.md` (working observations — `dream` only)
- Older journal entries (search via grep when needed)
- garden `<topic>.md` content (loaded by relevance)
- skills (invoked by description match)

## 6 lifecycle skills

| Skill | When | Role |
|---|---|---|
| `init` | Once after clone (or major restructure) | Workspace bootstrap — verify structure; invoke `detect-runtime`; ratify profile.md |
| `session-start` | Every session begin | Load 7-item read order; invoke `detect-runtime` for drift check; consume + clear `NEXT.md` |
| `session-end` | Every session close | Write journal entry + fresh `NEXT.md`; chain `dream` for substantive sessions |
| `dream` | Chain from `session-end`, mid-session triggers, or `/dream` | Sleep-consolidation pass — **R1 primary enforcer** (consolidate-on-error at write-time); replay journal → T1 writes; propose T2 graduations |
| `audit` | Monthly, limit-breach, or `/audit` | General-purpose maintenance — cross-cutting enforcement: One canonical home (duplicates/contradictions/orphans), Use-driven evolution (low-utility prune + journal archival), **R1 backstop** (over-grown scan), R3 source-trail |
| `detect-runtime` | From `init`, `session-start`, or `/detect-runtime` | Detect (harness, backend, effective_context); derive recommended tier per `runtime-flexibility.md` rule |

Detail per skill at `2-mind/forge/act/skill/<name>/SKILL.md`.

## Dual-store identity graduation pipeline

```
session                dream skill            periodic Owner review
   ↓                       ↓                          ↓
journal entries  →   garden/essential/SOUL.md  →  3-control/foundation/SOUL.md
(episodic)           (T1 working observations)     (T2 canonical, Owner-ratified)
```

1. **Session**: agent observes Owner-stance signals → records in
   journal entry's *Owner-signals* section.
2. **`dream`**: distills signals from journals into
   `garden/essential/SOUL.md` *Observations* / *Owner-signals* (T1).
3. **`dream`, periodic**: agent proposes promising observations as
   `3-control/foundation/SOUL.md` diffs; Owner ratifies per item.
4. **On ratify**: change lands in canonical; the source entry gets
   marked `[graduated YYYY-MM-DD → 3-control/foundation/SOUL.md]` and
   moves to *Graduated* section (R3 source trail preserved).

## Bounded growth + archival

| Store | Discipline |
|---|---|
| `USER.md` | R1 natural cap 100 hard / consolidate at 80; R2 tier-adjusted |
| `NEXT.md` | R1 natural cap 30 soft; R2 tier-adjusted; single-consumption |
| journal entry | R1 natural cap 200 soft per entry; R2 tier-adjusted; no entry-count cap |
| journal/ folder | entries >3 months → `garden/archive/<YYYY-MM>/<filename>.md` via `audit` |
| `garden/essential/SOUL.md` | no hard cap; *Graduated* entries >6 months pruned by `audit` |
| garden `<topic>.md` | R1 flag at 300 lines; R2 tier-adjusted; `audit` consolidates near-duplicates |
| canonical `SOUL.md` / `PRINCIPLE.md` | R1 spec-cap advisory flags (runtime-independent); Owner-curated cadence |

Archival is **not deletion** — old journal entries move to
`garden/archive/` and remain searchable (grep), just not auto-loaded
at session-start. Preserves source-monitoring trail (R3).

## Cross-runtime continuity

Memory stores are **workspace-canonical** — written to and read from
the repo, not runtime cache. Sessions in Claude Code, Codex CLI, and
Gemini CLI all share the same `garden/essential/USER.md`, `NEXT.md`,
and `journal/` (entries distinguished by `<runtime>` tag in filename).
Each runtime's auto-loaded instruction file (`CLAUDE.md`, `AGENTS.md`,
`GEMINI.md` — symlinks at repo root) points at the workspace
`AGENTS.md`, from which the agent reads the 7-item order regardless
of runtime.

## References

Cognitive theory:
- Schacter, D. L., & Tulving, E. (1994). *Memory Systems 1994*. MIT Press.
- Tulving, E. (1972). "Episodic and semantic memory." In E. Tulving & W. Donaldson (eds.), *Organization of Memory*.
- Baddeley, A. D. (2000). "The episodic buffer: a new component of working memory?" *Trends in Cognitive Sciences* 4(11).
- Conway, M. A. (2005). "Memory and the self." *Journal of Memory and Language* 53(4).
- McGaugh, J. L. (2000). "Memory — a century of consolidation." *Science* 287.
- Miller, G. A. (1956). "The magical number seven, plus or minus two." *Psychological Review* 63(2).
- Ebbinghaus, H. (1885). *Über das Gedächtnis*.
- Loftus, E. F., & Palmer, J. C. (1974). "Reconstruction of automobile destruction." *Journal of Verbal Learning and Verbal Behavior* 13.
- Johnson, M. K., Hashtroudi, S., & Lindsay, D. S. (1993). "Source monitoring." *Psychological Bulletin* 114(1).

LLM-agent systems:
- Hermes Agent (Nous Research): <https://hermes-agent.nousresearch.com/docs/>
- Anthropic Auto Dream: <https://claudefa.st/blog/guide/mechanics/auto-dream>
- Reflexion (Shinn et al., 2023): <https://arxiv.org/abs/2303.11366>
- MemGPT / Letta (Packer et al., 2023): <https://arxiv.org/abs/2310.08560>
- Generative Agents (Park et al., 2023): <https://arxiv.org/abs/2304.03442>
- Mem0 (2024): <https://arxiv.org/abs/2504.19413>
- A-MEM (Xu, 2025): <https://arxiv.org/abs/2502.12110>
