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
| 3. Recommend cap tier | detected-runtime list + R1 tier table | — |
| 4. Propose runtime profile | (Owner-ratified) | `3-control/runtime/profile.md` (T2) |
| 5. Brief read order | `AGENTS.md` (reading order section) | — |
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

### 2. Detect installed LLM runtimes

For each of `claude`, `codex`, `gemini`, `ollama`, `lms`, `mlx_lm`,
run `command -v <name>` and report:
- `detected:` list
- `missing:` list (informational; install separately if desired)

For each detected local runtime (`ollama` / `lms` / `mlx_lm`),
attempt to enumerate installed models (e.g., `ollama list`) and
record the largest available — this informs tier recommendation.

### 3. Recommend cap tier

Map detected runtime(s) to a cap tier per
`3-control/foundation/use-driven-memory.md §R1`:

| Detected runtime | Recommended tier |
|---|---|
| Only hosted CLI(s) (claude / codex / gemini) | `extended` |
| Local runtime running 30B+ model, OR hosted-modest pairing | `standard` |
| Local runtime running ≤13B model (most common single-GPU setup) | `lean` |
| Mixed (hosted + local) | **most constrained** of the set |
| Nothing detected | `lean` (safe floor) |

### 4. Propose runtime profile to Owner

Draft `3-control/runtime/profile.md` content:

```markdown
# Runtime profile

**active_tier**: <recommended>
**detected_runtimes**: <list>
**last_updated**: <YYYY-MM-DD>
**notes**: <recommendation rationale; Owner may amend>
```

Present diff to Owner: "Detected runtimes X, Y. Recommending tier T
because Z. Accept / adjust?". On accept (T2 ratify), write the file.
On adjust, write Owner's chosen tier.

### 5. Brief the Owner on read order

From `AGENTS.md` § Reading order:
1. `AGENTS.md`
2. `WORKSPACE.md`
3. `3-control/foundation/PRINCIPLE.md`
4. `3-control/foundation/SOUL.md`
5. `2-mind/garden/essential/USER.md`
6. `2-mind/garden/essential/NEXT.md` (consume + clear)
7. `2-mind/garden/essential/journal/<most-recent>.md`

### 6. (Optional) Modify template seeds with workspace-specific info

If template files (`garden/essential/{USER,NEXT,SOUL}.md`,
`journal/ENTRY-TEMPLATE.md`) have placeholder slots that benefit from
runtime-detection results (e.g., "Runtime: <detected runtimes>"),
edit those slots in-place. Don't add substantive content — templates
fill via use.

## Pitfalls

- **Creating new memory files**: templates ship in the repo. `init`
  only modifies templates; never creates memory content. If a
  template is missing, the spec repo itself is broken — restore.
- **Skipping the tier-ratify step**: without `profile.md`, `learn`
  and `audit` default to `lean` — fine on local but wastes headroom
  on hosted setups. Always offer the tier proposal.
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
