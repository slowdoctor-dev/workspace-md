# workspace.md

> A workspace-topology specification — sibling to agents.md.

## What this is

A directory-topology convention for workspaces shared between human
users and AI agents. Sibling to [agents.md](https://agents.md) (which
describes agent behavior); this file describes the *workspace they
operate within*.

Compatible with any LLM runtime:

- *Hosted agent CLIs* — Claude Code, Gemini CLI, Codex CLI
- *Local LLM backends* — Ollama, LM Studio, MLX (Apple Silicon)

Hosted CLIs provide the agent loop and read instruction files; local
backends provide token generation. The two are commonly paired
(hosted CLI pointed at a local backend's HTTP endpoint).

One approach, not *the* approach.

## Layout

**Five top-level folders are mandated**, plus three mandated leaf
paths: `2-mind/atelier/SOUL.md` (identity), `2-mind/factory/`
(knowledge accumulation slot, may be empty), and
`4-control/principle/PRINCIPLE.md` (operating principles). Containing
`2-mind/atelier/` and `4-control/principle/` folders are implied. All
other sub-folder structure is *optional* — apply *lazy structure*:
create only when content arrives.

Layer 0 is general file storage (LLM-passive); layers 1–3 are
LLM-active content layers; layer 4 is the orthogonal control axis.
The 1–4 design enables *use-driven evolution* — see
`4-control/principle/PRINCIPLE.md` §Core design values.

    0-storage/    general file storage (LLM-passive)        [mandated]
    1-active/     main work area                            [mandated]
    2-mind/       knowledge systems                         [mandated]
      atelier/    Owner-authored knowledge                  [mandated]
        SOUL.md   workspace identity / animating principles [mandated — every workspace has identity, even minimal]
        ...       additional Owner-stance files             (optional)
      factory/    agent-authored knowledge                  [mandated, may be empty initially — synthesis accumulates here]
    3-playbook/   automation                                [mandated, may be empty initially]
      role/       agent specs (who acts)                    (optional)
      cue/        triggers (hooks, schedules, CI workflows) (optional)
      act/skill/  natural-language procedures               (optional)
      act/script/ executable code                           (optional)
    4-control/    workspace configuration & governance      [mandated]
                  (reading order: principle → external → runtime → rule)
      principle/    workspace operating principles            [mandated]
        PRINCIPLE.md  runtime-independent operating discipline [mandated]
        ...           additional principle files              (optional)
      external/   LLM-agnostic external connections         (optional — MCP, OpenAPI, webhooks)
      runtime/    canonical for runtimes lacking native     (optional — local LLM configs:
                  repo-level convention                       Ollama / LM Studio / MLX)
      rule/       enforceable rules + document conventions  (optional)

Secrets and credentials never live inside the workspace; keep them
outside (e.g., `~/.config/<workspace>-secrets/`).

Layout reflects the *separability* principle — runtime-tied content
lives at runtime-native paths, runtime-independent content under
`4-control/external/`, `2-mind/`, etc. Full articulation:
`PRINCIPLE.md` §Separability.

Hosted CLIs' native discovery paths live at repo root and are
committed directly **when settings exist** (lazy structure — empty
configs are not pre-created):

    .claude/settings.json     Claude Code project settings
    .codex/config.toml        Codex CLI project config (trust required)
    .gemini/settings.json     Gemini CLI project settings
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

Vocabulary: *user* (the human), *Owner* (the user in their
identity-authoring capacity, especially for atelier content;
Hermes-borrowed term), *agent* (the AI), *workspace* (the 5-folder
tree rooted at the repo).

Filename:

- **Dated content** (logs, drafts, archived spec versions, queue
  items): `{YYYY-MM-DD}_{slug}.md`.
- **Durable named documents** (`WORKSPACE.md`, `SOUL.md`,
  `PRINCIPLE.md`, per-agent `AGENTS.md`, individual rule files, skill
  `SKILL.md`): no date prefix; named by topic.

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
