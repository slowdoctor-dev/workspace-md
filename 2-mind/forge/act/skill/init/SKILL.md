---
name: init
description: One-shot workspace bootstrap after git clone. Verifies mandated structure, invokes `detect-runtime` to detect (harness, backend, effective_context) and derive recommended tier, proposes the runtime profile for Owner ratification, modifies template seeds with workspace-specific info. Does NOT create memory content — templates ship in the repo.
---

# init

## When to use

Once after cloning a workspace.md-compliant workspace, or after major
filesystem reorganization, or after switching the primary runtime
(e.g., moving from local-only Ollama to a hosted CLI). Not for
routine sessions (use `session-start`).

## Requires

Requires `AGENTS.md` and `WORKSPACE.md` at the repo root. During
bootstrap, verify `3-control/foundation/SOUL.md`,
`3-control/foundation/PRINCIPLE.md`, and `2-mind/garden/essential/`.
If any of those are missing, stay in `init` and restore from git or a
fresh clone before invoking lifecycle skills.

## Quick reference

| Step | Reads | Writes |
|---|---|---|
| 1. Verify structure | `WORKSPACE.md`, repo file tree | — |
| 2. Invoke `detect-runtime` (bootstrap mode) | runtime self-introspection + env/config/endpoint signals | — (skill returns proposed profile) |
| 3. Ratify profile.md | detect-runtime result | `3-control/runtime/profile.md` (T2) |
| 4. (Optional) expose Antigravity aliases | ratified `harness=antigravity`, MCP registry | `.agents/` aliases/rendered config (Owner-owned setup) |
| 5. Brief read order | `AGENTS.md` § Reading order | — |
| 6. (Optional) modify seeds | template files in `garden/essential/` | minor edits only |

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

### 2. Invoke `detect-runtime` (bootstrap mode)

Run the `detect-runtime` skill
(`2-mind/forge/act/skill/detect-runtime/SKILL.md`) in bootstrap
mode. It produces a proposed profile with 6 fields populated:
`harness`, `backend_provider`, `backend_endpoint`, `backend_model`,
`effective_context`, `recommended_tier` (derived per
`runtime-flexibility.md`'s canonical rule — becomes `active_tier`
in profile.md on Owner ratify), plus any `signal_disagreements`
flagged.

Optional helper available at
`2-mind/forge/act/script/detect-runtime.sh` when shell is available;
otherwise execute the skill's procedure manually.

### 3. Ratify profile.md

Present the detect-runtime result to Owner field-by-field. For each
field: accept detection's value, override with Owner's choice, or
mark `(uncertain — <reason>)`. On accept, write
`3-control/runtime/profile.md` per its schema; set `last_updated`
to today.

If signal_disagreements were flagged (e.g., agent self-says "Claude
Sonnet 4.6" but `/v1/models` returns `qwen2.5-coder:32b` →
proxy-mismatch), surface them explicitly before ratify.

### 4. (Optional) Expose Antigravity aliases

Only when the ratified profile has `harness: antigravity`, expose the
workspace through Antigravity's `.agents/` convention:

- `.agents/skills` points to `2-mind/forge/act/skill/`
- `.agents/mcp_config.json` is a rendered config with `serverUrl`,
  owned by `3-control/external/mcp`

This step is a documentation handoff for the Owner/root-doc pass:
create or update those root aliases/configs there, not from this
forge-only procedure edit. If Antigravity and Gemini CLI are both
present, keep the detect-runtime collision warning visible while
reviewing these aliases.

### 5. Brief the Owner on read order

From `AGENTS.md` § Reading order (7 items):
1. `AGENTS.md`
2. `WORKSPACE.md`
3. `3-control/foundation/PRINCIPLE.md`
4. `3-control/foundation/SOUL.md`
5. `2-mind/garden/essential/USER.md`
6. `2-mind/garden/essential/NEXT.md` (consume + clear)
7. `2-mind/garden/essential/journal/<most-recent>.md`

#### Existing AGENTS.md Handoff

Treat `AGENTS.md` as the current session-start handoff until the
canonical read-order home is ratified elsewhere. Do not duplicate or
rewrite the read-order definition during `init`; point the Owner to
the existing `AGENTS.md` list and continue with profile ratification.

### 6. (Optional) Modify template seeds

If templates (`garden/essential/{USER,NEXT,SOUL}.md`,
`journal/ENTRY-TEMPLATE.md`) have placeholder slots that benefit
from runtime info (e.g., "Runtime: <detected>"), edit in place.
Don't add substantive content — templates fill via use.

## Pitfalls

- **Creating new memory files**: templates ship in the repo. `init`
  only modifies templates; never creates memory content. If a
  template is missing, the spec repo itself is broken — restore.
- **Skipping the tier-ratify step**: without `profile.md`, `dream`
  and `audit` default to `standard` (R1 baseline). Fine on
  hosted-modest / local 30B+; under-protective on local 7-13B
  (lean would fit better). Always offer the tier proposal.
- **Substantive content in templates**: templates are scaffolds, not
  starter content. Don't pre-populate USER.md with guessed Owner
  preferences — let `dream` discover them.
- **Skipping read-order brief**: even if Owner is experienced, the
  brief surfaces structural mismatches early.

## Verification

- `find . -not -path './.git*' \( -type f -o -type l \)` shows all
  mandated files present
- Read order in `AGENTS.md` matches the 7-item list above
- `3-control/runtime/profile.md` exists with all 6 fields Owner-
  ratified: `harness`, `backend_provider`, `backend_endpoint`,
  `backend_model`, `effective_context`, `active_tier` (or
  annotated `(uncertain — <reason>)` per `detect-runtime` discipline)
- `last_updated` field set to today's date
- Owner acknowledges readiness to proceed
