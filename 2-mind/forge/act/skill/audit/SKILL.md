---
name: audit
description: Periodic maintenance pass — 6-class issue scan + journal archival (>3 months old → garden/archive/<YYYY-MM>/). Companion to learn (accumulation); audit handles forgetting and consolidation.
---

# audit

## When to use

- **Monthly** by default (or every N sessions, per workspace cadence)
- **On size-limit breach** (USER.md or garden topic exceeds its tier
  cap — see R1)
- **After bulk additions** (post-migration, post-research-heavy)
- **Explicit `/audit`** Owner invocation

Companion to `learn` — `learn` accumulates, `audit` prunes. Without
`audit` the workspace drifts toward clutter; without `learn` it
doesn't accumulate. (Ebbinghaus forgetting curve + interference
theory mitigation.)

## Quick reference

| Issue class | What to look for | Action |
|---|---|---|
| 1. Stale | references to deleted/renamed files; entries with old `last_verified` | update or prune |
| 2. Duplicates | two files on same topic; same rule in multiple places | merge to canonical home |
| 3. Contradictions | rules/principles in tension; old vs new claims | resolve (keep newer; annotate older) |
| 4. Over-grown | files exceeding their R1 cap | split or consolidate |
| 5. Orphans | dead links; broken cross-refs | fix paths or remove refs |
| 6. Low-utility | skills never invoked; rules never fired | archive or prune |

Plus: journal archival pass (entries >3 months → archive).

## Procedure

### 1. Journal archival (the main mechanical task)

Scan `2-mind/garden/essential/journal/` for entries with date prefix
>3 months old. For each:
- `mkdir -p 2-mind/garden/archive/<YYYY-MM>/` (year-month of entry)
- `git mv 2-mind/garden/essential/journal/<entry>.md 2-mind/garden/archive/<YYYY-MM>/`

Archived entries stay grep-searchable but no longer auto-load.

### 2. Stale scan

- Grep for paths that no longer resolve (e.g., references to
  pre-restructure paths like `4-control/` or `3-playbook/`)
- Check entries with `last_verified:` frontmatter older than 6 months
  (for non-time-anchored content)

Stale items in 2-mind/ → fix or prune directly (T1).
Stale items in 3-control/ → propose to Owner (T2).

### 3. Duplicate scan

- Walk `garden/<topic>.md` files; look for overlapping topics
- Check if rules duplicate between `3-control/rule/` and per-agent
  `rules/` (if exists in `forge/role/<agent>/rules/`)
- Scan USER.md for repeated entries
- Scan `forge/act/skill/` for skills with overlapping scope

In 2-mind/ → merge directly (T1). In 3-control/ → propose (T2).

### 4. Contradiction scan

- Compare PRINCIPLE.md statements with SOUL.md / WORKSPACE.md for
  internal consistency
- Look for "previously did X but now Y" patterns in garden content
  without explicit resolution

Resolution (T2 if 3-control/ involved; T1 otherwise): keep newer,
annotate older.

### 5. Over-grown scan

Caps are runtime-tier-dependent for memory files; fixed for spec
files. Read `3-control/runtime/profile.md` for the active tier
(default `lean` if absent). Full tier table at
`3-control/foundation/use-driven-memory.md §R1`.

**Memory caps** (hard — apply by tier):

| File | lean | standard | extended |
|---|---|---|---|
| `USER.md` | 60 | 100 | 200 |
| `NEXT.md` | 20 | 30 | 50 |
| journal entry | 100 soft | 200 soft | 400 soft |
| garden `<topic>.md` flag | 200 | 300 | 500 |

**Spec caps** (advisory flags — same all tiers):

| File | Flag at |
|---|---|
| `AGENTS.md` | 80 |
| `WORKSPACE.md` | 200 |
| `PRINCIPLE.md` | 250 |
| `SOUL.md` (canonical) | 100 |
| `use-driven-memory.md` | 300 |
| `SOUL.md` (working, in garden) | no cap; Graduated section ≥30 entries → prune |

Splits / consolidations in 2-mind/ → apply directly (T1). In
3-control/ → propose (T2). Spec-cap flags → report-only (Owner
decides whether to trim the spec doc).

### 6. Orphan + broken-ref scan

- `git ls-files | xargs grep -hoE '\[.*?\]\([^)]+\)'` → check links
- Check `@file` imports / cross-refs in spec docs

Fixes in 2-mind/ → apply (T1). In 3-control/ → propose (T2).

### 7. Low-utility scan

- Skills never invoked since creation (check git log of journal/
  for skill name mentions)
- Rules never fired (no hook history / no agent self-reference)
- garden `<topic>.md` files with no downstream references

For 2-mind/ items: archive (move to `garden/archive/low-utility/<filename>.md`)
or prune directly (T1). For 3-control/ items (rules): propose (T2).

### 8. Write audit log

Append to `2-mind/garden/audit-log.md` (create if missing):
```
## YYYY-MM-DD audit pass

**Scope**: <which directories scanned>
**Findings**: stale=N · duplicates=N · contradictions=N · over-grown=N · orphans=N · low-utility=N · journal-archived=N
**Applied** (per item): <merges, splits, archives, prunes, updates>
**Deferred / declined**: <Owner-rejected items>
**Next audit**: <date or condition>
```

## Pitfalls

- **Auto-deleting**: NEVER. Always archive (move to
  `garden/archive/`) — R3 requires source preserved.
- **Touching 3-control/ autonomously**: all 3-control/ paths
  (foundation/, rule/, external/, runtime/) are T2 — propose, never
  auto-apply. The folder boundary is the tier boundary.
- **Full audit when scoped audit requested**: if Owner asks
  `/audit stale`, scan only that class.
- **Skipping the audit log**: the log is the source-trail for what
  changed when — critical for future audits.

## Verification

- 6 issue classes scanned (or explicitly skipped per request scope)
- Journal entries >3 months moved to `garden/archive/<YYYY-MM>/`
- T1 changes applied directly (2-mind/ items: garden + forge)
- T2 changes ratified by Owner per item (3-control/ items only)
- `2-mind/garden/audit-log.md` updated with this pass
- `git status` reflects all applied changes
