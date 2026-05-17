# Use-driven memory

Cognitive-architecture spec for workspace.md auto-growth. Grounds the
*use-driven evolution* core design value in established memory theory
and gives it operational machinery.

## Scope

workspace.md specifies the **file scaffold** for the Memory System
building block of a self-growing-agent stack. Out of scope (runtime /
training concerns deliberately not modeled): Optimizer (fine-tuning,
exploration), Environment & Feedback (LLM-as-judge, reward systems).
The workspace provides the files; the runtime drives the loop.

## 7 memory stores + cognitive analogs

| Store | Location | Tier | Cognitive analog |
|---|---|---|---|
| Self canonical | `3-control/foundation/SOUL.md` | T2 | Conway core self-schema |
| Self working | `2-mind/garden/essential/SOUL.md` | T1 | Conway working-self observations |
| Semantic person | `2-mind/garden/essential/USER.md` (≤100 lines) | T1 | Conway external person-schema |
| Working buffer | `2-mind/garden/essential/NEXT.md` (single-consumption) | T1 | Baddeley 2000 episodic buffer |
| Episodic | `2-mind/garden/essential/journal/<YYYY-MM-DD>-<runtime>-<NNN>.md` | T1 | Tulving 1972 episodic store |
| Semantic domain | `2-mind/garden/` (whole folder; sub-org per lazy-structure) | T1 | Tulving semantic store |
| Procedural | `2-mind/forge/` (whole layer) | T1 | Schacter & Tulving 1994 procedural |

Garden functions as the agent's declarative memory in full
(semantic + episodic + working); `essential/` is the bounded
fast-access portion. Forge functions as procedural memory — agent
autonomously creates new skills, scripts, role specs, triggers when
patterns recur. The runtime's turn-by-turn transcript (e.g., Claude
Code's session SQLite) plays the role of pre-consolidation
hippocampal trace — searched on demand, not loaded at session-start.

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

Every store has a capacity bound. Reaching the bound triggers
in-place consolidation (merge near-duplicates / drop superseded
entries) rather than rejecting writes. Regular replay via the `learn`
skill consolidates independently of size pressure.

**Primary rationale — runtime context budget.** The 7-item session-
start read order (see below) loads on every session. Cumulative size
must fit the runtime's effective context window. Local LLMs are the
binding constraint: a Llama 3.1 8B advertises 128K context but the
needle-in-haystack quality cliff lands around 8-16K tokens. Past
that, content is loaded but not reliably attended to — worse than
not loading. Hosted LLMs (Claude / GPT / Gemini) have far more
headroom; their constraint is prompt-cache stability rather than
absolute size.

**Convergent cognitive grounding.** The same caps that match runtime
budget also match cognitive theory: McGaugh consolidation
(hippocampus → cortex via replay), Miller 1956 7±2 working-memory
capacity, Ebbinghaus forgetting curve. The numbers are runtime-driven;
the *discipline* is theory-grounded.

#### Two cap classes

- **Memory caps** (use-grown — enforced hard by `learn` /
  consolidate-on-error): `USER.md`, `NEXT.md`, journal entries,
  `garden/<topic>.md`. Values depend on runtime tier (table below).
- **Spec caps** (Owner-curated, growth-by-edit — advisory flags only,
  reported by `audit`): `AGENTS.md`, `WORKSPACE.md`, `PRINCIPLE.md`,
  canonical `SOUL.md`, `use-driven-memory.md`. Numbers fixed (not
  runtime-dependent — these are Owner-authored, not use-grown).

#### Runtime tiers (memory caps)

| Tier | USER (hard / consol-at) | NEXT | journal/<entry> | garden/<topic> flag | Target runtime |
|---|---|---|---|---|---|
| **lean** | 60 / 50 | 20 | 100 soft | 200 | local 7-13B (Llama 3.1 8B, Qwen 2.5 7B, Mistral 7B class); sub-16K effective context |
| **standard** | 100 / 80 | 30 | 200 soft | 300 | local 30B-70B (Llama 70B, Mixtral, Qwen 32B+) / hosted-modest (Claude Haiku, GPT-4o-mini) |
| **extended** | 200 / 160 | 50 | 400 soft | 500 | hosted-large (Claude Sonnet/Opus, GPT-4, Gemini Pro 1M) |

Session-start budget per tier (memory + Owner-curated spec docs):
**lean ≈ 15K tokens · standard ≈ 19K · extended ≈ 29K**.

**Mixed-runtime rule**: if multiple runtimes share a workspace (e.g.,
Claude Code + local Ollama), select the **most constrained** active
tier. Writes from constrained sessions are always readable by extended
sessions; the reverse silently overflows.

#### Spec caps (advisory flags)

| File | Flag at | Notes |
|---|---|---|
| `AGENTS.md` | 80 lines | entry doc — keep terse |
| `WORKSPACE.md` | 200 lines | topology spec |
| `PRINCIPLE.md` | 250 lines | principles |
| `SOUL.md` (canonical) | 100 lines | Hermes-style sectioned |
| `use-driven-memory.md` | 300 lines | architecture detail |

Working `SOUL.md` (in garden): no cap; *Graduated* section pruned by
`audit` once ≥30 entries.

#### Active tier selection

Stored at `3-control/runtime/profile.md` (T2 — Owner-ratified at
`init` time, re-ratify on runtime change). `learn` and `audit` read
this file to look up applicable caps. Default if `profile.md`
absent: `lean` (safe floor).

### R2 — Writes settle between sessions

All memory writes appear in the **next session's** loaded context,
not the current one. This:
- Preserves prompt-cache stability (no mid-session cache thrash)
- Mirrors biological sleep consolidation (writes "settle" during
  quiescence)
