# Runtime integration

How LLM runtimes integrate with a workspace.md-conformant workspace.
Specifications below are verified against official documentation as of
May 2026; citations at the end of each runtime's section.

The goal: when a runtime is attached to the workspace, the runtime
(and the agent inside it) finds its instructions, configs, hooks, and
MCP servers without ambiguity. This document is the entry point for
that.

---

## Universal pattern (all runtimes)

### Entry point — root `AGENTS.md`

Every workspace.md-conformant workspace has `AGENTS.md` at the
repository root, following the [agents.md](https://agents.md)
convention. This is the single source of truth read by every runtime.

Per-runtime adaptation at the workspace root:

| Runtime | Auto-reads at workspace root | Adaptation |
|---|---|---|
| **Codex CLI** | `AGENTS.md` (native) | none — works as-is |
| **Claude Code** | `CLAUDE.md` (also `AGENTS.md` via `@AGENTS.md` import) | symlink `CLAUDE.md → AGENTS.md`, OR put `@AGENTS.md` inside a thin `CLAUDE.md` |
| **Gemini CLI** | `GEMINI.md` (default; AGENTS.md by config) | symlink `GEMINI.md → AGENTS.md`, OR set `context.fileName: ["AGENTS.md", "GEMINI.md"]` in `~/.gemini/settings.json`, OR `@AGENTS.md` import inside `GEMINI.md` |

### Hierarchical instruction loading

All three runtimes walk the directory tree and load instruction files
hierarchically. Closer-to-cwd content overrides farther content
because it appears later in the prompt context.

| Runtime | Global | Project root | Subdirectory |
|---|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` | `./CLAUDE.md` or `./.claude/CLAUDE.md` | walks up parent dirs |
| Gemini CLI | `~/.gemini/GEMINI.md` | workspace `./GEMINI.md` | JIT discovery on file access |
| Codex CLI | `~/.codex/AGENTS.md` (+ `AGENTS.override.md`) | from repo root down to cwd | one file per directory along path |

### Symlink scheme — canonical and symlinked

Canonical config lives inside the workspace at
`4-control/runtime/<runtime-name>/`. Symlinks bind canonical files to
each runtime's expected location:

```
~/.claude/  ←→  4-control/runtime/claude/
~/.gemini/  ←→  4-control/runtime/gemini/
~/.codex/   ←→  4-control/runtime/codex/
```

Editing the canonical file in the workspace updates every runtime view.
Per-runtime drift is prevented by construction.

**Secrets never live in `runtime/`.** Use the runtime's own credential
mechanism, environment variables outside `.env`, or
`~/.config/<workspace>-secrets/`.

---

## Claude Code

**Official source**: <https://code.claude.com/docs/en/> (especially
`claude-directory`, `settings`, `mcp`, `hooks`, `sub-agents`, `skills`,
`memory`, `permissions`)

### Instruction file

- Auto-reads `CLAUDE.md` from the working directory, walking up parent
  directories, plus `~/.claude/CLAUDE.md` at the user level.
- Project-scoped `./.claude/CLAUDE.md` also recognized.
- Personal override: `./CLAUDE.local.md` (gitignored by convention).
- Import syntax: `@path/to/file` includes other markdown files; recursive
  up to 5 hops.
- Recommended length: under 200 lines for best adherence.
- AAIF interop: place `@AGENTS.md` inside a thin `CLAUDE.md`, or symlink
  `CLAUDE.md → AGENTS.md`.
- Rules folder: `.claude/rules/<topic>.md` with optional YAML
  `paths: [...]` frontmatter for path-scoped activation.

### Settings file

- User: `~/.claude/settings.json`
- Project: `<repo>/.claude/settings.json` (committed)
- Local: `<repo>/.claude/settings.local.json` (gitignored)
- Managed (system): `/etc/claude-code/` (Linux) or
  `/Library/Application Support/ClaudeCode/` (macOS) or
  `HKLM\SOFTWARE\Policies\ClaudeCode` (Windows)
- Precedence (high → low): managed → CLI args → local → project → user
- Key fields: `permissions`, `hooks`, `env`, `model`, `statusLine`,
  `defaultMode`, `allowedMcpServers` (managed only), `allowManagedHooksOnly`

### MCP servers

- Project scope: `<repo>/.mcp.json` (committed)
- Local / user scope: `~/.claude.json` `mcpServers` field
- Format: JSON with `mcpServers` key

```json
{
  "mcpServers": {
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "${WORKSPACE_PATH}"]
    },
    "stripe": {
      "type": "http",
      "url": "https://mcp.stripe.com"
    }
  }
}
```

- Env var expansion: `${VAR}` and `${VAR:-default}` supported
- CLI: `claude mcp add --transport <stdio|http> --scope <local|project|user>`

### Subagents

- Project: `.claude/agents/<name>.md`
- User: `~/.claude/agents/<name>.md`
- Format: markdown with YAML frontmatter
- Required: `name`, `description`
- Optional: `tools`, `disallowedTools`, `model`, `permissionMode`,
  `mcpServers`, `hooks`, `memory`, `background`, `effort`, `isolation`,
  `initialPrompt`, `maxTurns`, `skills`, `color`

### Skills (preferred over commands)

- Project: `.claude/skills/<name>/SKILL.md`
- User: `~/.claude/skills/<name>/SKILL.md`
- Frontmatter: `name`, `description`, `allowed-tools`, `user-invocable`,
  `disable-model-invocation`, `model`
- Can include supporting files (templates, scripts, references)
- Invoked explicitly (`/<name>`) or autonomously by Claude

### Hooks

- Defined in `settings.json` `hooks` field
- 12+ events: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`,
  `PostToolBatch`, `Notification`, `UserPromptSubmit`,
  `UserPromptExpansion`, `Stop`, `SubagentStart`, `SubagentStop`,
  `SessionStart`, `Setup`, etc.
