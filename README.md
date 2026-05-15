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
    0-storage/                [mandated, empty in spec repo]
    1-active/                 [mandated, empty in spec repo]
    2-mind/                   [mandated]
      factory/                version log + getting-started
      (atelier/ omitted — no Owner-stance content; optional per spec)
    3-playbook/               [mandated]
      act/script/             check-workspace.sh, mcp-sync.sh,
                              ollama-up.{sh,ps1}, lmstudio-up.{sh,ps1}
      act/skill/              session-{init,start,end,retro}/, workspace-audit/
                              (lifecycle skills; Hermes / Auto Dream lineage)
      (role/, cue/ omitted — no agent specs or triggers; optional per spec)
    4-control/                [mandated]
      principle/              principle.md + runtime-integration.md
      rule/                   contribution.md
      external/mcp/           registry.json (canonical) + codex.toml / gemini.json
                              (derivations from mcp-sync.sh)
      (runtime/ omitted — no local LLM configs; optional per spec)
    .github/workflows/        CI: check-workspace.sh on push/PR

Per workspace.md spec, 5 top-level folders are mandated; sub-folders
are optional (*lazy-structure*: create on content arrival). This spec
repo demonstrates by example — empty optional sub-folders are not
pre-created.

## Reading order

1. This `README.md`
2. `WORKSPACE.md` — the spec itself
3. `4-control/principle/principle.md` — operating principles + core design values
4. `4-control/principle/runtime-integration.md` — per-runtime integration (verified against official docs)
5. `2-mind/factory/getting-started.md` — adoption walkthrough
6. `4-control/rule/contribution.md` — contribution rules (this spec only)

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
