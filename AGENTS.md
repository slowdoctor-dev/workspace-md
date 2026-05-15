# AGENTS.md

This repo defines the `workspace.md` specification — a sibling to
[agents.md](https://agents.md) describing workspace topology for
human-agent collaboration.

## Reading order

1. `WORKSPACE.md` — the spec
2. `4-control/principle/principle.md` — operating principles + core design values
3. `4-control/principle/runtime-integration.md` — per-runtime integration (verified against official docs)
4. `2-mind/factory/getting-started.md` — adoption walkthrough
5. `4-control/rule/contribution.md` — contribution rules (this spec only)

## Lifecycle skills

Five skills under `3-playbook/act/skill/` codify session and
maintenance lifecycle:

- `session-init` — once after `git clone`
- `session-start` — every working-session start
- `session-end` — before disconnecting (chains to `session-retro`)
- `session-retro` — accumulation: extract session learnings into
  durable assets across all 5 layers + non-runtime root files
  (`AGENTS.md`, `README.md`)
- `workspace-audit` — periodic maintenance: prune / merge / refactor
  accumulated content (the *groundskeeper*)

## Per-runtime entry

This workspace adopts the AAIF universal entry pattern. Each runtime
reads its own auto-discovered instruction file at the workspace root,
all pointing at this `AGENTS.md`:

- **Codex CLI** — reads `AGENTS.md` directly (native AAIF support).
- **Claude Code** — reads `CLAUDE.md` → symlinked to `AGENTS.md`.
- **Gemini CLI** — reads `GEMINI.md` → symlinked to `AGENTS.md`, or
  configure `context.fileName: ["AGENTS.md", "GEMINI.md"]` in
  `~/.gemini/settings.json`.

See `4-control/principle/runtime-integration.md` for the full mapping
including settings, MCP servers, subagents, hooks, and per-runtime
specifics verified against official documentation.

## Conventions for working in this repo

- This repo follows `WORKSPACE.md` ("eat your own dog food"). Empty
  folders in `0-storage/`, `1-active/`, `3-playbook/*` are intentional
  for v0.1 — the spec repo is documentation-shaped, not operational.
- Changes to the spec require following `4-control/rule/contribution.md`.
- Always-current spec is `WORKSPACE.md` at repo root; archived versions
  go to `2-mind/factory/<YYYY-MM-DD>_workspace_v<X.Y>.md`.

## Status

Pre-stable (v0.x). Breaking changes possible.
