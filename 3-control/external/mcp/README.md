# MCP — canonical external connections

LLM-agnostic MCP registry. The canonical server list lives in
`registry.json` (the `.mcp.json` standard, symlinked from repo-root
`.mcp.json`), used by Claude Code / Codex / Gemini CLI.

`registry.json` ships **intentionally empty** (`{"mcpServers":{}}`) as
the committed reference target for the symlink-alias pattern — see
`WORKSPACE.md §Layout`. Add your servers there.

## Antigravity CLI (`mcp_config.json`)

Antigravity CLI reads `.agents/mcp_config.json` and renames the
remote-server field `url` → `serverUrl` (copied Gemini configs **fail
silently on remote servers** otherwise). To avoid shipping a second
empty config (sync burden before any content exists), `mcp_config.json`
is **rendered on demand**, not pre-created:

- When you register your first server in `registry.json`, render
  `3-control/external/mcp/mcp_config.json` from it (identical, with
  `url` → `serverUrl` on remote/URL servers; `stdio`/command servers
  unchanged) and symlink `.agents/mcp_config.json` → it.
- `audit`'s duplicate/contradiction scan then keeps the two in sync.

Self-owned MCP servers carry source + config together in
`3-control/external/mcp/<server-name>/` (see
`PRINCIPLE.md §External connections`).
