# workspace.md

> A workspace-topology specification — sibling to agents.md.

## What this is

A workspace-topology specification for workspaces shared between
human users and AI agents. While [agents.md](https://agents.md)
describes agent behavior, this file describes the *workspace they
operate within*.

Runtime-flexible across LLM runtimes (examples illustrative, not exhaustive):

- *Hosted agent CLIs* — Claude Code, Codex CLI, Gemini CLI /
  Antigravity CLI (`agy`, Gemini CLI's successor — see Known limitations)
- *Local LLM backends* — Ollama, LM Studio, MLX (Apple Silicon)

Hosted CLIs provide the agent loop + read instruction files; local
backends generate tokens. The two pair commonly (hosted CLI → local
HTTP endpoint).

One approach, not *the* approach.

## Layout

**Four top-level folders are mandated** (0-storage, 1-active, 2-mind,
3-control), plus four mandated sub-paths: `2-mind/garden/`
(declarative memory layer), `2-mind/forge/` (procedural memory layer),
`3-control/foundation/SOUL.md` (canonical identity), and
`3-control/foundation/PRINCIPLE.md` (operating principles). All other
sub-folder structure is *optional* — apply *lazy structure*: create
only when content arrives.

Layer 0 is general file storage (LLM-passive); layers 1–2 are
LLM-active content layers (working scratch + agent memory); layer 3
is the orthogonal control axis (Owner-curated governance).
This structure enables *use-driven evolution* — see
`3-control/foundation/PRINCIPLE.md` §Core design values.

    0-storage/    general file storage (LLM-passive)        [mandated]
    1-active/     main work area (ephemeral scratch)        [mandated]
    2-mind/       agent-managed memory layer (T1)           [mandated]
      atelier/    Owner-stance bin (T2 if content exists)   (optional — brand, persona,
                                                             voice; non-canonical Owner content)
      garden/     declarative memory — semantic + episodic  [mandated]
                  + working (where knowledge grows)
        essential/                                          (recommended — auto-growth machinery)
          SOUL.md      working identity observations        (T1)
          USER.md      semantic person-model (tier-capped)   (T1)
          NEXT.md      working buffer (single-consumption)  (T1)
          journal/     episodic per-session entries         (T1; <YYYY-MM-DD>-<runtime>-<NNN>.md)
        archive/    aged-out journal entries +               (lazy — first audit pass;
                    audit-pruned low-utility items            sub-folders: <YYYY-MM>/, low-utility/)
        ...         freely-organized semantic-domain        (lazy — topic.md or topic/sub.md)
                    content (research, notes, syntheses)
      forge/      procedural memory (where skills are forged) [mandated, may be empty initially]
        role/     agent specs (who acts)                    (optional)
        cue/      triggers (hooks, schedules, CI workflows) (optional)
        act/skill/  natural-language procedures             (optional — init/session-start/
                                                             session-end/dream/audit/detect-runtime)
        act/script/ executable code                         (optional — e.g. detect-runtime.sh)
    3-control/    workspace configuration & governance (T2) [mandated]
                  (reading order: foundation → external → runtime → rule)
      foundation/                                           [mandated]
        SOUL.md                canonical identity            [mandated — T2, Owner-ratified]
        PRINCIPLE.md           operating principles          [mandated — T2]
        use-driven-memory.md   memory-architecture detail    (recommended — T2)
        runtime-flexibility.md runtime-tier mechanism (R2 B) (recommended — T2)
        ...                    additional foundational docs  (optional)
      external/   LLM-agnostic external connections         (optional — MCP, OpenAPI, webhooks)
      runtime/    runtime adapters + active runtime profile (optional; recommended once
                                                             `detect-runtime` runs at init —
                                                             profile.md holds 6 fields: harness,
                                                             backend_provider, backend_endpoint,
                                                             backend_model, effective_context,
                                                             active_tier. Local LLM adapter
                                                             configs (Ollama / LM Studio / MLX)
                                                             also land here when adopter needs
                                                             repo-level convention)
      rule/       enforceable rules + document conventions  (optional)

Secrets and credentials never live inside the workspace; keep them
outside (e.g., `~/.config/<workspace>-secrets/`).

Layout reflects *separability* — runtime-tied content at native paths,
runtime-independent content under `3-control/external/`, `2-mind/`, etc.
(full articulation: `3-control/foundation/PRINCIPLE.md §Separability`).

Hosted CLIs' native discovery paths live at repo root and are
committed directly **when settings exist** (lazy structure — in an
adopter's workspace, empty configs are not pre-created):

    .claude/settings.json     Claude Code project settings
    .codex/config.toml        Codex CLI project config (trust required)
    .gemini/settings.json     Gemini CLI project settings
    .mcp.json                 → 3-control/external/mcp/registry.json
    .agents/skills            → 2-mind/forge/act/skill/  (Antigravity native skills dir)
    .agents/mcp_config.json   Antigravity MCP — rendered on demand (not pre-created)

`.agents/` uses the symlink-alias policy (one canonical home under
`2-mind/forge/`, exposed at the native path); the Antigravity MCP config
is *rendered on demand* (`url`→`serverUrl`) at first-server time — see
`3-control/external/mcp/`. *Exception (this spec repo only):* it ships
`.mcp.json → registry.json` and `.agents/skills` as committed reference
examples (registry empty) to demonstrate the pattern — dogfooding, not a
lazy-structure violation; the rule governs *adopter* workspaces.

## Rule placement

Three rule homes by scope:

- **Workspace-wide rules** → `3-control/rule/<X>.md`
- **Foundational agent governance** → root `AGENTS.md` (AAIF convention)
- **Agent-local rules** → `2-mind/forge/role/<agent>/AGENTS.md` or
  `2-mind/forge/role/<agent>/rules/`

(Three-home convention proposed by this spec; not borrowed from an
established standard.)

**Rule numbering.** `R1`–`R4` are reserved for the memory rules
(`use-driven-memory.md §4`); adopter rules in `3-control/rule/` must use
a distinct prefix (`ACME-1`, `A1…`) so `R2` is never ambiguous.

Workspace operating *principles* — distinct from rules — live in
`3-control/foundation/`. Principles shape *how* the workspace is
operated; rules constrain *what* may be done. See
`3-control/foundation/PRINCIPLE.md`.

## Conventions

Vocabulary: *user* (the human), *Owner* (the user authoring identity,
esp. atelier content; Hermes term), *agent* (the AI), *workspace* (the
4-folder tree rooted at the repo).

Filename:

- **Dated content** (logs, drafts, archived spec versions, queue
  items): `{YYYY-MM-DD}_{slug}.md`.
- **Episodic journal entries** — the dated-content exception:
  `<YYYY-MM-DD>-<runtime>-<NNN>.md` (runtime tag + ordinal, no slug;
  see `use-driven-memory.md`).
- **Durable named documents** (`WORKSPACE.md`, `AGENTS.md`,
  `SOUL.md`, `PRINCIPLE.md`, `USER.md`, `NEXT.md`,
  `use-driven-memory.md`, per-agent `AGENTS.md`, individual rule
  files, skill `SKILL.md`): no date prefix; named by topic.
  Canonical mandated files use UPPERCASE; supplementary docs use
  lowercase-hyphenated.

When present, detailed writing/naming conventions live in
`3-control/rule/` (optional/lazy — absent until an adopter adds rules).

**Metadata / frontmatter.** Foundation/topology docs and template seeds
are **metadata-free** (no YAML frontmatter); lifecycle `SKILL.md` files
carry native skill frontmatter (`name:`/`description:`), which is
expected. Adopters mandating universal frontmatter should **exempt**
these — list in `3-control/foundation/adoption.md`.

## Known limitations (v0.x)

- **Windows native fragility**: the committed symlinks (`CLAUDE.md`,
  `GEMINI.md`, `.mcp.json`, `.agents/skills`) require
  `git config --global core.symlinks true` + admin terminal to
  materialize after clone on Windows native. Linux / macOS / WSL work
  out of the box.
- **Symlinks clobbered by in-place rewriters**: `sed -i` (temp-file +
  rename) replaces a symlink with a regular file of the followed
  content — silently breaking `CLAUDE.md`/`GEMINI.md` → `AGENTS.md`.
  Edit the *target*, or re-create the link (`ln -sf AGENTS.md
  CLAUDE.md`); `audit`'s symlink check catches drift.
- **Gemini CLI sunset / Antigravity**: Gemini CLI is being retired for
  free/Pro/Ultra in favour of Antigravity CLI (`agy`); running both
  leaks rules via the shared `~/.gemini/GEMINI.md`, and `detect-runtime`
  warns. Dates, sources, and the full adapter:
  `3-control/runtime/antigravity-cli.md`.
- **Authorization / per-agent permission semantics**: not modeled in
  the spec. Encode your own in `3-control/rule/` and per-agent
  `AGENTS.md` when needed.
- **Hook availability varies by harness**: the major CLIs
  (Claude Code, Codex CLI, Gemini CLI / Antigravity CLI — which
  inherits Gemini CLI's JSON hook format + lifecycle events) support
  SessionStart hooks for stronger R2 enforcement; hook-less harnesses
  (Hermes Agent, OpenCode, Continue.dev) rely on declarative
  `profile.md` + adaptive capability detection (per
  `runtime-flexibility.md` + `detect-runtime` skill). The spec degrades
  gracefully — declarative + adaptive is the universal floor.

These are acknowledged limits, not bugs (v0.x is pre-stable).

## See also

- `README.md` — public-facing repo entry (start here if browsing on GitHub).
- `AGENTS.md` — workspace AAIF entry: reading order + per-runtime mapping for AI agents.
- `3-control/foundation/adoption.md` — adopting into a new/existing
  workspace (first use, what to keep vs adapt, store migration, metadata).
- `LICENSE` — Apache License 2.0.

---

*Version: v0.1.2 — 2026-06-03 (pre-stable)*
