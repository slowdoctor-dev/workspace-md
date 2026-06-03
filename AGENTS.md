# AGENTS.md

This repo defines the `workspace.md` specification — a sibling to
[agents.md](https://agents.md) describing workspace topology for
human-agent collaboration.

> **Adopter note**: the line above describes *this spec repo*. When you
> adopt workspace.md, re-home this intro to describe *your* workspace
> (keep the §Reading order + §Per-runtime entry sections). If you
> already have an `AGENTS.md`, see `2-mind/forge/act/skill/init/SKILL.md
> §Existing AGENTS.md handoff` and `3-control/foundation/adoption.md`.

## Reading order (load at session-start, in sequence)

*Convenience summary of the canonical 7-item list in
`3-control/foundation/use-driven-memory.md §Read order at session-start`
— keep byte-for-byte in sync. Skills cite the canonical, so this works
even if an adopter's `AGENTS.md` omits this section.*

1. `AGENTS.md` (this file) — workspace entry + per-runtime mapping
2. `WORKSPACE.md` — topology spec
3. `3-control/foundation/PRINCIPLE.md` — operating principles
4. `3-control/foundation/SOUL.md` — canonical identity (Owner-ratified)
5. `2-mind/garden/essential/USER.md` — semantic person-model
6. `2-mind/garden/essential/NEXT.md` — working buffer (consume + clear)
7. `2-mind/garden/essential/journal/<most-recent>.md` — recent-session continuity

`2-mind/garden/essential/SOUL.md` (working identity observations) is
NOT loaded at session-start. Read only by the `dream` skill when
proposing graduations to canonical `3-control/foundation/SOUL.md`.

## Per-runtime entry

This workspace adopts the AAIF universal entry pattern. Each runtime
reads its own auto-discovered instruction file at the workspace root,
all pointing at this `AGENTS.md`:

- **Codex CLI** — reads `AGENTS.md` directly (native AAIF support).
- **Claude Code** — reads `CLAUDE.md` → symlinked to `AGENTS.md`.
- **Gemini CLI** — reads `GEMINI.md` → symlinked to `AGENTS.md`, or
  configure `context.fileName: ["AGENTS.md", "GEMINI.md"]` in
  `~/.gemini/settings.json`.
- **Antigravity CLI** (`agy`, Gemini CLI's successor) — auto-loads
  `AGENTS.md` + `GEMINI.md` unchanged; native skills under
  `.agents/skills` → `2-mind/forge/act/skill/`. Full adapter +
  transition details: `3-control/runtime/antigravity-cli.md`.

## Status

Pre-stable (v0.x). Breaking changes possible. See `WORKSPACE.md`
footer for current version.
