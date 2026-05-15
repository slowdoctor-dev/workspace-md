# workspace.md

> A workspace-topology specification — sibling to agents.md.

## What this is

A directory-topology convention for workspaces shared between human
users and AI agents. Sits alongside `AGENTS.md` (which describes agent
behavior); this file describes the *workspace they operate within*.

Drop-in compatible with any LLM runtime:

- *Hosted agent CLIs* — Claude Code, Gemini CLI, Codex CLI
- *Local LLM backends* — Ollama, LM Studio, MLX (Apple Silicon)

Hosted CLIs provide the agent loop and read instruction files; local
backends provide token generation. The two are commonly paired
(hosted CLI pointed at a local backend's HTTP endpoint).
See `4-control/principle/runtime-integration.md` for per-runtime
specs verified against official documentation.

One approach, not *the* approach.

## Layout

Five top-level folders. Layers 0–3 form a content lifecycle; layer 4 is
the orthogonal control axis (how the workspace itself is configured and
governed).

The structure is designed to **accumulate value with use** — each
working session can leave knowledge in `2-mind/`, automation in
`3-playbook/`, and distilled constraints in `4-control/`. The
workspace becomes a higher-leverage substrate over time. See
`4-control/principle/principle.md` §Core design values.

    0-storage/    raw assets / inputs
    1-active/     main work area
    2-mind/       curated knowledge
      atelier/    user-authored, agent-assisted
      factory/    agent-authored, user-audited
    3-playbook/   automation
      role/       agent specs (who acts)
      cue/        triggers (when / where) — hooks, schedules, CI workflows
      act/skill/  natural-language procedures (agent reads + follows)
      act/script/ executable code (deterministic; no agent judgment)
    4-control/    workspace configuration & governance
                  (reading order: principle → runtime → external → rule)
      principle/  workspace operating principles / philosophy
      runtime/    configs for runtimes lacking a native repo-level
                  convention (local LLMs: Ollama Modelfile, LM Studio
                  presets, MLX scripts). Hosted CLIs (Claude Code,
                  Codex, Gemini) use their native `.<runtime>/` at
                  repo root directly — no externalization.
      external/   LLM-agnostic external connections — MCP servers,
                  OpenAPI specs, webhooks. Canonical here under neutral
                  names (e.g., `mcp/registry.json`); each runtime's
                  native config references via symlink (format-compatible
                  case) or merge (format-incompatible case).
      rule/       enforceable workspace rules + document conventions
      .env        environment variables (optional; secrets stay outside)

**Separability principle**: content that is *inseparable* from a
specific runtime (settings.json, config.toml, hooks tied to a runtime's
event model) lives at the runtime's native location — workspace.md
does not over-manage it. Content that *can* exist independently of any
specific runtime (MCP server list, OpenAPI specs, webhook configs,
business rules, documents) lives runtime-independently under
`4-control/external/`, `2-mind/`, etc.

Hosted CLIs' native discovery paths live at repo root and are
committed directly:

    .claude/settings.json     Claude Code project settings (runtime-specific)
    .codex/config.toml        Codex CLI project config (runtime-specific; trust required)
    .gemini/settings.json     Gemini CLI project settings (runtime-specific)
    .mcp.json                 → 4-control/external/mcp/registry.json
                              (Claude's MCP discovery path; symlink to the
                              LLM-agnostic canonical because the format
                              happens to match Claude's native schema)

## Rules and principles

Three rule homes by scope:

- **Workspace-wide rules** → `4-control/rule/<X>.md`
- **Foundational agent governance** → root `AGENTS.md` (AAIF convention)
- **Agent-local rules** → `3-playbook/role/<agent>/AGENTS.md` or
  `3-playbook/role/<agent>/rules/`

Workspace operating principles (orientation, philosophy) live separately
in `4-control/principle/` — these shape *how* the workspace is operated,
distinct from rules that constrain *what* may be done.

(Convention proposed by this spec; not borrowed from an established
standard.)

## Conventions

Vocabulary: *user* (the human), *agent* (the AI), *workspace* (the
5-folder tree rooted at the repo).

Filename: `{YYYY-MM-DD}_{slug}.md` recommended.

Detailed writing/naming conventions live in `4-control/rule/`.

## Known limitations (v0.1)

- **Empirical basis is small (n=2)**: this spec converged from two
  independently-designed workspaces (LEAD clinic + a personal Life-OS),
  both authored by the same person. Universality across domains and
  authors is hypothesized, not proven.
- **Use-driven evolution unverified empirically**: the *use compounds
  usability* claim rests on the design, not on multi-month field data.
- **Windows native fragility**: the three committed symlinks
  (`CLAUDE.md`, `GEMINI.md`, `.mcp.json`) require
  `git config --global core.symlinks true` + admin terminal to
  materialize after clone on Windows native. Linux / macOS / WSL work
  out of the box.
- **No multi-user / team model**: Owner is assumed singular.
  Team-shared workspaces with multiple humans are not addressed.
- **Authorization / per-agent permission semantics**: not modeled in
  the spec. Adopters should encode their own in `4-control/rule/`
  and per-agent `AGENTS.md`.
- **Heavy first-time read** (~1900 lines across spec docs): mitigated
  by reading order, but not eliminated.

These are acknowledged limits, not bugs. v0.x is pre-stable; spec
matures with usage. See `4-control/rule/contribution.md`.

## See also

- `AGENTS.md` — agent-behavior spec (sibling to this file).

---

*Version: v0.1 — 2026-05-16 (pre-stable)*
