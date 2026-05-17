---
name: init
description: One-shot workspace bootstrap after git clone. Verifies mandated structure, detects installed LLM runtimes, proposes runtime profile (active cap tier) for Owner ratification, modifies template seeds with workspace-specific info. Does NOT create memory content — templates ship in the repo.
---

# init

## When to use

Once after cloning a workspace.md-compliant workspace, or after major
filesystem reorganization, or after switching the primary runtime
(e.g., moving from local-only Ollama to a hosted CLI). Not for
routine sessions (use `session-start`).

## Quick reference

| Step | Reads | Writes |
|---|---|---|
| 1. Verify structure | `WORKSPACE.md`, repo file tree | — |
| 2. Detect runtimes | shell `command -v` checks | — |
| 3. Recommend + ratify cap tier | detected list + R1 tier table | `3-control/runtime/profile.md` (T2) |
| 4. Brief read order | `AGENTS.md` § Reading order | — |
| 5. (Optional) modify seeds | template files in `garden/essential/` | minor edits only |

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
run `command -v <name>`. Report `detected:` and `missing:` lists.

### 3. Recommend + ratify cap tier

For each detected local runtime, enumerate installed models (e.g.,
`ollama list`) to find the largest available — informs tier choice.

Map to a cap tier per `use-driven-memory.md §R2 Part B` (R2's
runtime adjustment over R1 natural caps):

| Detected runtime | Recommended tier |
|---|---|
| Hosted CLI(s) pointing at hosted-large model (Claude Sonnet/Opus, GPT-4, Gemini Pro) | `extended` |
| Hosted CLI(s) pointing at hosted-modest model (Claude Haiku, GPT-4o-mini) | `standard` (= R1 baseline) |
| Local runtime, 30B+ model | `standard` (= R1 baseline) |
| Local runtime, ≤13B model | `lean` |
| Mixed runtimes | **most constrained** of the set |
| Nothing detected | `standard` (R1 baseline as-is) |

CLI detection alone doesn't reveal which model the CLI is pointing
at — confirm with Owner. Default to `standard` if uncertain.

Draft `3-control/runtime/profile.md`:

```markdown
# Runtime profile

**active_tier**: <recommended>
**detected_runtimes**: <list>
**last_updated**: <YYYY-MM-DD>
**notes**: <recommendation rationale; Owner may amend>
```

Present to Owner ("Detected X, Y → recommend tier T because Z.
Accept / adjust?"); write the file on ratify.

### 4. Brief the Owner on read order

From `AGENTS.md` § Reading order (7 items):
1. `AGENTS.md`
2. `WORKSPACE.md`
3. `3-control/foundation/PRINCIPLE.md`
4. `3-control/foundation/SOUL.md`
5. `2-mind/garden/essential/USER.md`
6. `2-mind/garden/essential/NEXT.md` (consume + clear)
7. `2-mind/garden/essential/journal/<most-recent>.md`

### 5. (Optional) Modify template seeds

If templates (`garden/essential/{USER,NEXT,SOUL}.md`,
`journal/ENTRY-TEMPLATE.md`) have placeholder slots that benefit
from runtime info (e.g., "Runtime: <detected>"), edit in place.
Don't add substantive content — templates fill via use.

## Pitfalls

- **Creating new memory files**: templates ship in the repo. `init`
  only modifies templates; never creates memory content. If a
  template is missing, the spec repo itself is broken — restore.
- **Skipping the tier-ratify step**: without `profile.md`, `learn`
  and `audit` default to `standard` (R1 baseline). Fine on
  hosted-modest / local 30B+; under-protective on local 7-13B
  (lean would fit better). Always offer the tier proposal.
- **Substantive content in templates**: templates are scaffolds, not
  starter content. Don't pre-populate USER.md with guessed Owner
  preferences — let `learn` discover them.
- **Skipping read-order brief**: even if Owner is experienced, the
  brief surfaces structural mismatches early.

## Verification

- `find . -not -path './.git*' \( -type f -o -type l \)` shows all
  mandated files present
- Read order in `AGENTS.md` matches the 7-item list above
- `3-control/runtime/profile.md` exists with Owner-ratified
  `active_tier`
- Owner acknowledges readiness to proceed
