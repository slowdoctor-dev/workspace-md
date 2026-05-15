# Getting started

A walkthrough for adopting workspace.md as your own workspace. Assumes
you have just cloned this repo.

## 1. Reset the repo as yours

    cd <your-clone>
    rm -rf .git
    git init -q
    git add -A
    git commit -q -m "<YYYY-MM-DD> initial commit"

## 2. Replace spec-repo-only files

These describe THIS spec repo, not your workspace. Replace or remove:

| File | Action |
|---|---|
| `README.md` | **Replace** with your workspace intro |
| `LICENSE` | **Replace** with your license |
| `AGENTS.md` | **Replace** — see [agents.md](https://agents.md) for the format |
| `4-control/rule/contribution.md` | **Delete** or replace with your own contribution rules |
| `2-mind/factory/version-log.md` | **Delete** or repurpose for your workspace's release log |
| `2-mind/factory/getting-started.md` (this file) | **Delete** once you've finished onboarding |

Files to keep:

| File | Action |
|---|---|
| `WORKSPACE.md` | **Keep** as your spec reference |
| `4-control/principle/principle.md` | **Keep the operational section**; remove the "Spec-evolution principles" section (it applies only to evolving the spec itself) |
| All `.gitkeep` files | Keep until you fill the folder |

## 3. Attach your first runtime

`4-control/runtime/` binds your LLM CLI to the workspace. One subfolder
per runtime; canonical config files live inside; symlinks bind them to
the runtime's expected location.

### Claude Code

    mkdir -p 4-control/runtime/claude
    mv ~/.claude/settings.json 4-control/runtime/claude/settings.json
    ln -s "$(pwd)/4-control/runtime/claude/settings.json" ~/.claude/settings.json

### Gemini CLI

    mkdir -p 4-control/runtime/gemini
    mv ~/.gemini/config.json 4-control/runtime/gemini/config.json
    ln -s "$(pwd)/4-control/runtime/gemini/config.json" ~/.gemini/config.json

### Codex

    mkdir -p 4-control/runtime/codex
    mv ~/.codex/config.toml 4-control/runtime/codex/config.toml
    ln -s "$(pwd)/4-control/runtime/codex/config.toml" ~/.codex/config.toml

### Local LLM (Ollama)

    mkdir -p 4-control/runtime/ollama
    cat > 4-control/runtime/ollama/Modelfile <<EOF
    FROM llama3.1
    PARAMETER temperature 0.7
    EOF

### Platform notes

- **macOS / Linux / WSL**: `ln -s` as shown above.
- **Windows native**: use `mklink` in `cmd.exe` (admin) or
  `New-Item -ItemType SymbolicLink` in PowerShell.
- **Secrets never go inside the workspace.** Use the runtime's own
  credential mechanism or `~/.config/<workspace>-secrets/`.

## 4. Add your first content

Common first additions, by layer:

- `2-mind/atelier/<stance>.md` — your design values, persona, principles
- `2-mind/factory/<topic>-notes.md` — synthesis your agent maintains
- `3-playbook/role/<agent>/AGENTS.md` — a custom agent spec
- `3-playbook/act/skill/<task>/SKILL.md` — a natural-language procedure
- `4-control/rule/<topic>.md` — a workspace-wide constraint

Refer to `WORKSPACE.md` for the canonical layout and
`4-control/principle/principle.md` for per-layer operational guidance.

## 5. (Optional) Attach an MCP server

### Self-owned MCP server

    mkdir -p 4-control/external/mcp/<server-name>
    # Put server source code + connection config inside this folder.
    # Code and config travel together.

### 3rd-party MCP server

    mkdir -p 4-control/external/mcp
    # Add a registry file with server entries. Format depends on the
    # runtime — check the runtime's MCP documentation.

## 6. (Optional) Add a hook or scheduled trigger

Hooks live in `3-playbook/cue/`. Implementation is runtime-specific
(Claude Code hooks ≠ Gemini hooks). Example for Claude Code:

    mkdir -p 3-playbook/cue/hooks
    cat > 3-playbook/cue/hooks/pre-write.sh <<'EOF'
    #!/usr/bin/env bash
    # Runs before any Write tool call. Customize per your needs.
    exit 0
    EOF
    chmod +x 3-playbook/cue/hooks/pre-write.sh

Then reference the hook from `4-control/runtime/claude/settings.json`.

## Troubleshooting

**Symlink breaks after moving the workspace?** Symlinks store absolute
paths. Recreate with `ln -sf` after moving.

**Runtime overwrites the symlinked config?** Some runtimes resolve
symlinks on write. Either bind-mount the directory, or configure the
runtime to import from your workspace path instead of replacing the
config.

**Need all 5 top-level folders?** Yes — they are the spec. But
subfolders can stay empty (`.gitkeep`) until you have content for them.

**Can I rename folders or change the numeric prefix?** No. Top-level
folder names + the `0-` to `4-` prefix are part of the spec. Renaming
makes your workspace non-conformant.

**Where do credentials and API keys go?** Outside the workspace.
Recommended: `~/.config/<workspace>-secrets/`. Never commit a credential
to a workspace.md-compliant repo.