- Input: JSON via stdin (event-specific fields + `session_id`, `cwd`,
  `hook_event_name`)
- Output: exit code 0 (success; stdout parsed as JSON) or 2 (block;
  stderr returned to Claude)
- `PreToolUse` is the only blocking hook; returns
  `permissionDecision: allow|deny|ask|defer`

### Mapping to workspace.md layers

```
4-control/runtime/claude/CLAUDE.md       ←→ ~/.claude/CLAUDE.md
                                          (or symlink to root AGENTS.md)
4-control/runtime/claude/settings.json   ←→ ~/.claude/settings.json
4-control/runtime/claude/agents/         ←→ ~/.claude/agents/
4-control/runtime/claude/skills/         ←→ ~/.claude/skills/
3-playbook/cue/hooks/<script>.sh         (referenced from settings.json)
4-control/external/mcp/claude.json       ←→ <repo>/.mcp.json
```

---

## Gemini CLI

**Official source**: <https://geminicli.com/docs/> +
<https://github.com/google-gemini/gemini-cli>

### Instruction file

- Default name: `GEMINI.md`
- Loading: hierarchical — `~/.gemini/GEMINI.md` (global) → workspace
  directories → JIT discovery when reading subdirs
- Customizable filename: set `context.fileName` in settings.json (e.g.,
  `["AGENTS.md", "GEMINI.md"]`)
- Import syntax: `@file.md` (relative or absolute)
- Commands: `/memory` shows loaded files; `/memory reload` re-scans
- AAIF interop: AGENTS.md not auto-read by default; configure via
  `context.fileName` or `@AGENTS.md` import inside GEMINI.md

### Settings file

- User: `~/.gemini/settings.json`
- Project: `<repo>/.gemini/settings.json`
- System: `/etc/gemini-cli/settings.json` (platform-specific paths
  exist; overridable via `GEMINI_CLI_SYSTEM_SETTINGS_PATH`)
- 7-level precedence (low → high): hardcoded → system defaults → user →
  project → system settings → env → CLI args
- Field categories: `general`, `output`, `model`, `context`, `tools`,
  `ui`, `skills`, `mcpServers`
- Env var expansion: `$VAR` and `${VAR}` supported

### MCP servers

- Configured in `settings.json` `mcpServers` key
- 3 transports: stdio (`command`/`args`), `sseUrl`, `httpUrl`
- Format: JSON inside settings.json

```json
{
  "mcpServers": {
    "myserver": {
      "command": "npx",
      "args": ["-y", "mcp-server"],
      "env": {"API_KEY": "${API_KEY}"},
      "tools": null,
      "resources": null
    }
  },
  "mcp": {
    "allowed": ["myserver"],
    "excluded": []
  }
}
```

- Environment sanitization: sensitive vars redacted by default; explicit
  `env` object passes required ones

### Custom commands

- User: `~/.gemini/commands/<name>.toml`
- Project: `<repo>/.gemini/commands/<name>.toml`
- Format: TOML
- Required: `prompt`; Optional: `description`
- Namespacing: subdirectory `/` → `:` (e.g.,
  `git/commit.toml` → `/git:commit`)
- Args: `{{args}}` placeholder OR appended at end if absent
- Shell exec: `!{cmd}` syntax (prompts for confirmation)

### Subagents

