# Antigravity CLI adapter

Runtime adapter notes for **Antigravity CLI** (`agy`) — Google's
successor to Gemini CLI. Gemini CLI sunsets **2026-06-18** for free /
AI Pro / AI Ultra / org installs; Code Assist Standard/Enterprise keep
Gemini CLI. This file is the per-workspace adapter convention (T2);
the universal mechanism lives in `runtime-flexibility.md`.

| Surface | Mapping | Notes |
|---|---|---|
| Context files | `AGENTS.md` + `GEMINI.md` auto-loaded, unchanged | no edits needed (✓ compatible) |
| Skills | `.agents/skills` → `2-mind/forge/act/skill/` (symlink) | Antigravity's native skills dir; skills are `.md`, format-compatible |
| MCP | `.agents/mcp_config.json` → `3-control/external/mcp/mcp_config.json` | **rendered** form: remote field `url` → `serverUrl` (copied Gemini configs fail silently otherwise). See `3-control/external/mcp/README.md` |
| Model | `--model` flag **removed**; runtime auto-selects (Gemini) | `profile.md backend_model` is *descriptive* here — record `auto:gemini-3.5-flash` |
| Hooks | same JSON hook format + lifecycle events as Gemini CLI | SessionStart hook usable for R2 enforcement |
| Headless | `agy -p "<prompt>" --output-format json` | lifecycle skills (`init`, `audit`, `dream`) are CI-runnable via headless mode |

## Detection

`detect-runtime` recognizes `agy` via: `agy --version`,
`~/.config/agy/credentials.json` or `~/.gemini/antigravity-cli/`, and
`AGY_*` env vars; `harness = antigravity`. It also **warns** when both
`gemini` and `agy` are installed — they share `~/.gemini/GEMINI.md`
(global rules), causing rule leakage (google-gemini/gemini-cli#16058,
closed "not planned").

## Subagents

Antigravity promotes subagents to a first-class feature for parallel
work. Model subagent-scoped specs under the existing per-agent
convention: `2-mind/forge/role/<subagent>/AGENTS.md` (+ optional
`rules/`). Subagents inherit the workspace `AGENTS.md` context and see
skills via `.agents/skills` (= `2-mind/forge/act/skill/`). Keep
subagent rules in the agent-local home, not workspace-wide
`3-control/rule/`, unless they apply to every agent.

## Install

`curl -fsSL https://antigravity.google/cli/install.sh | bash`
(PowerShell variant on Windows). Part of the Antigravity 2.0 platform.
