# Codex CLI adapter

Per-workspace adapter notes for **OpenAI Codex CLI** (T2). Vendor
facts — verify before relying; `developers.openai.com/codex` is the
source of truth.

`last_verified: 2026-10-26` (official docs for skills; hooks and
memories from secondary sources — confirm against the docs)

| Surface | Mapping | Notes |
|---|---|---|
| Entry | `AGENTS.md` read natively — `~/.codex/AGENTS.md` (global) → repo root → nested; `AGENTS.override.md` takes precedence | combined size cap `project_doc_max_bytes` (default ≈32 KiB, configurable) — keep the card small |
| Skills | `.agents/skills/` scanned from cwd up to the repo root; also `$HOME/.agents/skills/`; metadata loaded first, body on selection | `.agents/skills` → `2-mind/forge/act/skill/` |
| Hooks | GA 2026-05: `.codex/hooks.json` or inline in `.codex/config.toml`; events incl. `SessionStart` (source startup/resume/clear), `Stop`, `PreCompact`, `PostCompact` | render from `2-mind/forge/cue/lifecycle.md` (T2) |
| Memories | `~/.codex/memories/` — background session summaries; off by default (reported) | T0 inbox: `dream` ingests with `(auto-memory codex <date>)`; watch for over-personalization (R3) |
| MCP | `[mcp_servers]` tables in `.codex/config.toml` | **rendered** from `3-control/external/mcp/registry.json` (format differs from `.mcp.json`) |
| Subagents / worktrees | subagents run in auto-created worktrees | R5 applies |
| Headless | `codex exec`; cloud tasks | T2 via PR channel; slug `cloud` / `ci` |

## Detection

`detect-runtime`: `CODEX_PROJECT_DIR` env or `.codex/config.toml` →
`harness = codex-cli`; model from self-identification (GPT-5.x family,
≈1M context). `model_class`: non-mini → `hosted-frontier`; `mini` /
`nano` → `hosted-small`.
