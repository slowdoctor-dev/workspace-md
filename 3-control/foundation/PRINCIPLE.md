# Operating principles

Principles that guide how this workspace operates. Distinct from rules
(`../rule/`) that constrain specific actions: principles shape
judgment, rules constrain action.

Two sections — **core design values** (the philosophy behind the
workspace.md pattern, runtime-independent) and **operational
principles** (how to operate each layer in day-to-day work).

---

## Core design values

These describe *why* the workspace.md pattern is shaped the way it is.
Runtime-independent. Each value below states its core goal first,
then the mechanism that enables it.

### Use-driven evolution *(coined by this spec)*

**The core goal**: the workspace accumulates value with use. Each
session leaves behind durable assets so the next session knows more,
automates more, requires less re-explanation. Use compounds usability.

Sessions deposit declarative knowledge into `2-mind/garden/`,
procedural skills into `2-mind/forge/`, constraints and orientation
into `3-control/`. An unused workspace grows nothing.

Operationalized by a cognitive-architecture memory spec — 7 stores +
2 write-tiers (T1 / T2) + 4 operating rules (R1–R4) + 5 lifecycle
skills — grounded in Schacter-Tulving, Conway, Baddeley, McGaugh,
Miller, Ebbinghaus, Loftus, Johnson. Detail:
`3-control/foundation/use-driven-memory.md`.

### Separability *(general SW vocabulary; framing here is spec-specific)*

**The core goal**: the workspace works as intended regardless of which
runtime is brought in. Swap Claude Code for Codex CLI, Codex CLI for
Gemini CLI, or point a hosted CLI at a local LLM — the workspace's
content, identity, and operating discipline carry over unchanged.
Separability is what turns "LLM-agnostic" from a label into an
operational property.

Content tightly tied to one runtime (settings, permissions,
runtime-specific hooks) lives at that runtime's native location.
Content that exists independently of any specific runtime — MCP
server lists, OpenAPI specs, webhook configs, business rules,
documents, agent personas — lives runtime-independently in
`3-control/external/`, `2-mind/`, etc.

### Lazy structure *(borrowed from programming "lazy evaluation"; application to directory topology proposed by this spec)*

**The core goal**: structure follows actual content, not anticipated
content. The spec accommodates growth rather than predicting it,
avoiding premature classification overhead.

Subfolders are created on the *second* occurrence of a content kind,
not preemptively.

### One canonical home *(adapted from DRY; "canonical home" phrasing proposed by this spec)*

**The core goal**: every piece of content has one source of truth so
the workspace can grow without drift.

Each rule, each external resource, each operating principle has
exactly one canonical location. Cross-domain references link directly
to the canonical path. Content that legitimately bridges multiple
categories splits into separate pages; the spec forbids duplication.

### Native conventions where they exist; neutral where they don't *(framing proposed by this spec)*

**The core goal**: minimize friction with runtimes. Use what runtimes
already provide; invent convention only where no native exists.

`.claude/`, `.codex/`, `.gemini/` are used directly at the workspace
root. The spec only invents convention (`3-control/runtime/<name>/`)
where the runtime offers none (Ollama, LM Studio, MLX).

### Open standard ethos *(general open-standards practice; AAIF-alignment cited)*

**The core goal**: workspace.md is one approach among many —
forkable, extensible, AAIF-aligned. No claim of universality.

Sibling to agents.md. Proposed conventions are marked as such;
borrowed ones are cited.

---

## Operational principles

### Per-layer operation

**0-storage/** [mandated] — General file storage. LLM-passive —
binary assets, archives, received files, original media. Internal
structure free-form; no spec discipline applies inside. The LLM may
reference paths but does not treat contents as primary working
material.

**1-active/** [mandated] — Disposable working space. Drafts, scratch,
work-in-progress. Graduate to `2-mind/` if it matters to keep.

**2-mind/** [mandated] — Agent-managed memory layer (T1). Three
sub-folders: atelier (optional Owner-stance bin — outside the
Schacter-Tulving taxonomy), garden (declarative memory: semantic +
episodic + working), forge (procedural memory). Garden + forge map
to Schacter-Tulving 1994 declarative vs procedural distinction. The
three are cultivation crafts side by side — Owner cultivates identity
in atelier, agent grows knowledge in garden, agent forges skills in
forge.

**2-mind/atelier/** (optional) — Owner-stance bin (T2 if content
exists). For non-canonical Owner-authored stance content — brand,
persona, voice, declared values not yet promoted to canonical
foundation. Loses mandated status because canonical identity now
lives in `3-control/foundation/SOUL.md`.

**2-mind/garden/** [mandated] — Declarative memory: semantic +
episodic + working (T1, agent-autonomous within R1 capacity bounds).
`essential/` holds the 4 essential items (SOUL working, USER, NEXT,
journal/); freely-organized topic content (`<topic>.md`,
`<topic>/<sub>.md`) and `archive/` (aged-out journal entries) appear
lazily. Architecture detail at
`3-control/foundation/use-driven-memory.md`.

`3-control/foundation/SOUL.md` is the canonical identity (T2,
Owner-ratified, Owner-authored verbatim). Adopts the Hermes Agent
SOUL.md pattern
([personality](https://hermes-agent.nousresearch.com/docs/user-guide/features/personality),
[use-soul-with-hermes](https://hermes-agent.nousresearch.com/docs/guides/use-soul-with-hermes)):
canonical sections Identity / Style / Avoid / Defaults, extended
here with §Values. SOUL.md's own §Avoid owns the full content-type
exclusion list.

Companion working-identity store at `2-mind/garden/essential/SOUL.md`
(T1) accumulates observations awaiting Owner-ratified graduation —
dual-store pattern detailed in `use-driven-memory.md`.

**2-mind/forge/** [mandated, may be empty initially] — Procedural
memory (T1). Agent specs (`role/`), triggers (`cue/`), procedures
(`act/skill/`), deterministic code (`act/script/`). Agent
autonomously creates new skills/scripts when Hermes-style triggers
fire (≥5 tool calls / error recovery / Owner correction / novel
workflow). All sub-folders optional per lazy-structure.

**3-control/** [mandated] — Owner-curated configuration and
governance (T2). Sub-paths: `foundation/` [mandated — holds canonical
SOUL.md + PRINCIPLE.md + use-driven-memory.md], `external/` (optional,
LLM-agnostic connections like MCP), `runtime/` (optional, local LLM
adapters), `rule/` (optional, enforceable rules). All changes to
3-control/ require Owner ratification — this is the workspace's
governance boundary.

### External connections (`3-control/external/`)

LLM-agnostic external connections (MCP, OpenAPI, webhooks). The same
connection is conceptually identical regardless of which runtime
consumes it — canonical management here prevents drift across
runtimes.

MCP-specific patterns:

- **3rd-party MCP server**: registration + connection metadata only
  in `external/mcp/<runtime>.<format>`. Where format-compatible, the
  runtime's native config path symlinks here (e.g., `.mcp.json` →
  `external/mcp/registry.json`). Source code stays in upstream repo.
- **Self-owned MCP server**: source code + connection config travel
  together in `external/mcp/<server-name>/`.

(OpenAPI specs and webhook handlers follow analogous patterns under
`external/openapi/` and `external/webhook/` if used.)