- User: `~/.gemini/agents/<name>.md`
- Project: `<repo>/.gemini/agents/<name>.md`
- Format: markdown with YAML frontmatter
- Invocation: automatic delegation or `@agent-name`
- Built-in: `generalist`, `cli_help`, `codebase_investigator`

### Hooks (synchronous)

- Defined in `settings.json`; merged from project + user + system + extensions
- 10 events: `SessionStart`, `SessionEnd`, `BeforeAgent`, `AfterAgent`,
  `BeforeModel`, `AfterModel`, `BeforeToolSelection`, `BeforeTool`,
  `AfterTool`, `PreCompress`, `Notification`
- Required fields: `type: "command"`, `command: "<shell>"`
- Optional: `name`, `timeout` (ms, default 60000), `description`,
  `matcher` (regex for tool events, exact string for lifecycle)
- Exit codes: 0 (success; stdout parsed as JSON), 2 (system block; stderr is reason), other (warning)

### Mapping to workspace.md layers

```
4-control/runtime/gemini/GEMINI.md       ←→ ~/.gemini/GEMINI.md
                                          (or symlink to root AGENTS.md)
4-control/runtime/gemini/settings.json   ←→ ~/.gemini/settings.json
4-control/runtime/gemini/commands/       ←→ ~/.gemini/commands/
4-control/runtime/gemini/agents/         ←→ ~/.gemini/agents/
3-playbook/cue/hooks/<script>.sh         (referenced from settings.json)
4-control/external/mcp/gemini.json       (or embedded in gemini settings.json)
```

---

## Codex CLI

**Official source**: <https://developers.openai.com/codex/> +
<https://github.com/openai/codex>

### Instruction file

- Auto-reads `AGENTS.md` natively (AAIF native).
- Override file: `AGENTS.override.md` takes precedence in the same dir
  (skipped if empty).
- Loading: global `~/.codex/AGENTS.md` → project (from repo root down to
  cwd, one file per dir) → concatenated in order
- Closer-to-cwd content appears later → overrides earlier content.
- Size limit: 32 KiB default (`project_doc_max_bytes`), increasable
- Fallback names: `project_doc_fallback_filenames` config key (array)
- `$CODEX_HOME` env var overrides default `~/.codex` location

### Settings file

- User: `~/.codex/config.toml` (TOML format)
- Project: `<repo>/.codex/config.toml` (loaded only when project is
  **trusted** — defense against malicious checked-in configs)
- System: `/etc/codex/config.toml` (Unix) or
  `%ProgramData%\OpenAI\Codex\config.toml` (Windows)
- Precedence (high → low): CLI flags → profile → project → user →
  system → defaults
- Key fields: `model`, `model_reasoning_effort`, `approval_policy`,
  `sandbox_mode`, `web_search`, `shell_environment_policy`, `log_dir`,
  `default_permissions`
- Enterprise: `requirements.toml` (admin-enforced; constrains
  `allowed_approval_policies`, `allowed_sandbox_modes`, etc.)

### MCP servers

- Configured in `config.toml` `[mcp_servers]` table
- Format: TOML

```toml
[mcp_servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "/path"]
env = { "API_KEY" = "${API_KEY}" }

[mcp_servers.stripe]
url = "https://mcp.stripe.com"
```

- Remote HTTP servers supported via URL endpoint
- CLI: `codex mcp add`, `list`, `get`, `remove`, `login`, `logout`

### Skills (preferred over deprecated `~/.codex/prompts/`)

- Repo scope: `.agents/skills/<name>/SKILL.md` (walks from cwd up to repo
  root)
- User scope: `$HOME/.agents/skills/`
- Admin scope: `/etc/codex/skills/`
- System scope: bundled with Codex
- Progressive disclosure: only name + description + path loaded at
  startup; SKILL.md body loaded on selection

### Hooks

- Locations:
  - User: `~/.codex/hooks.json` or `~/.codex/config.toml` `[hooks]`
  - Project: `<repo>/.codex/hooks.json` or `<repo>/.codex/config.toml`
    `[hooks]`
- Structure: event → matcher group → hook handlers
- Events include: `PreToolUse`, `PostToolUse`, `Stop`, others
- Working dir for hook execution: session cwd (for repo-local hooks,
  resolve paths from Git root)

### Approval policy + sandbox mode (two-layer security)

- Sandbox modes:
  - `read-only` — no file edits or command execution without approval
  - `workspace-write` (default for auto preset) — edits and routine
    commands within workspace boundary
  - `danger-full-access` — no boundary (use only in isolated runners)
- Approval policies:
  - `untrusted` — prompt for every action
  - `on-request` — prompt only when crossing sandbox boundary
  - `never` — fully autonomous (CI only)
