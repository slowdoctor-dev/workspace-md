# workspace.md

> A workspace-topology specification — sibling to agents.md.

## What this is

A workspace-topology specification for workspaces shared between
human users and AI agents. While [agents.md](https://agents.md)
describes agent behavior, this file describes the *workspace they
operate within*.

Compatible with any LLM runtime:

- *Hosted agent CLIs* — Claude Code, Gemini CLI, Codex CLI
- *Local LLM backends* — Ollama, LM Studio, MLX (Apple Silicon)

Hosted CLIs provide the agent loop and read instruction files; local
backends provide token generation. The two are commonly paired
(hosted CLI pointed at a local backend's HTTP endpoint).

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
          USER.md      semantic person-model (≤100 lines)   (T1)
          NEXT.md      working buffer (single-consumption)  (T1)
          journal/     episodic per-session entries         (T1; YYYY-MM-DD-<runtime>-<NNN>.md)
        archive/    aged-out journal entries                 (lazy — first audit pass)
        ...         freely-organized semantic-domain        (lazy — topic.md or topic/sub.md)
                    content (research, notes, syntheses)
      forge/      procedural memory (where skills are forged) [mandated, may be empty initially]
        role/     agent specs (who acts)                    (optional)
        cue/      triggers (hooks, schedules, CI workflows) (optional)
        act/skill/  natural-language procedures             (optional — init/session-start/
                                                             session-end/learn/audit)
        act/script/ executable code                         (optional)
    3-control/    workspace configuration & governance (T2) [mandated]
                  (reading order: foundation → external → runtime → rule)
      foundation/                                           [mandated]
        SOUL.md           canonical identity                [mandated — T2, Owner-ratified]
        PRINCIPLE.md      operating principles              [mandated — T2]
        use-driven-memory.md  memory-architecture detail    (recommended — T2)
        ...               additional foundational docs      (optional)
      external/   LLM-agnostic external connections         (optional — MCP, OpenAPI, webhooks)
      runtime/    canonical for runtimes lacking native     (optional — local LLM configs:
                  repo-level convention                       Ollama / LM Studio / MLX)
      rule/       enforceable rules + document conventions  (optional)

Secrets and credentials never live inside the workspace; keep them
outside (e.g., `~/.config/<workspace>-secrets/`).

Layout reflects the *separability* principle — runtime-tied content
lives at runtime-native paths, runtime-independent content under
`3-control/external/`, `2-mind/`, etc. Full articulation:
`3-control/foundation/PRINCIPLE.md` §Separability.

Hosted CLIs' native discovery paths live at repo root and are
committed directly **when settings exist** (lazy structure — empty
configs are not pre-created):

    .claude/settings.json     Claude Code project settings
    .codex/config.toml        Codex CLI project config (trust required)
    .gemini/settings.json     Gemini CLI project settings
    .mcp.json                 → 3-control/external/mcp/registry.json

## Rule placement

Three rule homes by scope:

- **Workspace-wide rules** → `3-control/rule/<X>.md`
- **Foundational agent governance** → root `AGENTS.md` (AAIF convention)
- **Agent-local rules** → `2-mind/forge/role/<agent>/AGENTS.md` or
  `2-mind/forge/role/<agent>/rules/`

(Three-home convention proposed by this spec; not borrowed from an
established standard.)

Workspace operating *principles* — distinct from rules — live in
`3-control/foundation/`. Principles shape *how* the workspace is
operated; rules constrain *what* may be done. See
`3-control/foundation/PRINCIPLE.md`.

## Conventions

Vocabulary: *user* (the human), *Owner* (the user in their
identity-authoring capacity, especially for atelier content;
Hermes-borrowed term), *agent* (the AI), *workspace* (the 4-folder
tree rooted at the repo).

Filename:

- **Dated content** (logs, drafts, archived spec versions, queue
  items): `{YYYY-MM-DD}_{slug}.md`.
- **Durable named documents** (`WORKSPACE.md`, `SOUL.md`,
  `PRINCIPLE.md`, per-agent `AGENTS.md`, individual rule files, skill
  `SKILL.md`): no date prefix; named by topic.

Detailed writing/naming conventions live in `3-control/rule/`.

## Known limitations (v0.1)

- **Windows native fragility**: the three committed symlinks
  (`CLAUDE.md`, `GEMINI.md`, `.mcp.json`) require
  `git config --global core.symlinks true` + admin terminal to
  materialize after clone on Windows native. Linux / macOS / WSL work
  out of the box.
- **Authorization / per-agent permission semantics**: not modeled in
  the spec. Encode your own in `3-control/rule/` and per-agent
  `AGENTS.md` when needed.

These are acknowledged limits, not bugs. v0.x is pre-stable; spec
matures with usage.

## See also

- `AGENTS.md` — workspace AAIF entry: reading order + per-runtime mapping.

---

*Version: v0.1 — 2026-05-16 (pre-stable)*
