# MCP — canonical external connections

LLM-agnostic MCP registry. The canonical server list lives in
`registry.json` (the `.mcp.json` format, symlinked from repo-root
`.mcp.json` for harnesses that read it — Claude Code, Cursor, others).

`registry.json` ships **intentionally empty** (`{"mcpServers":{}}`) as
the committed reference target for the symlink-alias pattern — see
`WORKSPACE.md §Native discovery paths`. Add your servers there.

## Rendered copies (harnesses with another format)

Some harnesses cannot read `.mcp.json`; their config is **rendered on
demand** from `registry.json` when the first server is registered, and
`audit` keeps the copies in sync (class 8, TRUST-2 — MCP configs
execute, so renders are T2):

| Harness | Rendered file | Transform |
|---|---|---|
| Antigravity CLI | `3-control/external/mcp/mcp_config.json`, symlinked as `.agents/mcp_config.json` | remote servers: `url` → `serverUrl`; stdio servers unchanged |
| Codex CLI | `[mcp_servers.<name>]` tables in `.codex/config.toml` | JSON → TOML; keys per Codex docs |

Each rendered file carries a `rendered_from: registry.json @ <sha>`
note (comment or sibling `.rendered` file).

Self-owned MCP servers carry source + config together in
`3-control/external/mcp/<server-name>/` (see
`PRINCIPLE.md §External connections`).
