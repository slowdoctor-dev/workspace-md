# workspace.md

> A workspace-topology specification — sibling to agents.md.

## What this is

A directory-topology convention for workspaces shared between human
users and AI agents. Sits alongside `AGENTS.md` (which describes agent
behavior); this file describes the *workspace they operate within*.

Compatible with any LLM runtime:

- *Hosted agent CLIs* — Claude Code, Gemini CLI, Codex CLI
- *Local LLM backends* — Ollama, LM Studio, MLX (Apple Silicon)

Hosted CLIs provide the agent loop and read instruction files; local
backends provide token generation. The two are commonly paired
(hosted CLI pointed at a local backend's HTTP endpoint).

One approach, not *the* approach.

## Layout

**Five top-level folders are mandated**, plus three sub-paths:
`2-mind/atelier/SOUL.md` (identity), `2-mind/factory/` (knowledge
accumulation slot — may be empty), and
`4-control/principle/PRINCIPLE.md` (operating principles). Other
sub-folder structure is *recommended* but optional — apply *lazy
structure*: create only when content arrives. Layers 0–3 form a
content lifecycle; layer 4 is the orthogonal control axis.

The structure is designed to **accumulate value with use** — each
working session can leave knowledge in `2-mind/`, automation in
`3-playbook/`, and distilled constraints in `4-control/`. The
workspace becomes a higher-leverage substrate over time. See
`4-control/principle/PRINCIPLE.md` §Core design values.

    0-storage/    raw assets / inputs                       [mandated]
    1-active/     main work area                            [mandated]
    2-mind/       knowledge                                 [mandated]
      atelier/    user-authored, agent-assisted             [mandated]
        SOUL.md   workspace identity / animating principles [mandated — every workspace has identity, even minimal]
        ...       additional Owner-stance files             (optional)
      factory/    agent-authored, user-audited              [mandated, may be empty initially — extracted knowledge from work accumulates here]
    3-playbook/   automation                                [mandated, may be empty initially]
      role/       agent specs (who acts)                    (optional — when you have agent specs)
      cue/        triggers (hooks, schedules, CI workflows) (optional — when you have triggers)
      act/skill/  natural-language procedures               (optional — when you have skills)
      act/script/ executable code                           (optional — when you have scripts)
    4-control/    workspace configuration & governance      [mandated]
                  (reading order: principle → external)
      principle/    workspace operating principles            [mandated]
        PRINCIPLE.md  runtime-independent operating discipline [mandated]
        ...           additional principle files              (optional)
      rule/       enforceable rules + document conventions  (optional — when constraints to enforce)
      runtime/    canonical for runtimes lacking native     (optional — when using local LLMs:
                  repo-level convention                       Ollama Modelfile, LM Studio presets, MLX)
      external/   LLM-agnostic external connections —       (optional — when you have MCP servers,
                  MCP, OpenAPI, webhooks                      OpenAPI specs, webhooks)

Secrets and credentials never live inside the workspace — see
`4-control/principle/PRINCIPLE.md` §Runtime attachment for the
recommended out-of-workspace location.

**Separability principle**: content that is *inseparable* from a
specific runtime (settings.json, config.toml, hooks tied to a runtime's
event model) lives at the runtime's native location — workspace.md
does not over-manage it. Content that *can* exist independently of any
specific runtime (MCP server list, OpenAPI specs, webhook configs,
business rules, documents) lives runtime-independently under
`4-control/external/`, `2-mind/`, etc.

Hosted CLIs' native discovery paths live at repo root and are
committed directly **when settings exist** (lazy structure — empty
configs are not pre-created):

    .claude/settings.json     Claude Code project settings (runtime-specific)
    .codex/config.toml        Codex CLI project config (runtime-specific; trust required)
    .gemini/settings.json     Gemini CLI project settings (runtime-specific)
    .mcp.json                 → 4-control/external/mcp/registry.json

## Rule placement

Three rule homes by scope:

- **Workspace-wide rules** → `4-control/rule/<X>.md`
- **Foundational agent governance** → root `AGENTS.md` (AAIF convention)
- **Agent-local rules** → `3-playbook/role/<agent>/AGENTS.md` or
  `3-playbook/role/<agent>/rules/`

(Three-home convention proposed by this spec; not borrowed from an
established standard.)

Workspace operating *principles* — distinct from rules — live in
`4-control/principle/`. Principles shape *how* the workspace is
operated; rules constrain *what* may be done. See
`4-control/principle/PRINCIPLE.md`.

## Conventions

Vocabulary: *user* (the human), *agent* (the AI), *workspace* (the
5-folder tree rooted at the repo).

Filename:

- **Dated content** (logs, drafts, archived spec versions, queue
  items): `{YYYY-MM-DD}_{slug}.md`.
- **Durable named documents** (`WORKSPACE.md`, `PRINCIPLE.md`,
  per-agent `AGENTS.md`, individual rule files, skill `SKILL.md`):
  no date prefix; named by topic.

Detailed writing/naming conventions live in `4-control/rule/`.

## Known limitations (v0.1)

- **Windows native fragility**: the three committed symlinks
  (`CLAUDE.md`, `GEMINI.md`, `.mcp.json`) require
  `git config --global core.symlinks true` + admin terminal to
  materialize after clone on Windows native. Linux / macOS / WSL work
  out of the box.
- **Authorization / per-agent permission semantics**: not modeled in
  the spec. Encode your own in `4-control/rule/` and per-agent
  `AGENTS.md` when needed.

These are acknowledged limits, not bugs. v0.x is pre-stable; spec
matures with usage.

## See also

- `AGENTS.md` — agent-behavior spec (sibling to this file).

---

*Version: v0.1 — 2026-05-16 (pre-stable)*
