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
| Semantic person | `2-mind/garden/essential/USER.md` (tier-capped, see R1) | T1 | Conway external person-schema |
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

Every store has a capacity bound. Reaching it triggers in-place
consolidation (merge near-duplicates / drop superseded entries),
never write-rejection. Regular replay via `learn` consolidates
independently of size pressure.

**Rationale — runtime context budget.** The 7-item session-start
load runs every session; cumulative size must fit the runtime's
*effective* context window. Local LLMs are the binding constraint: a
Llama 3.1 8B advertises 128K but the needle-in-haystack cliff lands
near 8-16K tokens — content past that is loaded but not reliably
attended to. Hosted LLMs (Claude / GPT / Gemini) have far more
headroom; their constraint is prompt-cache stability, not raw size.

The caps that fit runtime budget also align with cognitive theory
(McGaugh replay-driven consolidation, Miller 7±2, Ebbinghaus decay)
— numbers are runtime-driven, discipline is theory-grounded.

#### Two cap classes

- **Memory caps** (use-grown — hard, enforced by `learn` /
  consolidate-on-error): `USER.md`, `NEXT.md`, journal entries,
  `garden/<topic>.md`. Tier-dependent (table below).
- **Spec caps** (Owner-curated, growth-by-edit — advisory flags only,
  reported by `audit`): `AGENTS.md`, `WORKSPACE.md`, `PRINCIPLE.md`,
  canonical `SOUL.md`, `use-driven-memory.md`. Fixed numbers.

#### Memory caps by runtime tier

| Tier | USER (hard/consol) | NEXT | journal/<entry> | garden/<topic> flag | Target runtime |
|---|---|---|---|---|---|
| **lean** | 60 / 50 | 20 | 100 soft | 200 | local 7-13B (Llama 3.1 8B, Qwen 2.5 7B, Mistral 7B); ≤16K effective |
| **standard** | 100 / 80 | 30 | 200 soft | 300 | local 30B-70B / hosted-modest (Haiku, GPT-4o-mini) |
| **extended** | 200 / 160 | 50 | 400 soft | 500 | hosted-large (Claude Sonnet/Opus, GPT-4, Gemini Pro) |

Session-start budgets: **lean ≈ 15K · standard ≈ 19K · extended ≈ 29K tokens**.

**Mixed-runtime rule**: pick the **most constrained** active tier
across runtimes sharing the workspace. Constrained writes are always
readable by extended sessions; the reverse silently overflows.

#### Spec caps (advisory flags)

| File | Flag at |
|---|---|
| `AGENTS.md` | 80 lines (entry doc — keep terse) |
| `WORKSPACE.md` | 200 lines |
| `PRINCIPLE.md` | 250 lines |
| `SOUL.md` (canonical) | 100 lines (Hermes-style sectioned) |
| `use-driven-memory.md` | 300 lines |

Working `SOUL.md` (in garden): no cap; *Graduated* section pruned by
`audit` once ≥30 entries.

#### Active tier selection

Stored at `3-control/runtime/profile.md` (T2 — Owner-ratified at
`init`, re-ratify on runtime change). `learn` and `audit` read it
for active caps. Default if absent: `lean` (safe floor).

### R2 — Writes settle between sessions

Memory writes appear in the **next session's** loaded context, never
the current one. This:
- Preserves prompt-cache stability (no mid-session cache thrash)
- Mirrors sleep consolidation (writes settle during quiescence)
- Prevents the agent from reacting to its own just-written claims

Agent writes to T1 stores any time during a session (typically via
`session-end` and `learn`); the *loaded-context effect* manifests
only at the next `session-start`.

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
The working store is **not** loaded at session-start — `learn` reads
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
- `garden/essential/SOUL.md` (working observations — `learn` only)
- Older journal entries (search via grep when needed)
- garden `<topic>.md` content (loaded by relevance)
- skills (invoked by description match)

## 5 lifecycle skills

| Skill | When | Role |
|---|---|---|
| `init` | Once after clone (or major restructure) | Workspace bootstrap — verify structure + detect runtime + propose tier profile |
| `session-start` | Every session begin | Load 7-item read order; consume + clear `NEXT.md` |
| `session-end` | Every session close | Write journal entry + fresh `NEXT.md`; chain `learn` for substantive sessions |
| `learn` | Chain from `session-end`, mid-session triggers, or `/learn` | Consolidation pass (R1): distill journal → T1 writes; propose T2 graduations |
| `audit` | Monthly, limit-breach, or `/audit` | Periodic maintenance: 6-class scan + archival of journal entries >3 months |

Detail per skill at `2-mind/forge/act/skill/<name>/SKILL.md`.

## Dual-store identity graduation pipeline

```
session                learn skill            periodic Owner review
   ↓                       ↓                          ↓
journal entries  →   garden/essential/SOUL.md  →  3-control/foundation/SOUL.md
(episodic)           (T1 working observations)     (T2 canonical, Owner-ratified)
```

1. **Session**: agent observes Owner-stance signals → records in
   journal entry's *Owner-signals* section.
2. **`learn`**: distills signals from journals into
   `garden/essential/SOUL.md` *Observations* / *Owner-signals* (T1).
3. **`learn`, periodic**: agent proposes promising observations as
   `3-control/foundation/SOUL.md` diffs; Owner ratifies per item.
4. **On ratify**: change lands in canonical; the source entry gets
   marked `[graduated YYYY-MM-DD → 3-control/foundation/SOUL.md]` and
   moves to *Graduated* section (R3 source trail preserved).

## Bounded growth + archival

| Store | Discipline |
|---|---|
| `USER.md` | tier-dependent hard cap (see §R1); consolidate at 80% before append |
| `NEXT.md` | tier-dependent soft cap (see §R1); single-consumption discipline |
| journal entry | tier-dependent soft cap per entry (see §R1); no entry-count cap |
| journal/ folder | entries >3 months → `garden/archive/<YYYY-MM>/<filename>.md` via `audit` |
| `garden/essential/SOUL.md` | no hard cap; *Graduated* section pruned by `audit` for >6 month old graduations |
| garden `<topic>.md` | tier-dependent flag-only threshold (see §R1); `audit` consolidates near-duplicates |
| canonical `SOUL.md` / `PRINCIPLE.md` | spec-cap advisory flags (see §R1); Owner-curated cadence |

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
