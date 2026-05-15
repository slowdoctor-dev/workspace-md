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

## Local LLM runtimes (model backends)

### Conceptual distinction from hosted CLIs

| Category | What it is | Reads `CLAUDE.md` / `AGENTS.md`? | How "behavior" is specified |
|---|---|---|---|
| **Hosted CLI** (Claude Code, Gemini CLI, Codex CLI) | An *agent runtime* — orchestrates tool use, reads instruction files, holds the agent loop. Talks to a remote LLM API. | Yes (auto-discovered) | Instruction files + settings.json |
| **Local LLM runtime** (Ollama, LM Studio, MLX) | A *model server* — serves token generation over HTTP. No agent loop, no tool use, no file discovery. | **No** (none of them auto-read instruction files) | Modelfile / preset / chat template (per request) |

Local LLM runtimes are **model backends**, not agent runtimes. They are usually combined with a hosted CLI:

> A hosted CLI (which provides the agent loop + instruction-file
> discovery) points its API endpoint at a local LLM runtime (which
> provides the actual token generation, locally and privately).

In a workspace.md workspace, both can coexist: `4-control/runtime/`
houses both the hosted CLI configs and the local backend Modelfile /
preset definitions; the hosted CLI's settings file points at the local
server's `localhost:port`.

### Common integration pattern

All three local runtimes expose an OpenAI-compatible HTTP endpoint
(`/v1/chat/completions`). Most provide an Anthropic-compatible
endpoint (`/v1/messages`) for Claude Code. Pointing a hosted CLI at a
local runtime is then a matter of environment variables or settings
fields:

| Hosted CLI | Variable / setting to point at local runtime |
|---|---|
| Claude Code | `ANTHROPIC_BASE_URL` + `ANTHROPIC_AUTH_TOKEN` |
| Gemini CLI | Custom provider via LiteLLM proxy (no native local-backend setting) |
| Codex CLI | `[model_providers.<name>]` table in `config.toml` (`base_url`, `wire_api`, `env_key`) |
| OpenAI SDK (any) | `base_url=http://localhost:<port>/v1` |

---

## Ollama

**Official source**: <https://docs.ollama.com> + <https://github.com/ollama/ollama>

### Storage and configuration

- Model store:
  - macOS / Linux user mode: `~/.ollama/models/`
  - Linux systemd service: `/usr/share/ollama/`
  - Windows: `%USERPROFILE%\.ollama\models\`
- Logs: `~/.ollama/logs/{app.log, server.log}`
- **No config file** as of 2026 — config exclusively via env vars
- Key env vars: `OLLAMA_MODELS`, `OLLAMA_HOST` (default `127.0.0.1:11434`),
  `OLLAMA_ORIGINS` (CORS), `OLLAMA_KEEP_ALIVE`, `OLLAMA_NUM_PARALLEL`,
  `OLLAMA_MAX_LOADED_MODELS`, `OLLAMA_CONTEXT_LENGTH`, `OLLAMA_MAX_QUEUE`

### Modelfile (the canonical "what model + how"definition)

Plain text declarative format. Build with `ollama create <name> -f <Modelfile>`.

```Modelfile
FROM llama3.2

PARAMETER temperature 0.7
PARAMETER num_ctx 8192

SYSTEM """
You are a focused assistant for this workspace.
Prefer concise answers. Cite sources when uncertain.
"""

TEMPLATE """{{ .System }}
User: {{ .Prompt }}
Assistant: {{ .Response }}"""

# Optional fine-tuned adapter
# ADAPTER ./my-lora.gguf
```

- Directives: `FROM` (required), `PARAMETER`, `SYSTEM`, `TEMPLATE`,
  `MESSAGE`, `ADAPTER`, `LICENSE`, `REQUIRES`
- `SYSTEM` is short-circuit instruction injection — keep under 100 words
- System prompt overridable at runtime via API `system` parameter

### HTTP API

- Server: `localhost:11434`
- Native endpoints: `/api/generate`, `/api/chat`, `/api/embed`,
  `/api/tags`, plus model management (`/api/create`, `/api/show`,
  `/api/pull`, `/api/push`, `/api/delete`, `/api/copy`)
- OpenAI-compatible: `/v1/chat/completions`, `/v1/completions`,
  `/v1/embeddings`, `/v1/models`
- Streaming by default; `"stream": false` for single-shot
- Structured output: `format: "json"` or full JSON schema in `format`

### Instruction files

- **None** — Ollama does not auto-read `AGENTS.md` / `CLAUDE.md`.
  Behavioral specification is entirely via Modelfile `SYSTEM` directive
  or runtime API `system` parameter.

### Integration as backend

- **Claude Code**: Ollama has native Anthropic-compatible endpoint.
  Set `ANTHROPIC_AUTH_TOKEN=ollama` and
  `ANTHROPIC_BASE_URL=http://localhost:11434`. Claude Code recommends
  ≥ 64 KB context for its agentic loop.
