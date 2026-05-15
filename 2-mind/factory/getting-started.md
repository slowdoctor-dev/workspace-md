# Getting started

A walkthrough for adopting workspace.md as your own workspace.

## 0. Pick your adoption path

### Path A — clone this repo as starter template

Best when you want our skeleton + principle.md + helper docs immediately.

    git clone <this-repo>.git my-workspace
    cd my-workspace
    rm -rf .git
    git init -q

(Continue with step 1 below.)

### Path B — apply the spec manually to your own repo

Best when you have an existing repo and want to retrofit the structure
without inheriting our files.

    cd <your-existing-repo>
    mkdir -p 0-storage 1-active \
             2-mind/{atelier,factory} \
             3-playbook/{role,cue,act/{skill,script}} \
             4-control/{principle,runtime,external,rule}
    touch 0-storage/.gitkeep 1-active/.gitkeep \
          2-mind/{atelier,factory}/.gitkeep \
          3-playbook/{role,cue,act/{skill,script}}/.gitkeep \
          4-control/{principle,runtime,external,rule}/.gitkeep
    curl -sL <raw-url>/WORKSPACE.md > WORKSPACE.md
    curl -sL <raw-url>/AGENTS.md.example > AGENTS.md   # optional

(Skip step 2; jump to step 3.)

## 1. Replace spec-repo-only files (Path A only)

These describe THIS spec repo, not your workspace. Replace, remove, or
customize:

| File | Action | Template below |
|---|---|---|
| `README.md` | **Replace** | §1.1 |
| `LICENSE` | **Replace** with your license | §1.2 |
| `AGENTS.md` | **Replace** | §1.3 |
| `4-control/rule/contribution.md` | **Delete** or replace | §1.4 |
| `2-mind/factory/version-log.md` | **Delete** or repurpose | — |
| `2-mind/factory/getting-started.md` (this file) | **Delete** after onboarding | — |

Files to keep:

| File | Action |
|---|---|
| `WORKSPACE.md` | **Keep** as your spec reference |
| `4-control/principle/principle.md` | **Keep operational section**; delete "Spec-evolution principles" section |
| All `.gitkeep` files | Keep until you fill the folder |

