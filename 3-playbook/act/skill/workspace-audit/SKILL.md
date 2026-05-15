---
name: workspace-audit
description: Periodic maintenance pass on the accumulated workspace content. Audits 2-mind/, 3-playbook/, and 4-control/ for staleness, duplicates, contradictions, orphaned references, and over-grown files. Proposes pruning, merging, refactoring, archiving — user ratifies each before applying. The "groundskeeper" complement to session-retro's accumulation. Run monthly / quarterly or after bulk content additions.
---

# Workspace audit — *maintenance / groundskeeping*

## When to use

`session-retro` adds durable assets to the workspace. Over many
sessions the accumulation needs pruning. Run `workspace-audit`:

- **Periodically** — monthly or quarterly, or every N sessions
  (configurable per workspace).
- **After bulk additions** — post-migration, post-merge, after a
  research-heavy week.
- **On structural-limit trigger** — when `principle.md` exceeds ~200
  lines, or any individual atelier/factory file exceeds ~150 lines, or
  any skill's SKILL.md exceeds ~200 lines.
- **On explicit user request** — "let's clean up the workspace"
  / "audit the rules" / "consolidate."

This skill is the maintenance counterpart to `session-retro`'s
accumulation. Without periodic audit, the workspace drifts toward a
cluttered, contradictory, over-grown state. With it, the workspace
stays *sharp and relevant* (Hermes consolidation principle).

## What it audits

Six classes of issue, across **all durable workspace files** —
content layers (`2-mind/`, `3-playbook/`, `4-control/`) AND root-level
files that are not runtime-specific (`AGENTS.md`, per-agent and
per-runtime `AGENTS.md`, `README.md`, `.gitignore`). Out of scope per
separability: runtime-native configs (`.claude/`, `.codex/`,
`.gemini/`), forwarder symlinks, and `WORKSPACE.md` itself
(governed by `contribution.md`).

### 1. Stale content

- Frontmatter `last_verified` older than N months (configurable;
  default 6 for facts, 12 for principles)
- References to files that no longer exist (orphan links)
- Skill files for runtimes no longer in use
- Rules that refer to removed agents or retired conventions
- Atelier stances superseded by newer ones (look for explicit
  "previously we did X but now Y" language in factory or session-log)

### 2. Duplicates and near-duplicates

- Two files covering the same topic (e.g., two atelier files on
  workspace voice, two factory notes on the same external system)
- A rule existing in both `4-control/rule/` and a per-agent `rules/`
  folder (violates single-canonical-home)
- A skill that overlaps significantly with an existing one
- Repeated entries within a single file (same item listed twice)

### 3. Contradictions

- Two pages making opposing claims about the same fact / convention
- Rule and principle in tension (a rule violates a stated principle)
- Newer entry contradicts older without resolution
- Skill instructions that conflict with current `4-control/rule/`

### 4. Over-grown files

- Files exceeding their suggested structural limit:

| File | Suggested limit |
|---|---|
| Root `AGENTS.md` | ~200 lines |
| Per-agent `AGENTS.md` (`role/<agent>/AGENTS.md`) | ~150 lines |
| `4-control/principle/principle.md` | ~200 lines |
| Individual atelier stance file | ~100–150 lines |
| Individual factory notes file | ~200 lines |
| Individual `act/rule/<topic>.md` | ~100 lines |
| Skill `SKILL.md` | ~200 lines |
| `README.md` | ~150 lines |

  When a file exceeds its limit, propose splitting by sub-topic (lazy
  structure activation: now the second occurrence justifies a
  subfolder).

  For root `AGENTS.md` specifically: per AAIF / Anthropic guidance,
  keep it concise (under 200 lines is the soft target Anthropic
  recommends for instruction-file adherence). When it grows beyond
  that, extract topic-specific guidance into `4-control/rule/<topic>.md`
  or per-agent `role/<agent>/AGENTS.md` and leave only the universal
  index in root `AGENTS.md`.

### 5. Orphaned / broken references

- `@file` imports pointing at non-existent files
- Markdown links to deleted files
- Cross-references between rules / principles / skills where the
  target was renamed
- Skills referencing tools / runtimes no longer attached

### 6. Low-utility artifacts

- Skills never invoked since creation (check git log + session-log)
- Rules that never fired (no hook history, no agent self-reference)
- Atelier files with no downstream references from factory or skills
- Scripts not called from any skill / hook / external invocation

Low utility ≠ delete-immediately. Mark candidates; user decides
whether to archive (`0-storage/_archive/`) or keep.

## Steps

### 1. Scan and classify

For each of the six issue classes above, walk the relevant directories
and produce a finding list. Use the helper:

    ./3-playbook/act/script/check-workspace.sh

for the basic structural/symlink/secret check first (rule out
catastrophic state), then perform the deeper content audit.

Concrete scans:

- Stale: `grep -rE 'last_verified: [0-9]{4}-[0-9]{2}-[0-9]{2}'` then
  filter by age threshold.
- Orphan links: `git ls-files | xargs grep -hoE '\[.*?\]\([^)]+\)' |
  ...` cross-checked against existing paths.
- Over-grown: `find . -name '*.md' -not -path './.git/*' | xargs
  wc -l | awk '$1 > 200'`.
- Low-utility skills: cross-check `3-playbook/act/skill/*/` against
  `git log -p --all` references and `2-mind/factory/session-log.md`
  mentions.