- **Gemini CLI**: requires LiteLLM proxy. Proxy translates Gemini API
  format to Ollama's. The chosen Ollama model must have a template
  that supports `tools` (e.g., Qwen 2.5 — Gemma3 templates do not).
- **OpenAI SDK / generic**: point `base_url` at `http://localhost:11434/v1`.

### Mapping to workspace.md layers

```
4-control/runtime/ollama/Modelfile          ←→ canonical Modelfile (build target)
4-control/runtime/ollama/env                ←→ env vars (loaded by systemd or shell init)
~/.ollama/models/                            (large blob store; usually NOT symlinked into workspace — keep at default path or set OLLAMA_MODELS)
4-control/external/mcp/                      (Ollama itself does not use MCP; the hosted CLI pointed at Ollama uses its own MCP config)
```

---

## LM Studio

**Official source**: <https://lmstudio.ai/docs/> + <https://github.com/lmstudio-ai>

### Storage and configuration

- Model store (preserves HuggingFace `<user>/<repo>/` structure):
  - macOS / Linux: `~/.lmstudio/models/`
  - Windows: `%USERPROFILE%\.lmstudio\models\`
- Models must sit ≥ 2 levels deep under the models dir
  (`<publisher>/<repo>/<file>.gguf`).
- Presets (system prompt + inference parameters bundled as JSON):
  - `~/.lmstudio/hub/` (macOS/Linux) or `%USERPROFILE%\.lmstudio\hub\` (Windows)
- Per-model defaults: configurable via "My Models" gear icon in GUI;
  default load settings persisted per model.

### `lms` CLI

Ships with LM Studio. Key commands:

| Command | Purpose |
|---|---|
| `lms server start [--port N] [--cors]` | Launch HTTP server (default port 1234) |
| `lms server stop` | Shut down server |
| `lms server status [--json]` | Query server state |
| `lms ls` | List downloaded models |
| `lms get <repo>` or `lms get qwen/qwen2.5-coder-32b-instruct-gguf@Q4_K_M` | Download from HuggingFace |
| `lms load <model> [--context-length N] [--gpu off\|max\|0..1] [--ttl SEC] [--identifier NAME]` | Load model into memory |
| `lms unload <model>` or `lms unload --all` | Unload |
| `lms ps` | Loaded models (process-like view) |
| `lms chat [-p PROMPT] [-s SYSTEM] [--ttl SEC] [--stats]` | Interactive or one-shot chat |
| `lms daemon up` | Run as background daemon |
| `lms link` | Manage remote LM Link inference |

### HTTP API

- Default: `localhost:1234`
- Native: `/api/v1/*` (POST `/api/v1/chat` is stateful — maintains
  history across turns; also `/api/v1/models`, `/api/v1/models/load`,
  `/api/v1/models/unload`, `/api/v1/models/download`)
- OpenAI-compatible: `/v1/chat/completions`, `/v1/completions`,
  `/v1/embeddings`, `/v1/responses`, `/v1/models`
- Anthropic-compatible: `/v1/messages` (since v0.4.1, January 2026)
- CORS: `lms server start --cors` enables; chromium browsers may need
  reverse proxy for `Access-Control-Allow-Private-Network` header
- Authentication: optional API tokens; `x-api-key` or `Authorization: Bearer <token>`

### MCP

- Native MCP host since v0.3.17. Config file: `mcp.json` (Cursor notation).
- Edit via "Program" tab → "Install > Edit mcp.json"

### Presets (system prompts)

- JSON file storing `system prompt + inference parameters`
- Stored in `~/.lmstudio/hub/`
- Shareable: copy JSON file or publish to LM Studio Hub
- Apply via GUI selection or `lms chat -s "<prompt>"` flag

### Instruction files

- **None** — LM Studio does not auto-read `AGENTS.md` / `CLAUDE.md`.
  Behavioral specification is via presets (JSON), per-model config,
  or runtime `--system-prompt`.

### Integration as backend

- **Claude Code**: set `ANTHROPIC_BASE_URL=http://localhost:1234` and
  `ANTHROPIC_AUTH_TOKEN=lmstudio`. ≥ 25 KB context recommended.
- **Codex CLI**: native integration via OpenAI-compatible
  `/v1/responses` endpoint. Run `codex --oss` pointed at the local
  server.
- **Gemini CLI**: redirect via LiteLLM proxy (same pattern as Ollama).
- **OpenAI SDK / generic**: `base_url='http://localhost:1234/v1/'`.

### MLX support

LM Studio supports MLX models natively since v0.3.4 (October 2024) on
Apple Silicon. Same chat/server semantics; faster inference per token
on M-series chips.

### Mapping to workspace.md layers

```
4-control/runtime/lmstudio/presets/<name>.json  ←→ ~/.lmstudio/hub/<name>.json
4-control/runtime/lmstudio/mcp.json             ←→ mcp.json (or embedded via "Edit mcp.json")
~/.lmstudio/models/                              (large blob store; usually kept at default)
4-control/runtime/lmstudio/env                  ←→ port and other env vars (for `lms server start`)
```

---

## MLX / mlx-lm

**Official source**: <https://github.com/ml-explore/mlx> + <https://github.com/ml-explore/mlx-lm>

### Identity

- MLX is **Apple's NumPy-like array framework** for ML on Apple
  Silicon. Not a CLI by itself — a Python/C++/Swift framework.
- `mlx-lm` is the Python package adding LLM-specific tooling: model
  loading, generation, server, LoRA training.
- Apple Silicon ONLY (M1/M2/M3/M4/M5 generations). No x86, no NVIDIA,
  no Android/iOS as of 2026.
- Unified memory architecture (no host↔device data transfer);
  composable transformations (autodiff, vectorization, graph
  optimization).

### Installation and storage

- Install: `pip install mlx-lm` (or `conda install -c conda-forge mlx-lm`)
- Model cache: `~/.cache/huggingface/hub/` (HuggingFace standard;
  overridable via `HF_HUB_CACHE` or `HF_HOME` env vars)
- Model format: Safetensors (auto-converts from PyTorch on first load)
- Recommended models: `mlx-community/<base>-<variant>-<quantization>`
  on HuggingFace (e.g., `mlx-community/Mistral-7B-Instruct-v0.3-4bit`)

### `mlx_lm` CLI

(Both `mlx_lm.<cmd>` and `mlx_lm <cmd>` supported.)

| Command | Purpose |
|---|---|
| `mlx_lm.generate --model <repo> --prompt "..."` | One-shot generation |
| `mlx_lm.server --model <repo> [--port 8080] [--adapter PATH]` | OpenAI-compat HTTP server |
| `mlx_lm.convert --hf-path <repo> --mlx-path <dir> [-q]` | Convert + quantize from HuggingFace |
| `mlx_lm.chat` | Interactive chat |
| `mlx_lm.lora` | LoRA / QLoRA fine-tuning (on-device) |

### HTTP API

- Server: `localhost:8080` (configurable)
- OpenAI-compatible: `/v1/chat/completions`, `/v1/models`
- Streaming via Server-Sent Events when `stream: true`
- Standard OpenAI fields supported: `temperature`, `top_p`, `max_tokens`,
  `repetition_penalty`, `logit_bias`, `logprobs`
- LoRA adapter loading via `--adapter` server flag

> Production note: the official docs explicitly state the server is
> **not recommended for production**. Use a reverse proxy (nginx /
> Envoy) for auth, rate limiting, monitoring before exposing
> externally.

### Configuration

- **No config file.** CLI args + env vars only.
- For reproducibility, wrap CLI commands in shell scripts or use the
  Python API directly.

### Instruction files

- **None** — MLX does not auto-read any instruction file. System
  prompts are passed via the tokenizer's `apply_chat_template` method
  programmatically, or via API `messages` array with a `system` role.
- Community proposals for `--system-message` flag and `--messages-file`
  argument are in discussion but not shipped as of May 2026.

### Integration as backend

- **OpenAI SDK / generic**: point `base_url` at
  `http://localhost:8080/v1`. Works for any OpenAI-compat client.
- **Claude Code / Anthropic-format clients**: MLX server does not have
  a native `/v1/messages` (Anthropic) endpoint. Use through LM Studio
  (which exposes MLX models via its own Anthropic-compatible endpoint)
  or wrap mlx-lm.server behind a translation proxy.
- **Through Ollama (recommended as of May 2026)**: Ollama v0.19+ uses
  MLX as its default inference engine on Apple Silicon. Adopters on
  Apple Silicon typically run Ollama (which uses MLX internally) rather
  than mlx_lm.server directly.

### MLX vs llama.cpp on Apple Silicon

| Dimension | MLX | llama.cpp (Ollama / LM Studio backend) |
|---|---|---|
| Peak throughput on Apple Silicon | Higher (15–20% on small models; narrows at 70B+) | Lower but production-grade |
| Cross-platform | Apple Silicon only | macOS, Linux, Windows |
| Model availability | Requires conversion (slight lag) | Day-one GGUF for most models |
| Fine-tuning | Native LoRA / QLoRA | Inference only |
| Production-readiness of server | Functional but "not recommended for production" | Production-grade |
| Recommended use | Research + fine-tuning + Apple-only stacks | Mixed-hardware teams; CI/CD; production |

### Mapping to workspace.md layers

```
4-control/runtime/mlx/run.sh                    (canonical launch script for `mlx_lm.server`)
4-control/runtime/mlx/system-prompt.json        (canonical messages-array file for chat template)
~/.cache/huggingface/hub/                        (model cache; kept at HuggingFace default)
4-control/runtime/mlx/lora-adapters/<name>/      (locally-trained adapter weights)
```

For most workspace.md adopters on Apple Silicon, MLX is best accessed
*through Ollama or LM Studio* (both use MLX internally on M-series
hardware). Direct mlx_lm.server use is appropriate for research,
fine-tuning, or maximum-throughput inference deployments.

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

### Hosted CLI + local backend pattern

A common deployment pairs a hosted CLI (agent runtime + instruction
discovery) with a local LLM runtime (token generation backend):

| Combination | How |
|---|---|
| Claude Code + Ollama | `ANTHROPIC_BASE_URL=http://localhost:11434`, `ANTHROPIC_AUTH_TOKEN=ollama` |
| Claude Code + LM Studio | `ANTHROPIC_BASE_URL=http://localhost:1234`, `ANTHROPIC_AUTH_TOKEN=lmstudio` |
| Codex CLI + LM Studio | `codex --oss` (uses local `/v1/responses` endpoint) |
| Codex CLI + Ollama / MLX | custom `[model_providers.<name>]` table in `~/.codex/config.toml` (`base_url=http://localhost:<port>/v1`, `wire_api="chat"`) |
| Gemini CLI + any local | LiteLLM proxy translating Gemini API to OpenAI |
| Any CLI + Apple Silicon | Use Ollama (its v0.19+ default engine on Apple Silicon is MLX) or LM Studio (native MLX since 0.3.4) |

In this pattern: `4-control/runtime/claude/` holds the hosted CLI
config; `4-control/runtime/ollama/` (or `lmstudio/`, `mlx/`) holds the
backend Modelfile / preset / launch script. The hosted CLI's
settings file references the local endpoint URL.

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

**Hosted CLIs:**
- Claude Code: <https://code.claude.com/docs/en/> (claude-directory,
  settings, mcp, hooks, sub-agents, skills, memory, permissions)
- Gemini CLI: <https://geminicli.com/docs/> +
  <https://github.com/google-gemini/gemini-cli>
- Codex CLI: <https://developers.openai.com/codex/> +
  <https://github.com/openai/codex/blob/main/docs/config.md>

**Local LLM runtimes:**
- Ollama: <https://docs.ollama.com/> + <https://github.com/ollama/ollama>
  (modelfile, api, faq, integrations/claude-code, openai-compatibility)
- LM Studio: <https://lmstudio.ai/docs/> +
  <https://github.com/lmstudio-ai> (app, cli, developer/openai-compat,
  developer/anthropic-compat, developer/rest, app/presets, app/mcp,
  blog/claudecode, integrations/codex)
- MLX / mlx-lm: <https://github.com/ml-explore/mlx> +
  <https://github.com/ml-explore/mlx-lm> +
  <https://machinelearning.apple.com/research/exploring-llms-mlx-m5>

**Standards / specs:**
- AAIF / AGENTS.md: <https://agents.md>
