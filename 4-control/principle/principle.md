# Operating principles

Principles that guide how this workspace operates. Distinct from rules
(`../rule/`) that constrain specific actions: principles shape
judgment, rules constrain action.

Three sections — **core design values** (the philosophy behind the
workspace.md pattern, runtime-independent), **operational principles**
(how to operate each layer in day-to-day work), and **spec-evolution
principles** (for proposing changes to WORKSPACE.md itself).

---

## Core design values

These describe *why* the workspace.md pattern is shaped the way it is.
They are runtime-independent — true regardless of which LLM CLI or
local backend you attach.

### Use-driven evolution

The workspace *accumulates value with use*. Each session leaves
behind: knowledge in `2-mind/` (factory synthesis + atelier stance),
automation in `3-playbook/` (skill / script / role / cue), constraints
and orientation in `4-control/` (rule + principle), refined universal
or per-agent `AGENTS.md`, and evolved `README.md`.

Over many sessions the workspace knows more, automates more, and
requires less re-explanation. Use compounds usability.

**Universality**: every durable workspace file is in scope for
evolution and maintenance — not only the 4-layer content folders. Out
of scope: runtime-native configs (separability), forwarder symlinks,
and `WORKSPACE.md` (governed by `4-control/rule/contribution.md`).

A workspace that has not been used grows nothing. A workspace used
across many sessions becomes a high-leverage substrate.

### Separability

Content tightly tied to one runtime (settings, permissions,
runtime-specific hooks) lives at that runtime's native location;
the spec does not over-manage it.

Content that exists independently of any specific runtime — MCP server
lists, OpenAPI specs, webhook configs, business rules, documents,
agent personas — lives runtime-independently in `4-control/external/`,
`2-mind/`, etc.

### Lazy structure

Subfolders are created on the *second* occurrence of a content kind,
not preemptively. The spec accommodates growth rather than predicting
it.

### One canonical home

Each rule, each external resource, each operating principle has
exactly one canonical location. Cross-domain references link directly
to that path. Content that legitimately bridges multiple categories
splits into separate pages; the spec forbids duplication.

This is what enables `2-mind/` and `3-playbook/` accumulation without
drift — there is always a single source of truth.

### Native conventions where they exist; neutral where they don't

The spec does not fight runtime-native conventions. `.claude/`,
`.codex/`, `.gemini/` are used directly at the workspace root. The
spec only invents convention (`4-control/runtime/<name>/`) where the
runtime offers none (Ollama, LM Studio, MLX).

### Open standard ethos

One approach, not *the* approach. Sibling to agents.md, AAIF-aligned.
Proposed conventions are marked as such; borrowed ones are cited.
Forks are first-class.

---

## Operational principles

### Per-layer operation

