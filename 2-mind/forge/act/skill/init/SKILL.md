---
name: init
description: One-shot workspace bootstrap after git clone. Verifies mandated structure, detects installed LLM runtimes, modifies template seeds with workspace-specific info (e.g., runtime detection results). Does NOT create files — templates ship in the repo.
---

# init

## When to use

Once after cloning a workspace.md-compliant workspace, or after major
filesystem reorganization. Not for routine sessions (use
`session-start` for those).

## Quick reference

| Step | Reads | Writes |
|---|---|---|
| 1. Verify structure | `WORKSPACE.md`, repo file tree | — |
| 2. Detect runtimes | shell `command -v` checks | — |
| 3. Brief read order | `AGENTS.md` (reading order section) | — |
| 4. (Optional) modify seeds | template files in `garden/essential/` | minor edits only |

## Procedure

### 1. Verify mandated structure

Confirm presence:
- 4 top folders: `0-storage/ 1-active/ 2-mind/ 3-control/`
- `2-mind/garden/` (mandated — declarative memory)
- `2-mind/forge/` (mandated — procedural memory)
- `3-control/foundation/SOUL.md` (canonical identity)
- `3-control/foundation/PRINCIPLE.md` (operating principles)

If anything missing: restore from git or re-clone. Do NOT create
missing files — they should be in the spec repo.

### 2. Detect installed LLM runtimes

For each of `claude`, `codex`, `gemini`, `ollama`, `lms`, `mlx_lm`,
run `command -v <name>` and report:
- `detected:` list
- `missing:` list (informational; install separately if desired)

### 3. Brief the Owner on read order

From `AGENTS.md` § Reading order:
1. `AGENTS.md`
2. `WORKSPACE.md`
3. `3-control/foundation/PRINCIPLE.md`
4. `3-control/foundation/SOUL.md`
5. `2-mind/garden/essential/USER.md`
6. `2-mind/garden/essential/NEXT.md` (consume + clear)
7. `2-mind/garden/essential/journal/<most-recent>.md`

### 4. (Optional) Modify template seeds with workspace-specific info

If template files (`garden/essential/{USER,NEXT,SOUL}.md`,
`journal/ENTRY-TEMPLATE.md`) have placeholder slots that benefit from
runtime-detection results (e.g., "Runtime: <detected runtimes>"),
edit those slots in-place. Don't add substantive content — templates
fill via use.

## Pitfalls

- **Creating new files**: templates ship in the repo. `init` only
  modifies; never creates. If a template is missing, the spec repo
  itself is broken — restore from git.
- **Substantive content in templates**: templates are scaffolds, not
  starter content. Don't pre-populate USER.md with guessed Owner
  preferences — let `learn` skill discover them across sessions.
- **Skipping read-order brief**: even if Owner is experienced, the
  read-order brief surfaces any structural mismatches.

## Verification

- `find . -not -path './.git*' \( -type f -o -type l \)` shows all
  mandated files present
- Read order in `AGENTS.md` matches the 7-item list above
- Owner acknowledges readiness to proceed