### 2. Group findings into proposals

For each issue, build a *concrete proposal*:

- **Merge** — two near-duplicate files → single canonical, with
  cross-reference from the deprecated location
- **Split** — over-grown file → topic-named subfolder with multiple
  smaller files
- **Resolve** — contradiction → keep newer, annotate older with
  "superseded by X, YYYY-MM-DD" or delete
- **Archive** — stale / low-utility → move to `0-storage/_archive/`
  (preserves history without burdening active layers)
- **Prune** — clearly dead orphans → delete (with user confirmation)
- **Update** — broken references → fix paths or remove

### 3. Present proposals to the user (ratification)

Show as a categorized list with rationale + preview-diff per item:

    Workspace audit — YYYY-MM-DD

    ### Merge (2)
    1. `atelier/workspace-voice.md` + `atelier/voice-notes.md`
       — same topic, second is a thinner version of first. Merge.

    ### Split (1)
    2. `4-control/principle/principle.md` is 247 lines (>200).
       Propose split: keep Core values + Spec-evolution at root,
       move Operational principles to `principle/operational.md`.

    ### Resolve contradictions (1)
    3. `rule/filename.md` says YYYY-MM-DD prefix; `rule/naming.md`
       says no date prefix. Pick one; archive other.

    ### Archive (3)
    4. `skill/old-claude-3.5-workflow/` — Claude 3.5 EOL, runtime
       no longer in attached set. Move to `0-storage/_archive/`.

    ### Update references (2)
    5. `factory/runtime-notes.md` links to renamed
       `external/mcp/claude.json` → `external/mcp/registry.json`.

    Ratify (y/n/modify) per item:

User accepts / rejects / modifies each. **No autonomous deletion.**

### 4. Apply ratified changes

For each accepted proposal:

- **Merge**: edit destination to incorporate source content (resolving
  duplicates); replace source with a 1-line forwarder ("Content moved
  to <destination>, YYYY-MM-DD") OR delete source after user
  confirmation; update any cross-references.
- **Split**: create the new subfolder, distribute content, leave
  index/forwarder in original location.
- **Archive**: `git mv <path> 0-storage/_archive/<path>` to preserve
  history; update references.
- **Prune**: `git rm <path>`; update references.
- **Update references**: fix paths in-place via Edit.

Keep changes atomic — one logical operation per commit if the user
commits per-item; or one bulk audit commit if user prefers.

### 5. Verify integrity

After applying:

    ./3-playbook/act/script/check-workspace.sh

Should pass. If any new orphans were introduced (e.g., the merge
broke a link), fix immediately or revert.

### 6. Log the audit

Append to `2-mind/factory/audit-log.md` (or `session-log.md` if
audit-log doesn't yet exist):

    ## YYYY-MM-DD audit pass

    **Scope**: <which layers / file ranges scanned>
    **Findings**: <counts by category>
    **Applied**: <merges N, splits N, archives N, prunes N, updates N>
    **Deferred**: <items user declined or postponed>
    **Next-audit trigger**: <date or condition>

### 7. (Optional) Update structural limit conventions

If many files exceeded a limit, that limit may be too tight for the
workspace's actual usage. Propose adjusting the limit in
`4-control/principle/principle.md` (operational principles section)
rather than fighting against the natural file size. Conversely, if no
files came close, limits could tighten.

## Safety / scope constraints

- **Write only** to: durable workspace content layers (`2-mind/`,
  `3-playbook/`, `4-control/`) + `0-storage/_archive/` (for archived
  content) + *non-runtime-specific* root files (`AGENTS.md`,
  `README.md`, `.gitignore`) when audit findings justify edits.
- **Do not edit** runtime-native configs (`.claude/`, `.codex/`,
  `.gemini/`, root `.mcp.json`) — separability principle.
- **Do not edit** `WORKSPACE.md` (spec; follows `contribution.md`)
  or `LICENSE` (legal) without explicit user direction.
- **Do not edit** forwarder symlinks (`CLAUDE.md`, `GEMINI.md`,
  `.mcp.json`) — they already point at canonical targets.
- **Never auto-commit**. Stage; user commits.
- **Deletion requires explicit ratification** per item.
- **Preserve history** — archive (`git mv`) is the default for any
  potentially-valuable stale content. Pure deletion only for
  unambiguous orphans.
- **Quote-verbatim preservation** — when merging atelier content,
  Owner stance must remain verbatim. The wrapper / index may change;
  the quoted words may not.

## Done criteria

- All six issue classes scanned
- User ratified each proposal
- Ratified changes applied; `check-workspace.sh` passes
- `audit-log.md` (or `session-log.md`) appended with summary
- Optionally: next-audit-trigger date or condition noted

## References

Pattern lineage: Auto Dream consolidation phase + Hermes bounded
memory (consolidate-before-append at 80%) + `claude-md-improver` +
software-engineering "groundskeeper" practice.

- Auto Dream — <https://claudefa.st/blog/guide/mechanics/auto-dream>
- Hermes memory architecture — <https://vectorize.io/articles/hermes-agent-memory-explained>
- `claude-md-improver` — <https://github.com/anthropics/claude-plugins-official/blob/main/plugins/claude-md-management/skills/claude-md-improver/SKILL.md>
