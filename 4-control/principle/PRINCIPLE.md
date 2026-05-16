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

**The core goal**: the workspace accumulates value with use — it
becomes a higher-leverage substrate the more it is used. Each
session leaves behind durable assets so the next session knows more,
automates more, and requires less re-explanation. Use compounds
usability.

Each session deposits knowledge into `2-mind/`, automation into
`3-playbook/`, constraints and orientation into `4-control/`, refined
`AGENTS.md`. A workspace that has not been used grows nothing. A
workspace used across many sessions becomes a high-leverage
substrate.

### Separability *(general SW vocabulary; framing here is spec-specific)*

**The core goal**: the workspace works as intended regardless of which
runtime is brought in. Swap Claude Code for Codex CLI, Gemini for
Claude, or point a hosted CLI at a local LLM — the workspace's
content, identity, and operating discipline carry over unchanged.
Separability is what turns "LLM-agnostic" from a label into an
operational property.

Content tightly tied to one runtime (settings, permissions,
runtime-specific hooks) lives at that runtime's native location.
Content that exists independently of any specific runtime — MCP
server lists, OpenAPI specs, webhook configs, business rules,
documents, agent personas — lives runtime-independently in
`4-control/external/`, `2-mind/`, etc.

### Lazy structure *(borrowed from programming "lazy evaluation"; application to directory topology proposed by this spec)*

**The core goal**: structure follows actual content, not anticipated
content. The spec accommodates growth rather than predicting it,
avoiding premature classification overhead.

Subfolders are created on the *second* occurrence of a content kind,
not preemptively.

### One canonical home *(adapted from DRY; "canonical home" phrasing proposed by this spec)*

**The core goal**: every piece of content has one source of truth so
the workspace can grow without drift. Cross-domain references link
directly to the canonical path.

Each rule, each external resource, each operating principle has
exactly one canonical location. Content that legitimately bridges
multiple categories splits into separate pages; the spec forbids
duplication.

### Native conventions where they exist; neutral where they don't *(framing proposed by this spec)*

**The core goal**: minimize friction with runtimes. Use what runtimes
already provide; invent convention only where no native exists.

`.claude/`, `.codex/`, `.gemini/` are used directly at the workspace
root. The spec only invents convention (`4-control/runtime/<name>/`)
where the runtime offers none (Ollama, LM Studio, MLX).

### Open standard ethos *(general open-standards practice; AAIF-alignment cited)*

**The core goal**: workspace.md is one approach among many —
forkable, extensible, AAIF-aligned. No claim of universality.

Sibling to agents.md. Proposed conventions are marked as such;
borrowed ones are cited.

---

## Operational principles

### Per-layer operation

**0-storage/** [mandated] — Raw inputs only. Received content
preserved as-received; derived assets go in `1-active/` or `2-mind/`.

**1-active/** [mandated] — Disposable working space. Drafts, scratch,
work-in-progress. Graduate to `2-mind/` if it matters to keep.

**2-mind/atelier/** [mandated] — User-authored, agent-assisted.
Owner's declared stance preserved verbatim.

`atelier/SOUL.md` is the universal canonical first file — the
workspace's animating identity. Per the Hermes Agent SOUL.md pattern
this spec generalizes from: SOUL.md is **strictly Owner-authored
verbatim** — the agent does not paraphrase, rewrite, or re-section
it. Read at session start; injected verbatim into agent context.

**2-mind/factory/** [mandated, may be empty initially] —
Agent-authored, user-audited. Synthesized observations, operational
bookkeeping, logs. The accumulation slot for use-driven evolution.

**3-playbook/** [mandated, may be empty initially] — Automation:
agent specs (`role/`), triggers (`cue/`), procedures (`act/skill/`),
deterministic code (`act/script/`). All sub-folders optional per
lazy-structure.

**4-control/** [mandated] — Configuration and governance.
Sub-paths: `principle/PRINCIPLE.md` [mandated — runtime-independent
operating discipline], `external/` (optional, LLM-agnostic connections
like MCP), `runtime/` (optional, local LLM adapters), `rule/`
(optional, enforceable rules).

### Hosted CLI attach

Hosted CLIs (Claude Code, Codex CLI, Gemini CLI) auto-discover their
native paths at the workspace root:

    <repo>/.claude/settings.json     Claude Code project settings
    <repo>/.codex/config.toml        Codex CLI project config (trust required)
    <repo>/.gemini/settings.json     Gemini CLI project settings

No symlinks, no bootstrap. Secrets stay outside the workspace
regardless of runtime.

### External connections (`4-control/external/`)

LLM-agnostic external connections. The same MCP server, OpenAPI spec,
or webhook is conceptually identical regardless of which runtime
consumes it — canonical management here prevents drift.

- **3rd-party MCP server**: registration + connection metadata only
  in `external/mcp/<runtime>.<format>`. Where format-compatible, the
  runtime's native config path symlinks here (e.g., `.mcp.json` →
  `external/mcp/registry.json`). Source code stays in upstream repo.
- **Self-owned MCP server**: source code + connection config travel
  together in `external/mcp/<server-name>/`.
