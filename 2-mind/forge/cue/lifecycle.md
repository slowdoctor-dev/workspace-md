# Lifecycle cues — canonical hook spec

Runtime-neutral mapping from harness lifecycle events to workspace.md
skills. **This file is canonical**; per-harness hook configs
(`.claude/settings.json` → `hooks`, `.codex/hooks.json` or inline
`config.toml`, `.agents/hooks.json`) are *rendered* from it on demand
and kept in sync by `audit`. Rendered hook files execute code, so they
are **T2** even at native paths (`use-driven-memory.md §2 write-tiers`).

Hook-less harnesses (Hermes, OpenCode, Continue.dev) skip rendering;
the skills carry the same discipline declaratively.

## Event → action

| Cue (neutral name) | Claude Code event | Codex CLI event | Action |
|---|---|---|---|
| `session.start` | `SessionStart` (source `startup`) | `SessionStart` (`startup`) | run `session-start` in full |
| `session.reenter` | `SessionStart` (`compact` / `resume` / `fork`) | `SessionStart` (`resume` / `clear`), `PostCompact` | run `session-start` in **re-entry mode** (hot load only; no `NEXT.md` consume) |
| `context.precompact` | `PreCompact` | `PreCompact` | append a `NEXT.md` checkpoint block (*Outstanding* only) |
| `turn.stop` | `Stop` | `Stop` | optional: remind to run `session-end` if the Owner is leaving |
| `session.end` | `SessionEnd` | — | run `session-end` if not already run (journal + `NEXT.md` block) |
| `subagent.start` | `SubagentStart` | — | inject R5 line: "worktree/subagent → journal + NEXT only; no garden consolidation" |
| `worktree.create` | `WorktreeCreate` | — | copy `.worktreeinclude`d files; nothing else |

Antigravity CLI inherits Gemini CLI's JSON hook format and lifecycle
events; map by event name. Event names are the harness's; verify
against its docs before rendering (`3-control/runtime/<harness>.md`).

## Rendering rules

- Render **only** rows whose event the harness exposes; omit the rest.
- Hook bodies are one-liners that *invoke a skill or append a block*;
  no business logic lives in the rendered file.
- Record `rendered_from: 2-mind/forge/cue/lifecycle.md @ <git sha>` as a
  comment or sibling note so `audit` can detect drift.
- Rendered hooks must not read or write outside the workspace, and
  never run on untrusted content (`3-control/rule/trust.md`).

## Reference shape (Claude Code)

```json
{ "hooks": { "SessionStart": [ { "matcher": "compact|resume|fork",
  "hooks": [ { "type": "command",
  "command": "echo 'Re-entry: reload hot read order (AGENTS.md §Hot read order); do not consume NEXT.md.'" } ] } ],
  "PreCompact": [ { "hooks": [ { "type": "command",
  "command": "echo 'Append a NEXT.md checkpoint block (Outstanding) before compaction.'" } ] } ] } }
```

Illustrative; adopt the harness's current schema.
