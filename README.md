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
    AGENTS.md                 forward + reading order
    0-storage/                (empty in spec repo; raw inputs slot)
    1-active/                 (empty in spec repo; working area slot)
    2-mind/
      atelier/                (empty in v0.1; user-stance content)
      factory/                version log
    3-playbook/               (empty in spec repo; spec is documentation)
    4-control/
      principle/              operating principles
      rule/                   contribution rules
      runtime/                (empty; N/A for spec repo)
      external/               (empty; N/A for spec repo)

Empty folders are intentional in v0.1 — the spec repo is
documentation-shaped, not operational. They demonstrate the spec's
shape and populate when adopted operationally.

## Reading order

1. This `README.md`
2. `WORKSPACE.md` — the spec itself
3. `4-control/principle/principle.md` — how to operate the workspace
4. `4-control/rule/contribution.md` — how to propose changes

## Quick start for adopters

    git clone <this-repo>.git my-workspace
    cd my-workspace
    rm -rf .git
    # Edit README.md to describe your workspace.
    # Fill in folders per WORKSPACE.md.

## License

CC-BY-SA 4.0 — see `LICENSE`.

## Status

Pre-stable (v0.x). Breaking changes possible. See `WORKSPACE.md`
footer for current version.
