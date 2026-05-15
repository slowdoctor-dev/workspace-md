# workspace.md

A workspace-topology specification for shared human-and-AI-agent
workspaces. Sibling to [agents.md](https://agents.md).

## What this is

`WORKSPACE.md` (at repo root) is the spec. It describes a 5-folder
directory topology + governance conventions for workspaces where
humans and AI agents collaborate. Drop-in compatible with any LLM
runtime — Claude Code, Gemini CLI, Codex, local LLMs like Ollama or
LM Studio.

This repo is itself a workspace.md-compliant workspace — eating its
own dog food.

## Repo layout

    WORKSPACE.md              the spec
    AGENTS.md                 universal AAIF entry (read by any runtime)
    CLAUDE.md → AGENTS.md     symlink (Claude Code reads this)
    GEMINI.md → AGENTS.md     symlink (Gemini CLI reads this)
    .claude/                  project-level discovery
      settings.json           → 4-control/runtime/claude/settings.json (symlink)
    .codex/                   project-level discovery
      config.toml             → 4-control/runtime/codex/config.toml (symlink)
    .gemini/                  project-level discovery
      settings.json           → 4-control/runtime/gemini/settings.json (symlink)
    .mcp.json                 → 4-control/external/mcp/claude.json (symlink)
    0-storage/                (empty in spec repo; raw inputs slot)
    1-active/                 (empty in spec repo; working area slot)
    2-mind/
      atelier/                (empty in v0.1; user-stance content)
      factory/                version log + getting-started walkthrough
    3-playbook/
      act/script/             ollama-up.sh, lmstudio-up.sh (local LLM bootstrap)
      (role, cue, act/skill)  (empty in spec repo; spec is documentation)
    4-control/
      principle/              operating principles + runtime-integration
      rule/                   contribution rules
      runtime/
        claude/settings.json  canonical Claude Code settings (workspace level)
        codex/config.toml     canonical Codex CLI config
        gemini/settings.json  canonical Gemini CLI settings
      external/mcp/
        claude.json           canonical Claude MCP server registry

Empty folders are intentional in v0.1 — the spec repo is
documentation-shaped, not operational. They demonstrate the spec's
shape and populate when adopted operationally.

## Reading order

1. This `README.md`
2. `WORKSPACE.md` — the spec itself
3. `4-control/principle/principle.md` — how to operate the workspace
4. `4-control/principle/runtime-integration.md` — per-runtime
   integration (Claude Code, Gemini CLI, Codex CLI; verified against
   official docs)
5. `2-mind/factory/getting-started.md` — adoption walkthrough
6. `4-control/rule/contribution.md` — how to propose changes

## Getting started for adopters

Full walkthrough: **`2-mind/factory/getting-started.md`**.

TL;DR:

    git clone <this-repo>.git my-workspace
    cd my-workspace
    rm -rf .git && git init -q

Then in `2-mind/factory/getting-started.md`:

1. Replace spec-repo-only files (`README.md`, `LICENSE`, `AGENTS.md`,
   `4-control/rule/contribution.md`, `2-mind/factory/version-log.md`).
2. Attach your runtime (`4-control/runtime/<your-runtime>/` + symlink).
3. Add your first content per layer.
4. (Optional) Attach MCP servers and hooks.

### Spec-repo-only files vs your workspace

Files marked **replace** in the walkthrough describe THIS spec repo —
they are not part of the workspace.md spec itself. Customize them for
your workspace.

## License

CC-BY-SA 4.0 — see `LICENSE`.

## Status

Pre-stable (v0.x). Breaking changes possible. See `WORKSPACE.md`
footer for current version.
