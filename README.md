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
    CLAUDE.md → AGENTS.md     symlink (Claude Code reads this natively)
    GEMINI.md → AGENTS.md     symlink (Gemini CLI reads this natively)
    .claude/                  Claude Code native discovery
      settings.json           project settings (committed directly)
    .codex/                   Codex CLI native discovery
      config.toml             project config (committed directly)
    .gemini/                  Gemini CLI native discovery
      settings.json           project settings (committed directly)
    .mcp.json                 → 4-control/external/mcp/registry.json
                              (only externalized config — MCP server list is
                              LLM-agnostic; JSON format coincides with Claude's)
    0-storage/                (empty in spec repo; raw inputs slot)
    1-active/                 (empty in spec repo; working area slot)
    2-mind/
      atelier/                (empty in v0.1; user-stance content)
      factory/                version log + getting-started walkthrough
    3-playbook/
      act/script/             check-workspace.sh, ollama-up.sh, lmstudio-up.sh
      act/skill/              session-init/, session-start/, session-end/,
                              session-retro/
                              (lifecycle skills — natural-language procedures
                              that agents read and follow with judgment;
                              session-retro consolidates session learnings
                              into durable workspace assets)
      (role, cue)             (empty in spec repo; spec is documentation)
    4-control/
      principle/              operating principles + runtime-integration
      rule/                   contribution rules
      runtime/                (reserved for local LLM canonicals —
                              Ollama Modelfile, LM Studio presets, MLX scripts.
                              Hosted CLIs use their native .<runtime>/ above.)
      external/mcp/
        registry.json         LLM-agnostic MCP server registry
                              (symlink target for .mcp.json)

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
