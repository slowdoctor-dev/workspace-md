# Claude Code adapter

Per-workspace adapter notes for **Claude Code** (T2). The universal
mechanism lives in `runtime-flexibility.md`; this file records how
Claude Code's native features map onto workspace.md. Vendor facts —
verify before relying.

`last_verified: 2026-10-26` — <https://code.claude.com/docs/en/memory>,
`/hooks`, `/skills`, `/sub-agents`, `/worktrees`

| Surface | Mapping | Notes |
|---|---|---|
| Entry | `AGENTS.md` read natively (≥2.1.277) when no `CLAUDE.md` is present | Keep no `CLAUDE.md`; fallback = one line `@AGENTS.md`. Setting `claude-md-and-agents-md` loads both |
| Instruction size | official guidance: ≤200 lines per instruction file; imports do not reduce cost | `AGENTS.md` card ≤80 lines |
| Path-scoped rules | `.claude/rules/*.md` with `paths:` globs, loaded on demand; symlinks allowed | optional render of `3-control/rule/*` for Claude-only rules |
| Skills | `.claude/skills/` (project); portable-six frontmatter; Claude-only fields (`context: fork`, `paths`, `disable-model-invocation`) | `.claude/skills` → `2-mind/forge/act/skill/`; `.claude/` must be a **real directory** (symlinked `.claude` blocks worktree creation) |
| Subagents | `.claude/agents/<name>.md`; `isolation: worktree`; `memory: user|project|local` | render from `2-mind/forge/role/<name>/`; subagent memory dirs are T0 inbox (`.claude/agent-memory-local/` gitignored) |
| Auto memory | `~/.claude/projects/<project>/memory/MEMORY.md` + topic files; first 200 lines / 25KB loaded; shared across worktrees; **off by default in self-hosted/cloud** | T0 inbox: `dream` ingests with `(auto-memory claude <date>)`. To disable: `"autoMemoryEnabled": false` in `.claude/settings.json` or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` |
| Hooks | `SessionStart` (startup/resume/clear/compact/fork), `PreCompact`, `PostCompact`, `SessionEnd`, `Stop`, `SubagentStart/Stop`, `WorktreeCreate/Remove` | render from `2-mind/forge/cue/lifecycle.md` into `.claude/settings.json` (T2) |
| Worktrees | `claude --worktree <name>` → `.claude/worktrees/<name>/`; main checkout's `.claude/skills`/`agents` read through | gitignore `.claude/worktrees/`; R5 applies (journal + NEXT only from a worktree) |
| MCP | `.mcp.json` (project scope) | symlink → `3-control/external/mcp/registry.json` |
| Headless | `claude -p`; cloud sessions; scheduled runs | T2 via PR channel; slug `cloud` / `cron` |

## Detection

`detect-runtime`: `CLAUDE_PROJECT_DIR` env or `.claude/` dir →
`harness = claude-code`; model from self-identification (Claude 5
family: `claude-opus-5-5`, `claude-sonnet-5-5`, `claude-haiku-5-5`,
`claude-fable-5-1` — all 1M context). `model_class`: Opus / Fable /
Sonnet → `hosted-frontier`; Haiku → `hosted-small`.

## Prompt-audit

`/doctor prompt-audit` covers `AGENTS.md`, rules, skills, and agents
for dated or contradictory instructions — run it after upgrading the
spec version.
