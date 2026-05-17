---
name: audit
description: General-purpose workspace maintenance pass. Cross-cutting enforcement of multiple core values (One canonical home / Use-driven evolution) and rules (R1 capacity backstop / R3 source-trail integrity). Every action respects R4 T1-T2 boundary procedurally. 6-class issue scan + journal archival (>3 months old → garden/archive/<YYYY-MM>/) + audit-log write.
---

# audit

## When to use

- **Monthly** by default (or every N sessions, per workspace cadence)
- **On size-limit breach** (R1 cap exceeded; primary R1 enforcement
  is `dream` consolidate-on-error — `audit` is the backstop)
- **After bulk additions** (post-migration, post-research-heavy)
- **Explicit `/audit`** Owner invocation

`audit` is the workspace's janitor — it doesn't accumulate, it keeps
things tidy. Each scan class serves a specific value or rule (see
Quick reference). Companion to `dream`: `dream` accumulates +
consolidates at write-time; `audit` verifies + prunes periodically.

## Quick reference

Each scan class enforces a specific value or rule:

| # | Issue class | What to look for | Action | Serves |
|---|---|---|---|---|
| 1 | Stale | references to deleted/renamed files; old `last_verified` | update or prune | One canonical home + R3 |
| 2 | Duplicates | two files on same topic; rule in multiple places | merge to canonical home | **One canonical home** |
| 3 | Contradictions | rules/principles in tension; old vs new claims | resolve (keep newer; annotate older) | One canonical home + internal consistency |
| 4 | Over-grown | files exceeding their cap | split or consolidate | **R1 backstop** (× R2 tier) |
| 5 | Orphans | dead links; broken cross-refs | fix paths or remove refs | One canonical home (link integrity) |
| 6 | Low-utility | skills never invoked; rules never fired | archive or prune | Use-driven evolution (pruning) |

Plus two mechanical steps that serve **R3 source-trail integrity**:
- Journal archival pass (entries >3 months → archive)
- Audit-log write (records what changed when)

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

Cap sources:
- **R1 natural memory caps** (USER, NEXT, journal entry, garden
  topic) — content-discipline baselines, defined in
  `3-control/foundation/use-driven-memory.md §R1`.
- **R2 runtime-tier override** — scales R1 caps down (lean) or up
  (extended) per the active runtime profile. Tier system + rule:
  `3-control/foundation/runtime-flexibility.md`. Active selection:
  `3-control/runtime/profile.md` (default `standard` = R1 baseline
  unchanged).
- **R1 spec caps** (AGENTS, WORKSPACE, PRINCIPLE, canonical SOUL,
  use-driven-memory, runtime-flexibility) — fixed advisory flags,
  runtime-independent.

For each file, look up its effective cap (R1 × R2 tier scale) and
compare current line count. Working `SOUL.md` (in garden) has no
cap but prune *Graduated* entries older than 6 months.

Memory-cap breach in 2-mind/ → split or consolidate directly (T1).
Spec-cap breach → flag only; Owner decides whether to trim (3-control/
content is T2).

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
