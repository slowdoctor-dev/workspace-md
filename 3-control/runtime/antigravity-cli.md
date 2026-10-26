# Antigravity CLI adapter

Runtime adapter notes for **Antigravity CLI** (`agy`) — Google's
successor to Gemini CLI. Gemini CLI stopped serving free / AI Pro /
AI Ultra accounts on **2026-06-18**; Code Assist Standard/Enterprise
keep Gemini CLI. This file is the per-workspace adapter convention
(T2); the universal mechanism lives in `runtime-flexibility.md`.

**Canonical home for the Antigravity/Gemini-transition facts.** Other
docs mention the transition briefly and point here. These are external
vendor claims, several from third-party guides — **verify before
relying**; `last_verified: 2026-10-26` (sunset confirmed via Google's
announcement + post-shutdown reporting; feature facts via secondary
sources, marked below).

| Surface | Mapping | Confidence |
|---|---|---|
| Context files | `AGENTS.md` + `GEMINI.md` both auto-loaded | official codelab + guides — no `GEMINI.md` needed when `AGENTS.md` exists |
| Skills | `.agents/skills/` → `2-mind/forge/act/skill/`; SKILL.md folders with name/description frontmatter | official codelab |
| MCP | `.agents/mcp_config.json` (workspace) / `~/.gemini/config/mcp_config.json` (user); remote servers use `serverUrl` (not `url`) — rendered from `registry.json` on demand | guides agree; `agy mcp add/list` exists for user-level config (reported ≥1.1.16) |
| Hooks | JSON hook format inherited from Gemini CLI; location reported as `.agents/hooks.json` (project) / `~/.gemini/config/hooks.json` (user) **or** `settings.json` — sources conflict | **unverified** — check `antigravity.google/docs` before rendering `cue/lifecycle.md` |
| Model | some guides document `agy --model` and `/model`; v0.1.x of this spec recorded the flag as removed — **conflicting** | **unverified**; record the observed model with `auto:` prefix in `profile.md` when not Owner-selected |
| Headless | `agy -p "<prompt>" --output-format json` | guides |
| Subagents | first-class; specs under `2-mind/forge/role/<name>/`, inherit workspace `AGENTS.md` and see `.agents/skills` | codelab + guides |

## Detection

`detect-runtime`: `agy --version`, `~/.config/agy/`, `AGY_*` env →
`harness = antigravity`. **Warns** when both `gemini` and `agy` are
installed — they share `~/.gemini/GEMINI.md` (global rules), causing
rule leakage (google-gemini/gemini-cli#16058, closed "not planned").
`model_class`: Gemini 3.x Pro → `hosted-frontier`; Flash / Flash-Lite →
`hosted-small`.

## Install

`curl -fsSL https://antigravity.google/cli/install.sh | bash`
(PowerShell variant on Windows). Part of the Antigravity 2.0 platform.

## Sources

- Google Developers Blog — Transitioning Gemini CLI to Antigravity CLI:
  <https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/>
- The New Stack (2026-06-20) — shutdown confirmed:
  <https://thenewstack.io/gemini-cli-antigravity-replacement/>
- Antigravity codelab (agents.md + skills, `.agents/` layout):
  <https://codelabs.developers.google.com/sdd-agy-cli>
- Antigravity CLI features / plugins (official):
  <https://antigravity.google/docs/cli/features/>, <https://antigravity.google/docs/plugins/>
- `~/.gemini/GEMINI.md` cross-tool collision:
  <https://github.com/google-gemini/gemini-cli/issues/16058>

`audit` flags this `last_verified` after 6 months.
