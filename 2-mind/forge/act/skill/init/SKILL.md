---
name: init
description: One-shot workspace bootstrap after git clone. Verifies mandated structure, invokes `detect-runtime` to detect (harness, backend, model_class) and derive the recommended tier, proposes the runtime profile for Owner ratification, exposes the native aliases the detected harness needs, briefs the hot read order. Does NOT create memory content — templates ship in the repo.
---

# init

## When to use

Once after cloning a workspace.md-compliant workspace, after major
filesystem reorganization, or after switching the primary runtime.
Not for routine sessions (use `session-start`).

## Requires

Requires `AGENTS.md` and `WORKSPACE.md` at the repo root. During
bootstrap, verify `3-control/foundation/SOUL.md`,
`3-control/foundation/PRINCIPLE.md`, and `2-mind/garden/essential/`.
If any are missing, stay in `init` and restore from git or a fresh
clone before invoking lifecycle skills.

## Quick reference

| Step | Reads | Writes |
|---|---|---|
| 1. Verify structure | `WORKSPACE.md`, repo file tree | — |
| 2. Invoke `detect-runtime` (bootstrap mode) | runtime signals | — (returns proposed profile) |
| 3. Ratify profile.md | detection result + `3-control/runtime/profile.example.md` | `3-control/runtime/profile.md` (T2) |
| 4. Expose native aliases | ratified `harness`, `2-mind/forge/`, MCP registry | symlinks / rendered configs at native paths (T2 where they execute) |
| 5. Brief hot read order | `use-driven-memory.md §Read order` | — |
| 6. (Optional) adjust seeds | `garden/essential/` templates | minor edits only |

## Procedure

### 1. Verify mandated structure

Confirm: `0-storage/ 1-active/ 2-mind/ 3-control/`; `2-mind/garden/`;
`2-mind/forge/`; `3-control/foundation/SOUL.md` + `PRINCIPLE.md`.
Missing → restore from git or re-clone. Do NOT create missing files.

### 2. Invoke `detect-runtime` (bootstrap mode)

Run `2-mind/forge/act/skill/detect-runtime/SKILL.md` in bootstrap
mode. It returns `harness`, `backend_provider`, `backend_endpoint`,
`backend_model`, `model_class`, `recommended_tier` (per
`runtime-flexibility.md`'s rule), optional `effective_context`, and any
`signal_disagreements`. Helper script:
`2-mind/forge/act/script/detect-runtime.sh` (objective checks only).

### 3. Ratify profile.md

Present field-by-field. For each: accept, override, or mark
`(uncertain — <reason>)`. On accept, write
`3-control/runtime/profile.md` from `profile.example.md`; set
`last_updated` to today. Surface `signal_disagreements` first (e.g.
proxy mismatch). Fresh clones ship only the example.

**Headless bootstrap**: cannot ratify → write the proposed profile to
`1-active/proposals/<date>_profile.md`, use `standard`, and open a PR
(`use-driven-memory.md §Ratification channels`).

### 4. Expose native aliases for the ratified harness

One canonical home, exposed at the harness's native path
(`WORKSPACE.md §Native discovery paths`). Create only what the harness
reads; lazy structure applies.

| Harness | Create |
|---|---|
| `claude-code` | `.claude/` as a **real directory**; `.claude/skills → ../2-mind/forge/act/skill`; `.claude/agents/<n>.md` rendered from `forge/role/<n>/` when roles exist; hooks rendered from `cue/lifecycle.md` into `.claude/settings.json` (T2) |
| `codex-cli` | `.agents/skills → ../2-mind/forge/act/skill`; `[mcp_servers]` rendered into `.codex/config.toml` after the first server; hooks rendered (T2) |
| `antigravity` | `.agents/skills`; `.agents/mcp_config.json` rendered (`url`→`serverUrl`) after the first server; hooks per `3-control/runtime/antigravity-cli.md`; keep the Gemini-collision warning visible if both are installed |
| other / `custom` | nothing beyond `AGENTS.md`; add a one-line `CLAUDE.md` containing `@AGENTS.md` only if the harness cannot read `AGENTS.md` |

Rendered files carry a `rendered_from` note (TRUST-2). `.mcp.json →
3-control/external/mcp/registry.json` is shared by every harness that
reads `.mcp.json`.

### 5. Brief the Owner on the hot read order

Use the canonical 5-item list at
`3-control/foundation/use-driven-memory.md §Read order`; `AGENTS.md`
mirrors it. Do not duplicate or rewrite the list here.

#### Existing AGENTS.md handoff

An adopter's existing `AGENTS.md` is the runtime-discovery handoff. Do
not rewrite their instructions during `init`; propose (T2) adding the
§Hot read order and §Rules-in-one-line blocks from this spec's card, or
rely on the canonical list in `use-driven-memory.md`. Keep the file an
operational card — README-style prose lowers agent success (ETH 2026).

### 6. (Optional) Adjust template seeds

If seeds (`garden/essential/{USER,NEXT,SOUL}.md`,
`journal/ENTRY-TEMPLATE.md`) have placeholder slots that benefit from
runtime info (journal id scheme, runtime slug), edit in place. Don't
add substantive content — templates fill via use.

## Pitfalls

- **Creating memory content**: `init` only adjusts templates.
- **Skipping tier ratify**: without `profile.md`, `dream`/`audit`
  default to `standard` — under-protective on `local-small`.
- **Symlinking `.claude/` itself**: Claude Code refuses worktree
  creation when `.claude` is a symlink; link `skills` inside a real dir.
- **Shipping symlinked `CLAUDE.md`/`GEMINI.md`**: redundant for
  current harnesses; use the `@AGENTS.md` fallback only when needed.
- **Rendering hooks without ratify**: rendered hook files execute
  (TRUST-2) — T2.
- **Skipping the read-order brief**: it surfaces mismatches early.

## Verification

- `find . -not -path './.git*' \( -type f -o -type l \)` shows all
  mandated files present
- `3-control/runtime/profile.md` exists with `harness`,
  `backend_provider`, `backend_endpoint`, `backend_model`,
  `model_class`, `active_tier` Owner-ratified (or `(uncertain — …)`);
  `last_updated` = today — or a proposal + PR exists (headless)
- Native aliases for the ratified harness resolve; rendered files
  carry `rendered_from`
- Read-order summaries numerically match `use-driven-memory.md`
- Owner acknowledges readiness
