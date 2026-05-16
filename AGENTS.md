# AGENTS.md

This repo defines the `workspace.md` specification — a sibling to
[agents.md](https://agents.md) describing workspace topology for
human-agent collaboration.

## Reading order

1. `2-mind/atelier/SOUL.md` — workspace identity (verbatim Owner
   stance; injected at session start per Hermes pattern)
2. `WORKSPACE.md` — the spec
3. `4-control/principle/PRINCIPLE.md` — operating principles

## Per-runtime entry

This workspace adopts the AAIF universal entry pattern. Each runtime
reads its own auto-discovered instruction file at the workspace root,
all pointing at this `AGENTS.md`:

- **Codex CLI** — reads `AGENTS.md` directly (native AAIF support).
- **Claude Code** — reads `CLAUDE.md` → symlinked to `AGENTS.md`.
- **Gemini CLI** — reads `GEMINI.md` → symlinked to `AGENTS.md`, or
  configure `context.fileName: ["AGENTS.md", "GEMINI.md"]` in
  `~/.gemini/settings.json`.

## Status

Pre-stable (v0.x). Breaking changes possible. See `WORKSPACE.md`
footer for current version.
