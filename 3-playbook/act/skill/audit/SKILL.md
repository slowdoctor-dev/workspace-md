---
name: audit
description: Periodic maintenance pass — 6-class issue scan + journal archival (>3 months old → factory/archive/<YYYY-MM>/). Companion to learn (accumulation); audit handles forgetting and consolidation.
---

# audit

## When to use

- **Monthly** by default (or every N sessions, per workspace cadence)
- **On size-limit breach** (USER.md hits 100, factory/<topic>.md
  exceeds adopter's threshold)
- **After bulk additions** (post-migration, post-research-heavy
  period)
- **Explicit `/audit`** Owner invocation

Operational instance of *Ebbinghaus forgetting curve* + *interference
theory* mitigation. Complement to `learn` (which accumulates).
Without `audit`, the workspace drifts toward clutter; without `learn`,
the workspace doesn't accumulate. Both are needed.

## Quick reference

| Issue class | What to look for | Action |
|---|---|---|
| 1. Stale | references to deleted/renamed files; entries with old `last_verified` | update or prune |
| 2. Duplicates | two files on same topic; same rule in multiple places | merge to canonical home |
| 3. Contradictions | rules/principles in tension; old vs new claims | resolve (keep newer; annotate older) |
| 4. Over-grown | files exceeding their bounds (USER >100; etc.) | split or consolidate |
| 5. Orphans | dead links; broken cross-refs | fix paths or remove refs |
| 6. Low-utility | skills never invoked; rules never fired | archive or prune |

Plus: journal archival pass (entries >3 months → archive).

## Procedure

### 1. Journal archival (the main mechanical task)

Scan `2-mind/factory/essential/journal/` for entries with date prefix
older than 3 months from today.

For each old entry:
- `mkdir -p 2-mind/factory/archive/<YYYY-MM>/` (year-month of entry)
- `git mv 2-mind/factory/essential/journal/<entry>.md 2-mind/factory/archive/<YYYY-MM>/`

Archived entries remain searchable via grep but are not auto-loaded.

### 2. Stale scan

- Grep for paths that no longer resolve (e.g., references to
  `4-control/principle/` or `4-control/setting/` after foundation/
  consolidation)
- Check entries with `last_verified:` frontmatter older than 6 months
  (for non-time-anchored content)

Propose updates or prunes to Owner per item (T2).

### 3. Duplicate scan

- Walk `factory/<topic>.md` files; look for overlapping topics
- Check if rules duplicate between `4-control/rule/` and any
  per-agent `rules/`
- Scan USER.md for repeated entries

Propose merges to canonical home (T2).

### 4. Contradiction scan

- Compare PRINCIPLE.md statements with SOUL.md / WORKSPACE.md for
  internal consistency
- Look for "previously did X but now Y" patterns in factory content
  without explicit resolution

Propose resolution (T2): keep newer, annotate older.

### 5. Over-grown scan

| File | Bound |
|---|---|
| `USER.md` | 100 lines |
| `SOUL.md` (working) | no hard cap; Graduated section ≥30 entries |
| journal entry | 200 lines soft |
| factory `<topic>.md` | no fixed cap; flag >300 lines |
| `PRINCIPLE.md` | no fixed cap; flag >250 lines |

Propose splits or consolidations for files breaching bounds (T2).

### 6. Orphan + broken-ref scan

- `git ls-files | xargs grep -hoE '\[.*?\]\([^)]+\)'` → check links
- Check `@file` imports / cross-refs in spec docs

Propose fixes (T2).

### 7. Low-utility scan

- Skills never invoked since creation (check git log of journal/
  for skill name mentions)
- Rules never fired (no hook history / no agent self-reference)
- factory `<topic>.md` files with no downstream references

Propose archive (move to `factory/archive/low-utility/<filename>.md`)
or prune (T2).

### 8. Write audit log

Append to `2-mind/factory/audit-log.md` (create if missing):
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
  `factory/archive/`). R3 source-monitoring requires source preserved.
- **Touching Owner-canonical files (foundation/) autonomously**:
  ALL foundation/ changes are T2. Always propose, never auto-apply.
- **Full audit when only specific class needed**: if Owner asks
  "/audit stale", scan only stale class; don't drag in others.
- **Skipping the audit log**: the log is the source-trail for what
  was changed when — critical for future audits.

## Verification

- 6 issue classes scanned (or explicitly skipped per request scope)
- Journal entries >3 months moved to `factory/archive/<YYYY-MM>/`
- All applied changes have Owner ratification
- `2-mind/factory/audit-log.md` updated with this pass
- `git status` reflects only Owner-accepted commits