- Prevents the agent from reacting to its own just-written claims
  mid-session

The agent may write to T1 stores at any time during a session
(typically via `session-end` and `learn` skills); the *effect* on
loaded context only manifests at the next `session-start`.

*Theory*: sleep-boundary consolidation in standard model of
declarative memory.

### R3 — Verbatim episodic, synthesized semantic

Episodic stores preserve **verbatim** records: each journal entry has
a timestamp, runtime tag, and source citations back to the session's
commits / decisions. Semantic stores (`USER.md`, garden `<topic>.md`,
foundation docs) hold **synthesized** content, each item with explicit
citation back to the source journal entry it derives from (format:
`(journal <YYYY-MM-DD-runtime-NNN>)`).

This source-monitoring discipline prevents attribution errors and
LLM-hallucination-from-compression. A synthesized claim is always
traceable back to its raw observation.

*Theory*: Loftus 1974 reconstructive memory + misinformation effect;
Johnson 1993 source monitoring framework.

### R4 — Two-tier authority with mirrored identity

T1 / T2 split (above). Identity content uses **dual-store**: the
agent's working observations (`garden/essential/SOUL.md`, T1)
accumulate freely; canonical identity (`3-control/foundation/SOUL.md`, T2) only
updates via Owner-ratified graduation proposals from the working
store. The working store is NOT loaded at session-start — it's read
only by the `learn` skill when preparing graduation proposals.

This mirrors Conway's self-memory system: the working self
(observations, contextual) is distinct from the core self (stable,
protected), and the working self proposes updates to the core only
through deliberate consolidation.

*Theory*: Conway self-memory system; Hermes Agent verbatim SOUL.md
contract (relaxed: we permit T2-ratified updates).

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

| Skill | When | Reads | Writes | Role |
|---|---|---|---|---|
| `init` | Once after clone or recreation | WORKSPACE, AGENTS (structure verify) | Modifies template seeds (NOT create); records runtime detection | Workspace bootstrap |
| `session-start` | Every session begin | 7-item read order | Clears NEXT.md after consuming | Load working context |
| `session-end` | Every session close | Transcript + git diff/log | journal/<new-entry>.md; NEXT.md (fresh) | Episodic trace + handoff |
| `learn` | Chain from session-end OR mid-session triggers (≥5 tool calls / error recovery / Owner correction / novel workflow) OR `/learn` | Today's journal entry + prior 1-2 entries; garden/essential/SOUL.md | T1 (autonomous): USER.md, garden/essential/SOUL.md, garden/<topic>.md, new skills/scripts in forge/. T2 (propose-ratify): 3-control/foundation/SOUL.md, 3-control/foundation/PRINCIPLE.md, 3-control/rule/ | Consolidation pass (R1) |
| `audit` | Monthly OR limit breach OR `/audit` | All of 2-mind/ (garden + forge) + 3-control/ (6 issue classes) | T1 (direct): archive journal entries >3 months → garden/archive/<YYYY-MM>/; consolidate within 2-mind/. T2 (propose): 3-control/ changes. Writes garden/audit-log.md | Periodic maintenance (Ebbinghaus pruning) |

## Dual-store identity graduation pipeline

```
session                  learn skill               periodic Owner review
   ↓                          ↓                            ↓
journal entries     →   garden/essential/SOUL.md  →  3-control/foundation/SOUL.md
(episodic events)       (T1 working observations)     (T2 canonical, Owner-
                                                       ratified)
```

1. **Session**: agent observes Owner-stance signals → journal entry
   `Owner-signals` section.
2. **`learn` skill**: distills Owner-signals from journal entries into
   `garden/essential/SOUL.md` *Observations* / *Owner-signals*
   sections. T1 autonomous.
3. **Periodic (also via `learn`)**: agent proposes promising
   observations as `3-control/foundation/SOUL.md` diffs. Owner ratifies per item.
4. **On ratify**: change lands in `3-control/foundation/SOUL.md`; the
   `garden/essential/SOUL.md` entry gets marked
   `[graduated YYYY-MM-DD → 3-control/foundation/SOUL.md]` and moves to
   *Graduated* section (kept for source-monitoring trail per R3).

## Bounded growth + archival

| Store | Discipline |
|---|---|
| `USER.md` | 100 lines hard; consolidate at 80 lines before append |
| journal entries | 30–200 lines soft per entry; no entry-count cap |
| journal/ folder | entries >3 months → `garden/archive/<YYYY-MM>/<filename>.md` via `audit` |
| `garden/essential/SOUL.md` | no hard cap; *Graduated* section pruned by `audit` for >6 month old graduations |
| garden `<topic>.md` | no fixed cap; `audit` consolidates near-duplicates |
| canonical `SOUL.md` / `PRINCIPLE.md` | no caps; Owner-curated cadence |

Archival is **not deletion** — old journal entries move to
`garden/archive/` and remain searchable (grep), just not auto-loaded
at session-start. Preserves source-monitoring trail (R3).

## Cross-runtime continuity

All memory stores are **workspace-canonical**: written to / read from
the repo, not runtime cache. A session in Claude Code, the next in
Codex CLI, the third in Gemini CLI all read and write the same
`garden/essential/USER.md`, `NEXT.md`, and `journal/` (entries
distinguished by `<runtime>` tag in filename).

Per-runtime auto-loaded context (Claude Code's `CLAUDE.md`, Codex's
`AGENTS.md`, Gemini's `GEMINI.md` symlinks) all point at the workspace
`AGENTS.md`. From there, the agent reads the 7-item read order
regardless of runtime.

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
