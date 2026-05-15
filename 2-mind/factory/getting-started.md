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

`4-control/runtime/` holds canonical config files for each LLM runtime;
symlinks bind them to the runtime's expected discovery locations.

### 3.0 Two integration depths — pick based on your needs

**Project-level (recommended; comes pre-configured in Path A clone):**

When a hosted CLI is invoked from a directory it treats as a project root, it auto-discovers `<repo>/.<runtime>/` and uses any settings there. Path A clones already include the following project-level symlinks:

    .claude/settings.json  →  4-control/runtime/claude/settings.json
    .codex/config.toml     →  4-control/runtime/codex/config.toml
    .gemini/settings.json  →  4-control/runtime/gemini/settings.json
    .mcp.json              →  4-control/external/mcp/claude.json

This means **running `claude`, `codex`, or `gemini` at the repo root just works** — workspace settings apply only here, your global `~/.<runtime>/` is untouched.

To customize, edit the canonical files at `4-control/runtime/<runtime>/` and `4-control/external/mcp/`. Changes propagate automatically through the symlinks.

If you used Path B (manual): create these symlinks yourself:

    mkdir -p .claude .codex .gemini
    ln -s ../4-control/runtime/claude/settings.json .claude/settings.json
    ln -s ../4-control/runtime/codex/config.toml    .codex/config.toml
    ln -s ../4-control/runtime/gemini/settings.json .gemini/settings.json
    ln -s 4-control/external/mcp/claude.json        .mcp.json

**User-level (optional):**

If you want workspace settings to apply globally for a runtime (everywhere on your machine, not just this workspace), follow the per-runtime commands below to symlink `~/.<runtime>/` to canonical workspace paths.

Project-level overrides user-level when both are configured.

### 3.1 Claude Code (multi-file directory)

Claude Code's `~/.claude/` is a *directory* containing `settings.json`,
`agents/`, `commands/`, `hooks/`, `mcp.json`, and more. Two options:

**Option A — symlink the whole directory** (recommended for new
adopters; preserves all Claude Code state in the workspace):

    # Backup first
    cp -a ~/.claude ~/.claude.backup-$(date +%Y%m%d)

    # Move .claude content into runtime/claude/
    mkdir -p 4-control/runtime/claude
    mv ~/.claude/* ~/.claude/.[!.]* 4-control/runtime/claude/ 2>/dev/null
    rmdir ~/.claude

    # Symlink the whole directory
    ln -s "$(pwd)/4-control/runtime/claude" ~/.claude

    # Verify
    readlink ~/.claude
    # → expected: /your/workspace/4-control/runtime/claude

**Option B — symlink individual files** (lower risk; some files stay
in `~/.claude/` outside the workspace):

    mkdir -p 4-control/runtime/claude
    for f in settings.json mcp.json; do
      if [ -f ~/.claude/$f ]; then
        mv ~/.claude/$f 4-control/runtime/claude/$f
        ln -s "$(pwd)/4-control/runtime/claude/$f" ~/.claude/$f
      fi
    done

If `~/.claude/` doesn't exist yet (Claude Code not yet installed):

    mkdir -p 4-control/runtime/claude
    echo '{}' > 4-control/runtime/claude/settings.json
    mkdir -p ~/.claude && ln -s "$(pwd)/4-control/runtime/claude/settings.json" ~/.claude/settings.json

### 3.2 Gemini CLI

    mkdir -p 4-control/runtime/gemini
    [ -f ~/.gemini/config.json ] && \
      mv ~/.gemini/config.json 4-control/runtime/gemini/config.json || \
      echo '{}' > 4-control/runtime/gemini/config.json
    mkdir -p ~/.gemini
    ln -sf "$(pwd)/4-control/runtime/gemini/config.json" ~/.gemini/config.json

### 3.3 Codex

    mkdir -p 4-control/runtime/codex
    [ -f ~/.codex/config.toml ] && \
      mv ~/.codex/config.toml 4-control/runtime/codex/config.toml || \
      touch 4-control/runtime/codex/config.toml
    mkdir -p ~/.codex
    ln -sf "$(pwd)/4-control/runtime/codex/config.toml" ~/.codex/config.toml

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

### 3.5 Platform notes

- **macOS / Linux / WSL**: `ln -s` as shown.
- **Windows native**: use `mklink /D` (directory) or `mklink` (file) in
  `cmd.exe` as administrator, or `New-Item -ItemType SymbolicLink` in
  PowerShell.
- **Secrets never go inside the workspace.** Use the runtime's own
  credential mechanism, environment variables outside `.env`, or
  `~/.config/<workspace>-secrets/`.

### 3.6 Verify

    # All symlinks under .claude or .gemini point inside the workspace
    ls -la ~/.claude/ ~/.gemini/ 2>/dev/null | grep '^l'

    # The runtime starts up normally
    claude --version  # or gemini, codex, ollama

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

A minimum-conformance check (manual):

    # All 5 top-level folders present
    for d in 0-storage 1-active 2-mind 3-playbook 4-control; do
      [ -d "$d" ] && echo "OK: $d/" || echo "MISSING: $d/"
    done

    # 2-mind and 4-control subfolders
    for d in 2-mind/{atelier,factory} \
             4-control/{principle,runtime,external,rule}; do
      [ -d "$d" ] && echo "OK: $d/" || echo "MISSING: $d/"
    done

    # No secrets accidentally committed
    git grep -nE '(AKIA[0-9A-Z]{16}|sk-[a-zA-Z0-9]{32,}|password\s*=)' \
      && echo "WARNING: possible secret in tree" \
      || echo "OK: no obvious secrets"

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
