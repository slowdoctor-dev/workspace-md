# MCP — canonical external connections

LLM-agnostic MCP registry. Two rendered forms of the same servers; the
canonical content is identical, only the runtime-native shape differs.

| File | For | Remote-server field |
|---|---|---|
| `registry.json` | Claude Code / Codex / Gemini CLI (the `.mcp.json` standard) — symlinked from repo-root `.mcp.json` | `url` |
| `mcp_config.json` | **Antigravity CLI** — symlinked from repo-root `.agents/mcp_config.json` | `serverUrl` |

**Why two files.** Antigravity CLI moved MCP out of inline
`settings.json` into a dedicated `mcp_config.json` and renamed the
remote-server field `url` → `serverUrl`. Copied Gemini CLI configs
**fail silently on remote servers** if the field is not renamed.
Keeping a separate rendered file is the cleanest way to honor the
*one canonical home* value without the rename corrupting the standard
form.

**Sync discipline.** When you add/edit a server, update both files:
the only difference is the `url` ↔ `serverUrl` key on remote (URL)
servers. `stdio`/command servers are identical in both. `audit`'s
duplicate/contradiction scan flags drift between them. (Both currently
empty — no servers registered.)