- Platform sandbox:
  - macOS: Seatbelt
  - Linux: `bwrap` + `seccomp` (WSL1 unsupported as of v0.115; WSL2 OK)
  - Windows: native sandbox (`elevated` or `unelevated`)
- Protected paths within writable roots (always read-only):
  `.git`, `.agents`, `.codex`

### Command rules

- Files: `~/.codex/rules/<name>.rules` or `<repo>/.codex/rules/`
- Per-rule fields: `pattern`, `decision` (`allow`/`prompt`/`forbidden`),
  `justification`, `match`, `not_match`
- Conflict: most restrictive decision wins
  (`forbidden` > `prompt` > `allow`)
- Multi-command scripts parsed via tree-sitter, evaluated per command

### Non-interactive (CI / scripts)

- Command: `codex exec "<prompt>"` or `cat prompt.txt | codex exec -`
- Default sandbox in `exec`: `read-only`; pass `--sandbox workspace-write`
  to enable edits
- `--ask-for-approval never` for fully autonomous runs
- `--json` for JSONL event stream
- GitHub Actions: `openai/codex-action`

### Mapping to workspace.md layers

```
4-control/runtime/codex/AGENTS.md         ←→ ~/.codex/AGENTS.md
                                            (or root AGENTS.md served directly)
4-control/runtime/codex/AGENTS.override.md ←→ ~/.codex/AGENTS.override.md (optional)
4-control/runtime/codex/config.toml       ←→ ~/.codex/config.toml
3-playbook/cue/hooks/<script>             (referenced from config.toml [hooks] or hooks.json)
4-control/external/mcp/codex.toml         ←→ extracted [mcp_servers] section
                                            (or embedded directly in config.toml)
```

---

## Cross-runtime notes

### When you have multiple runtimes attached

- All three can coexist by symlinking each runtime-specific instruction
  file to root `AGENTS.md`:

      CLAUDE.md  → AGENTS.md
      GEMINI.md  → AGENTS.md
      AGENTS.md  (Codex reads directly)

- **MCP configs are format-incompatible**: Claude/Gemini use JSON,
  Codex uses TOML. Maintain per-runtime files in
  `4-control/external/mcp/`. Do not attempt a single canonical MCP file
  shared across all three.
- **Subagent definitions are per-runtime**. Claude's `.claude/agents/`,
  Gemini's `.gemini/agents/`, and Codex's skill system are distinct
  artifacts. Don't expect cross-runtime portability.
- **Skills format**: Claude (`.claude/skills/<name>/SKILL.md`) and Codex
  (`.agents/skills/<name>/SKILL.md`) are similar at the file level;
  the directory location differs. Gemini's skill system is emerging.
- **Hook formats differ**: Claude has the most events (12+), Gemini has
  10, Codex has fewer. Hooks do not port across runtimes without rewrite.

### Recommended attachment sequence

1. Pick your primary runtime (usually the one you use daily).
2. Run the symlink commands in
   `2-mind/factory/getting-started.md §3` for that runtime.
3. Verify with `<runtime> --version` and
   `readlink ~/.<runtime>/<file>`.
4. Add subagents and skills as needed (`<runtime>/agents/` or
   `<runtime>/skills/`).
5. Add MCP servers using the runtime-specific format.
6. Add hooks if the runtime supports them.
7. Repeat for additional runtimes.

### What lives where (cross-cutting cheat sheet)

| Concept | workspace.md location |
|---|---|
| Universal agent instructions (any runtime) | root `AGENTS.md` |
| Per-runtime instructions (read by that runtime) | `4-control/runtime/<name>/AGENTS.md` or symlinked CLAUDE/GEMINI/AGENTS at root |
| Runtime settings (canonical) | `4-control/runtime/<name>/settings.<ext>` |
| Subagent definitions (canonical) | `4-control/runtime/<name>/agents/` (and/or `3-playbook/role/<agent>/`) |
| Skills (canonical) | `4-control/runtime/<name>/skills/` (and/or `3-playbook/act/skill/<name>/`) |
| Hook scripts (executable code) | `3-playbook/cue/hooks/` |
| MCP servers (configs) | `4-control/external/mcp/<runtime>.<ext>` |
| Secrets | **outside** workspace |

---

## Sources (verified May 2026)

- Claude Code: <https://code.claude.com/docs/en/> (claude-directory,
  settings, mcp, hooks, sub-agents, skills, memory, permissions)
- Gemini CLI: <https://geminicli.com/docs/> +
  <https://github.com/google-gemini/gemini-cli>
- Codex CLI: <https://developers.openai.com/codex/> +
  <https://github.com/openai/codex/blob/main/docs/config.md>
- AAIF / AGENTS.md spec: <https://agents.md>