### 1.1 README.md template

    # <your-workspace>

    Brief description of what this workspace is and who uses it.

    Conforms to [workspace.md](https://github.com/<author>/workspace-md) v0.1.

    ## Layout

    See `WORKSPACE.md`.

    ## Getting around

    - `2-mind/atelier/<...>.md` — declared values / brand / persona
    - `3-playbook/role/<...>` — agent specs
    - `4-control/principle/principle.md` — operating principles

### 1.2 LICENSE selection

Pick what fits your workspace:

- **MIT** — permissive, widely understood
- **Apache 2.0** — permissive + patent grant
- **CC-BY-SA 4.0** — for documentation/content workspaces (this spec uses this)
- **Proprietary** — `Copyright (c) <year> <holder>. All rights reserved.`
- **None** — delete the LICENSE file (full copyright by default; not recommended for public repos)

### 1.3 AGENTS.md template

    # AGENTS.md

    <one-line workspace description>

    ## Reading order

    1. `README.md`
    2. `WORKSPACE.md`
    3. `4-control/principle/principle.md`
    4. `<your workspace-specific docs>`

    ## Conventions

    - Vocabulary: <user-defined>
    - Filename: `{YYYY-MM-DD}_{slug}.md`
    - Rule scope: see `WORKSPACE.md` §Rules and principles

### 1.4 contribution.md template (optional)

Delete `4-control/rule/contribution.md` if your workspace is private.
For shared workspaces:

    # Contribution rules

    ## Process
    - <how proposals are reviewed>

    ## Versioning
    - <your scheme>

## 2. (Skipped if Path B)

## 3. Attach your first runtime

### 3.0 Where each runtime's config lives

| Runtime category | Where configs live | Why |
|---|---|---|
| **Hosted CLI** (Claude Code / Codex / Gemini) | Native: `<repo>/.claude/`, `<repo>/.codex/`, `<repo>/.gemini/` at repo root — committed directly | Each CLI auto-discovers its own location; using native paths avoids symlink fragility |
| **External connections** (MCP, OpenAPI, webhook) | LLM-agnostic canonical: `4-control/external/` | Same MCP server is conceptually identical regardless of which runtime calls it |
| **Local LLM backends** (Ollama / LM Studio / MLX) | Workspace-defined canonical: `4-control/runtime/<name>/` | These runtimes have no native repo-level convention; the workspace creates one |

**Running `claude` / `codex` / `gemini` at the workspace root** auto-loads `<repo>/.<runtime>/settings.json` (or `.codex/config.toml`). Path A clones include empty placeholder files at these paths; fill them in directly. No symlinks, no bootstrap step.

The only symlinks committed to the spec repo are:

- `CLAUDE.md → AGENTS.md` (Claude Code reads CLAUDE.md natively; AAIF sibling pattern)
- `GEMINI.md → AGENTS.md` (Gemini CLI reads GEMINI.md natively; AAIF sibling pattern; also set `context.fileName: ["AGENTS.md", "GEMINI.md"]` in Gemini settings if you want both names recognized)
- `.mcp.json → 4-control/external/mcp/registry.json` (LLM-agnostic MCP server registry; JSON format coincides with Claude's native schema, enabling the direct symlink. Codex/Gemini consume the same registry via merge into their native configs.)

**Codex CLI note**: Codex loads project-level `.codex/config.toml` only when the project is marked *trusted*. First invocation at this repo prompts for trust (security feature against malicious checked-in configs).

### 3.1 Claude Code

Edit at workspace root:

- `.claude/settings.json` — project-level settings (permissions, hooks,
  env, model, etc.)
- `.claude/agents/<name>.md` — subagent definitions (markdown + YAML
  frontmatter)
- `.claude/skills/<name>/SKILL.md` — reusable skills with optional
  supporting files
- `.mcp.json` (symlink to `4-control/external/mcp/registry.json`) — MCP
  server list; edit the symlink target directly

Hook scripts referenced from `.claude/settings.json` live at
`3-playbook/cue/hooks/` (executable code = act/script, but triggers are
in cue per WORKSPACE.md spec).

Verify after editing:

    claude --version
    # In Claude Code, `/memory` lists loaded CLAUDE.md / settings paths.

### 3.2 Gemini CLI

Edit at workspace root:

- `.gemini/settings.json` — project-level settings (MCP `mcpServers`
  key lives inside)
- `.gemini/commands/<name>.toml` — custom slash commands
- `.gemini/agents/<name>.md` — subagents

Recommended setting to recognize both `AGENTS.md` and `GEMINI.md`:

    {
      "context": {
        "fileName": ["AGENTS.md", "GEMINI.md"]
      }
    }

Gemini's MCP config is embedded in `settings.json` `mcpServers` key.
For LLM-agnostic management, keep
`4-control/external/mcp/gemini.json` as the canonical reference and
merge changes into `.gemini/settings.json` manually (or via the
future `mcp-sync.sh`).

Verify:

    gemini --version
    # In Gemini CLI, `/memory` lists loaded GEMINI.md / AGENTS.md.

### 3.3 Codex CLI

Edit at workspace root:

- `.codex/config.toml` — project-level config (MCP `[mcp_servers]`
  table lives inside)
- (Hooks: in `[hooks]` table inside config.toml, or separate
  `hooks.json` per Codex docs)

Codex's MCP is embedded in `config.toml` `[mcp_servers]` table. For
LLM-agnostic management, keep `4-control/external/mcp/codex.toml` as
the canonical reference and merge into `.codex/config.toml`
`[mcp_servers]` section manually.

**Trust on first run**: Codex prompts to trust this project on first
invocation; approve to load project-level `.codex/config.toml`.

Verify:

    codex --version
    codex status        # shows trust + active config layers

### 3.4 Local LLM backends (Ollama / LM Studio / MLX)

Local LLM runtimes do not auto-discover `<repo>/.<name>/` — there is no
project-level convenience comparable to the hosted CLIs. Workspace.md
bridges this with bootstrap scripts in `3-playbook/act/script/`.

**Ollama:**

    # 1. Write your canonical Modelfile
    mkdir -p 4-control/runtime/ollama
    cat > 4-control/runtime/ollama/Modelfile <<'EOF'
    FROM llama3.1
    PARAMETER temperature 0.7
    SYSTEM """
    You are a focused assistant for this workspace.
    """
    EOF

    # 2. Run the bootstrap script (builds the model and starts the server)
    ./3-playbook/act/script/ollama-up.sh my-llama

    # OpenAI-compat endpoint: http://localhost:11434/v1
    # Anthropic-compat endpoint (Claude Code): http://localhost:11434

**LM Studio:**

    # Run the bootstrap script (starts server, optionally loads a model)
    ./3-playbook/act/script/lmstudio-up.sh "qwen/qwen2.5-coder-32b-instruct-gguf" 1234

    # Workspace presets at 4-control/runtime/lmstudio/presets/*.json
    # MCP config at 4-control/runtime/lmstudio/mcp.json
    # OpenAI-compat: http://localhost:1234/v1
    # Anthropic-compat: http://localhost:1234

**MLX (Apple Silicon):**

For most adopters, access MLX through Ollama (v0.19+ default engine on
Apple Silicon) or LM Studio (native MLX since v0.3.4). Direct
`mlx_lm.server` use is appropriate for research and fine-tuning:

    pip install mlx-lm
    mlx_lm.server --model mlx-community/Mistral-7B-Instruct-v0.3-4bit --port 8080
    # OpenAI-compat at http://localhost:8080/v1 (no Anthropic-compat)

### 3.5 Platform and security notes

- **Symlinks** in this spec are limited to three: `CLAUDE.md`,
  `GEMINI.md` → `AGENTS.md`, and `.mcp.json` → canonical Claude MCP.
  All three are git-tracked. On macOS / Linux / WSL they work out of
  the box. On Windows native, `git config --global core.symlinks true`
  + admin terminal (or PowerShell `New-Item -ItemType SymbolicLink`)
  may be needed for them to materialize correctly after clone.
- **Secrets never go inside the workspace.** Use the runtime's own
  credential mechanism, environment variables outside `.env`, or
  `~/.config/<workspace>-secrets/`.

### 3.6 Verify

    # Runtime starts and discovers project config
    claude --version    # then in Claude Code: `/memory` to confirm CLAUDE.md loaded
    gemini --version    # then in Gemini CLI: `/memory`
    codex status        # shows trust state and active config layers
    ollama list         # if Ollama running

## 4. Add your first content (with examples)

Each layer has a typical first file. Examples below are minimum-viable
shapes you can copy and adapt.

### 4.1 First atelier file

`2-mind/atelier/<stance>.md` — user-authored stance, kept verbatim.

    ---
    # Workspace voice

    Direct over polite. Concrete over abstract. Numbers when available.

    ## Vocabulary preferences

    - "user" not "customer"
    - "agent" not "AI assistant"

    ## Things we don't do

    - No marketing fluff.
    - No fabricated examples.

### 4.2 First factory file

`2-mind/factory/<topic>-notes.md` — agent-maintained synthesis.

    ---
    # Notes — <topic>

    > Maintained by: agent. Audited: <date>.

    ## Sources
    - <link / file path>

    ## Synthesis
    <bullet observations the agent collected>

    ## Open questions
    <items needing user audit>

### 4.3 First agent spec

`3-playbook/role/<agent>/AGENTS.md` — agent's behavioral spec.

    ---
    # <agent-name>

    ## Scope
    <one-line description of what this agent handles>

    ## Tools
    <whitelist; format depends on runtime>

    ## System prompt
    <the prompt the runtime gives this agent>

    ## Invocation conditions
    <when this agent is spawned vs. another>

    ## Last reviewed
    <date>

### 4.4 First skill

`3-playbook/act/skill/<task>/SKILL.md` — natural-language procedure.

    ---
    # <task-name>

    ## When to use
    <trigger description>

    ## Steps

    1. <first step in natural language>
    2. <second step>
    3. <verification>

    ## Done criteria
    <how the agent knows it's complete>

### 4.5 First rule

`4-control/rule/<topic>.md` — enforceable workspace constraint.

    ---
    # <topic>

    ## Rule
    <one-line constraint>

    ## Rationale
    <why this rule exists>

    ## Scope
    <which layers / which agents this binds>

    ## Enforcement
    <hook, lint, or convention>

### 4.6 Adding your own principles

`4-control/principle/principle.md` (kept from spec) covers
*operational principles* universal across workspaces. Add your own
workspace's orientation alongside:

- **Append**: add sections to the existing `principle.md` under a new
  heading `## <your workspace> principles`.
- **Or split**: create `4-control/principle/<your-workspace>.md`
  alongside the operational one.

## 5. Attach an MCP server (optional)

### 5.1 Self-owned MCP server (you maintain the code)

    mkdir -p 4-control/external/mcp/my-server
    cd 4-control/external/mcp/my-server
    # Initialize your MCP server here (Node, Python, etc.)
    npm init -y
    # Source code + package.json + README.md live in this folder.

### 5.2 3rd-party MCP server (referenced by config only)

Format depends on your runtime. For Claude Code:

    cat > 4-control/external/mcp/registry.json <<'EOF'
    {
      "mcpServers": {
        "filesystem": {
          "command": "npx",
          "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"]
        }
      }
    }
    EOF
    # Import into Claude Code:
    ln -sf "$(pwd)/4-control/external/mcp/registry.json" 4-control/runtime/claude/mcp.json

For Gemini / Codex / others: consult the runtime's MCP docs and follow
the same canonical-and-symlinked pattern.

## 6. Add a hook (optional)

Hooks live in `3-playbook/cue/hooks/`. Implementation is
runtime-specific.

### 6.1 Claude Code example (PreToolUse hook on Write)

    mkdir -p 3-playbook/cue/hooks
    cat > 3-playbook/cue/hooks/block-secrets-write.sh <<'EOF'
    #!/usr/bin/env bash
    # Block writes containing common secret patterns.
    set -e
    input=$(cat)
    if echo "$input" | grep -qE '(AKIA[0-9A-Z]{16}|sk-[a-zA-Z0-9]{32,})'; then
      echo "blocked: looks like a credential" >&2
      exit 2
    fi
    exit 0
    EOF
    chmod +x 3-playbook/cue/hooks/block-secrets-write.sh

Then register in `4-control/runtime/claude/settings.json`:

    {
      "hooks": {
        "PreToolUse": [
          {
            "matcher": "Write",
            "hooks": [
              { "type": "command",
                "command": "$CLAUDE_PROJECT_DIR/3-playbook/cue/hooks/block-secrets-write.sh" }
            ]
          }
        ]
      }
    }

## 7. Verify the workspace

Run the bundled integrity-check script:

    ./3-playbook/act/script/check-workspace.sh

It validates the 5-layer topology, the canonical symlinks
(`CLAUDE.md`, `GEMINI.md`, `.mcp.json`), required root files, and
checks for accidentally committed secrets.

Use `--quick` for a folder-presence-only check, `--repair` to recreate
broken canonical symlinks, `--quiet` to suppress non-error output.

## 8. Lifecycle skills (optional but recommended)

Five skills under `3-playbook/act/skill/` guide an agent through the
workspace lifecycle. Three handle session boundaries; two handle the
*use-driven evolution* + *maintenance* loop.

### Session-boundary skills

| Skill | When | Role |
|---|---|---|
| `session-init` | Once after `git clone` | Verify structure, detect runtimes, brief reading order |
| `session-start` | Every working-session start | Report state, surface stale ephemerals, bring backend up |
| `session-end` | Before disconnecting | Summarize changes, suggest commits, update session log, prune |

### Evolution + maintenance skills

| Skill | When | Role |
|---|---|---|
| `session-retro` | After `session-end`, mid-session at Hermes-style triggers, or on explicit request | **Accumulation** — extract session learnings into durable assets across all 5 layers. User ratifies each proposed change. |
| `workspace-audit` | Periodically (monthly / quarterly) or on structural-limit trigger or explicit request | **Maintenance** — audit accumulated content for staleness, duplicates, contradictions, orphans, over-growth, low utility. Propose merges / splits / archives / prunes; user ratifies. |

The two are complementary: `session-retro` *grows* the workspace
(accumulation); `workspace-audit` *keeps it sharp* (consolidation /
pruning). Without `workspace-audit`, the workspace drifts toward
clutter; without `session-retro`, the workspace doesn't accumulate
durable value from each session.

### Pattern lineage

Both skills draw from established patterns:

- **Anthropic Auto Dream** (Claude Code background memory
  consolidation) — surgical transcript grep, sandboxed write scope,
  consolidation phases.
- **Nous Research Hermes Agent** — periodic nudges, bounded memory
  with consolidate-before-append, explicit skill-creation triggers
  (≥ 5 tool calls / error recovery / user correction / non-trivial
  workflow), standard SKILL.md sections (When to Use / Quick
  Reference / Procedure / Pitfalls / Verification), compatibility
  metadata (`requires_tools`, `fallback_for_tools`).
- **`retrospective` (LobeHub)** — per-skill `learnings.md` /
  `failures.md` accumulation.
- **`summarize-session` + `claude-md-improver`** (Anthropic) — CLAUDE.md
  compaction + audit.
- **`hookify`** — problematic behavior → blocking hook.

Each SKILL.md is a natural-language procedure the agent reads and
follows with judgment. Invoke explicitly (`/session-retro`,
`/workspace-audit`) or via autonomous invocation when description
matches.

## Troubleshooting

**Symlink breaks after moving the workspace?**
Symlinks store absolute paths. Recreate with `ln -sf` after moving, or
use `realpath`-relative symlinks: `ln -sr <target> <link>`.

**Claude Code overwrites the symlinked config?**
Claude Code preserves symlinks on most writes. If yours is overwriting,
upgrade Claude Code, or use Option B (file-level symlinks) instead of
Option A (directory symlink).

**Runtime can't find the symlinked config?**
Verify with `readlink ~/.claude/settings.json`. The target must be an
absolute path that exists. WSL → Windows path translation is a common
source of breakage; keep symlinks within one filesystem.

**Need all 5 top-level folders?**
Yes — they're part of the spec. Subfolders may stay empty
(`.gitkeep`) until populated.

**Can I rename folders or change the numeric prefix?**
No. Top-level folder names + `0-` to `4-` prefix are part of the spec.
Renaming makes your workspace non-conformant to workspace.md.

**Where do credentials and API keys go?**
Outside the workspace. Recommended: `~/.config/<workspace>-secrets/`.
Never commit a credential.

**How do I know my workspace is conformant?**
Run the verification script in §7. (A formal linter is on the roadmap.)