**0-storage/** — Raw inputs only. Never edit in place. Long-term
retention; never delete casually. Source-of-truth for anything that
originated elsewhere (received documents, original media, archived
snapshots).

**1-active/** — Disposable working space. High churn, no preservation
guarantee. Drafts, scratch, in-progress work, candidate skills before
ratification. If something matters to keep, graduate it to `2-mind/`.

**2-mind/atelier/** — User-authored, agent-assisted. User's declared
stance preserved verbatim — agents may scribe, organize, cross-link,
but must not paraphrase the user's words. Brand identity, persona
definitions, principles, curated reference.

**2-mind/factory/** — Agent-authored, user-audited. Synthesized
observations, operational bookkeeping, logs, help, research synthesis.
Updated regularly without asking; audited periodically by the user.

**3-playbook/role/** — Per-agent specs. Each agent uses single-file
form (`role/<agent>.md`) or expanded subfolder form
(`role/<agent>/{AGENTS.md, rules/, ...}`) when state is non-trivial.
The tool whitelist in the agent's `AGENTS.md` is the only mechanism
for tool restriction.

**3-playbook/cue/** — Event-driven triggers (hooks, schedules, CI
workflows). Hook implementations are runtime-specific (Claude Code
hooks ≠ Gemini hooks); not portable across runtimes without rewrite.

**3-playbook/act/skill/** — Natural-language procedures. One folder
per skill containing `SKILL.md`. Agent reads and follows with judgment
along the way.

**3-playbook/act/script/** — Deterministic executable code (bash,
python, etc.). No agent judgment at runtime. Idempotent and testable
where possible.

### Runtime attachment (`4-control/runtime/`)

Workspace.md distinguishes two cases:

**Hosted CLIs with native repo-level discovery** (Claude Code, Codex
CLI, Gemini CLI) — use their native paths at workspace root directly,
NOT externalized to `4-control/runtime/`:

    <repo>/.claude/settings.json     Claude Code project settings
    <repo>/.codex/config.toml        Codex CLI project config
    <repo>/.gemini/settings.json     Gemini CLI project settings

Running the CLI at the workspace root auto-discovers these. No
symlinks, no bootstrap. (Codex CLI requires the project to be marked
trusted on first run.)

**Runtimes lacking native repo-level discovery** (Ollama, LM Studio,
MLX) — canonical lives in `4-control/runtime/<name>/`:

    4-control/runtime/ollama/Modelfile          Ollama model definition
    4-control/runtime/lmstudio/presets/*.json   LM Studio system prompts
    4-control/runtime/mlx/run.sh                MLX launch script

Bootstrap scripts in `3-playbook/act/script/` (e.g., `ollama-up.sh`,
`lmstudio-up.sh`) bridge these canonical configs to the running
runtime.

Secrets stay outside the workspace regardless of runtime
(e.g., `~/.config/<workspace>-secrets/`).

### External connections (`4-control/external/`)

LLM-agnostic external connections. The same MCP server, OpenAPI spec,
or webhook is conceptually identical regardless of which runtime
consumes it — canonical management here prevents drift.

- **Self-owned MCP server**: source code + connection config travel
  together in `external/mcp/<server-name>/`. Tests and language tooling
  stay scoped to that folder.
- **3rd-party MCP server**: registration + connection metadata only in
  `external/mcp/<runtime>.<format>` (per-runtime export from the
  canonical registry). Where format-compatible, the runtime's native
  config path symlinks here (e.g., `.mcp.json` → `external/mcp/registry.json`).
  Where format-incompatible (Codex TOML, Gemini embedded JSON), the
  per-runtime export sits here as documentation/staging and is merged
  into the runtime's native config manually or via sync script. No source
  code (lives in its own
  repo).
- **OpenAPI / REST**: spec files in `external/openapi/<service>.yaml`.
  Referenced from `act/skill/` or `act/script/` at call time.
- **Webhooks**: subscription config in `external/webhook/<source>.yaml`.
  Receiving handler lives in `act/script/`.

### Rule placement

Each rule has exactly one canonical home (see WORKSPACE.md §Rules and
principles). Cross-domain references link directly to that path.
Content that bridges constraint + methodology splits across two pages
rather than duplicating.

---

## Spec-evolution principles

Apply when proposing changes to WORKSPACE.md itself.

- **Minimalism over maximalism.** Add only when forced by practice.
  Three similar needs trigger consideration; only the third is allowed
  to introduce structure.
- **AAIF-aligned, not competing.** workspace.md is a sibling to
  agents.md, organized in the same format.
- **One approach, not THE approach.** Present as one perspective on
  workspace topology. Avoid normative universal claims.
- **Honest about novelty.** Where the spec proposes conventions, mark
  them explicitly ("proposed by this spec; not borrowed from an
  established standard").
- **Top-level numeric prefix carries meaning.** Changes to top-level
  layout must preserve or replace the 0–3 lifecycle + 4 control axis
  coherently.
- **Bias toward fewer folders.** Subfolders are lazy — created on
  second occurrence of a content kind, not preemptively.
