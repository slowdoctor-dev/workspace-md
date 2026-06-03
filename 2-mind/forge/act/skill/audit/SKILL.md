---
name: audit
description: General-purpose workspace maintenance pass. Cross-cutting enforcement of multiple core values (One canonical home / Use-driven evolution) and rules (R1 capacity backstop / R3 source-trail integrity + citation backstop). Every action respects R4 T1-T2 boundary procedurally. 7-class issue scan + journal archival (>3 months old → garden/archive/<YYYY-MM>/) + audit-log write. May invoke `detect-runtime` for known-constants freshness re-check.
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

## Requires

Requires `3-control/foundation/SOUL.md`,
`3-control/foundation/PRINCIPLE.md`, and `2-mind/garden/essential/`
to exist. If any are missing, run `init` instead of continuing.

## Quick reference

Each scan class enforces a specific value or rule:

| # | Issue class | What to look for | Action | Serves |
|---|---|---|---|---|
| 1 | Stale | broken paths; old `last_verified`; broken symlinks; profile.md staleness/completeness | update or prune | One canonical home + R3 + schema integrity |
| 2 | Duplicates | two files on same topic; rule in multiple places; convenience-summary drift | merge to canonical home | **One canonical home** |
| 3 | Contradictions | rules/principles in tension; old vs new claims | resolve (keep newer; annotate older) | One canonical home + internal consistency |
| 4 | Over-grown | files exceeding their cap | split or consolidate | **R1 backstop** (× R2 tier) |
| 5 | Orphans | dead links; broken cross-refs | fix paths or remove refs | One canonical home (link integrity) |
| 6 | Citation gaps | synthesized entries missing `(journal …)` citation | flag for `dream` to fix | **R3 backstop** (source-trail integrity) |
| 7 | Low-utility | skills never invoked; rules never fired | archive or prune | Use-driven evolution (pruning) |

Plus two mechanical steps that serve **R3 source-trail integrity**:
- Journal archival pass (entries >3 months → archive)
- Audit-log write (records what changed when)

May invoke `detect-runtime` skill in freshness-check mode to
re-verify hosted-backend known-constants table when its
`last_verified:` marker is >6 months old.

## Procedure

### 1. Journal archival (the main mechanical task)

Scan `2-mind/garden/essential/journal/` for entries with date prefix
>3 months old. For each:
- `mkdir -p 2-mind/garden/archive/<YYYY-MM>/` (year-month of entry)
- `git mv 2-mind/garden/essential/journal/<entry>.md 2-mind/garden/archive/<YYYY-MM>/`

Archived entries stay grep-searchable but no longer auto-load.

### 2. Stale scan

Four checks:

**A. Broken paths in content** — grep for paths that no longer
resolve (e.g., references to pre-restructure paths like `4-control/`
or `3-playbook/`).

**B. `last_verified` freshness** — entries with `last_verified:`
markers older than 6 months. Markers may be frontmatter or
section-level. Highest-stake target:
`2-mind/forge/act/skill/detect-runtime/SKILL.md` known-constants
table (hosted-backend effective_context values evolve with model
releases). If detect-runtime's known-constants are >6 months stale,
optionally invoke `detect-runtime` skill in freshness-check mode +
present updated constants to Owner for re-ratify of the table.

**C. Symlink integrity** — verify committed symlinks (`CLAUDE.md`,
`GEMINI.md`, `.mcp.json`, `.agents/skills`) still resolve. WSL DrvFs
has been observed to silently convert symlinks to regular files;
`git ls-files -s` + mode `120000` check + target-exists check.

**D. profile.md health** — for `3-control/runtime/profile.md`
(when present):
- Schema completeness: all 6 required fields populated
  (`harness`, `backend_provider`, `backend_endpoint`, `backend_model`,
  `effective_context`, `active_tier`) — or annotated `(uncertain —
  <reason>)`
- Staleness: `last_updated` >3 months without re-ratify → flag for
  Owner attention (runtime may have drifted)

Stale items in 2-mind/ → fix or prune directly (T1).
Stale items in 3-control/ → propose to Owner (T2). Symlink + profile.md
issues are surfaced for Owner since they cross-cut tier boundaries.

### 3. Duplicate scan

- Walk `garden/<topic>.md` files; look for overlapping topics
- Check if rules duplicate between `3-control/rule/` and per-agent
  `rules/` (if exists in `forge/role/<agent>/rules/`)
- Scan USER.md for repeated entries
- Scan `forge/act/skill/` for skills with overlapping scope
- **Convenience-summary drift**: check acknowledged summaries against
  their canonical sources. Summary columns may differ for operator
  convenience; numeric cap values, rows/list items, and ordering must
  match the canonical source.
  - Active `3-control/runtime/profile.md` (created from
    `profile.example.md`) *Tier reference* summary ↔
    `3-control/foundation/runtime-flexibility.md` *Tier system*
  - `2-mind/forge/act/skill/dream/SKILL.md` cap summary ↔
    `3-control/foundation/runtime-flexibility.md` *Tier system*
  - `2-mind/forge/act/skill/audit/SKILL.md` cap summary below ↔
    `3-control/foundation/runtime-flexibility.md` *Tier system*
  - `AGENTS.md` read-order summary ↔
    `3-control/foundation/use-driven-memory.md` §Read order
  - `2-mind/forge/act/skill/detect-runtime/SKILL.md` §Sub-step 4
    tier-derivation summary ↔ `runtime-flexibility.md`
    *Tier-derivation rule*
  Drift is unacceptable; point summaries at the canonical source when
  exact synchronization is too costly.

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
  topic) — token-primary content-discipline baselines, defined in
  `3-control/foundation/use-driven-memory.md §R1` and counted with
  `2-mind/forge/act/script/token-count.sh`.
- **R2 runtime-tier override** — scales R1 caps down (lean) or up
  (extended) per the active runtime profile. Tier system + rule:
  `3-control/foundation/runtime-flexibility.md`. Active selection:
  `3-control/runtime/profile.md` (default `standard` = R1 baseline
  unchanged).
- **R1 spec caps** (README, AGENTS, WORKSPACE, PRINCIPLE, canonical
  SOUL, use-driven-memory, runtime-flexibility, adoption) — fixed advisory
  line-count flags, runtime-independent.

Operational token tier summary for use-grown memory stores. Numeric cap
values must match `3-control/foundation/runtime-flexibility.md`;
columns may differ for operator convenience.

| Tier | USER (hard / consol) | NEXT | journal/<entry> | garden-topic |
|---|---|---|---|---|
| `lean` | 500 / 400 | 170 | 1200 | 2000 |
| `standard` | 800 / 640 | 240 | 2000 | 3200 |
| `extended` | 1600 / 1280 | 400 | 4000 | 6400 |

For each memory file, look up its effective token cap (R1 × R2 tier
scale) and compare `token-count.sh <path>` output. Include line count
as advisory context in the report, but do not use it to decide
memory-cap compliance. Working `SOUL.md` (in garden) has no cap but
prune *Graduated* entries older than 6 months.

Memory-cap breach in `2-mind/garden/` + `2-mind/forge/` → split or
consolidate directly (T1). Memory-cap breach in `2-mind/atelier/`
(T2-when-content-exists exception) → propose to Owner.
Spec-cap breach remains line-based → flag only; Owner decides whether
to trim (3-control/ content is T2).

### 6. Orphan + broken-ref scan

- `git ls-files | xargs grep -hoE '\[.*?\]\([^)]+\)'` → check links
- Check `@file` imports / cross-refs in spec docs

Fixes in 2-mind/ → apply (T1). In 3-control/ → propose (T2).

### 7. Citation-gap scan (R3 backstop)

R3 says every synthesized entry in semantic stores carries a
`(journal <YYYY-MM-DD>-<runtime>-<NNN>)` citation. `dream` is the
primary enforcer at write-time; `audit` is the backstop.

Walk these targets:
- `2-mind/garden/essential/USER.md` — every entry under any section
  (Preferences / Patterns / Tells) must carry a citation
- `2-mind/garden/essential/SOUL.md` — *Observations* + *Owner-signals*
  sections; *Graduated* entries carry the
  `[graduated YYYY-MM-DD → 3-control/foundation/SOUL.md]` marker
  instead of a journal citation (acceptable)
- `2-mind/garden/<topic>.md` (and `<topic>/<sub>.md`) — synthesized
  domain notes must carry citations

For each entry without a citation: flag for `dream` to backfill from
journal sources. Do NOT delete uncited entries — they may be valid
but mis-discipline; `dream`'s job is to find their source and add
the citation.

Citation gaps in 2-mind/ → flag for `dream` (T1). Persistent gaps
across multiple audits → surface to Owner (the discipline may need
re-clarification in the spec).

### 8. Low-utility scan

- Skills never invoked since creation (check git log of journal/
  for skill name mentions)
- Rules never fired (no hook history / no agent self-reference)
- garden `<topic>.md` files with no downstream references

For 2-mind/ items: archive (move to `garden/archive/low-utility/<filename>.md`)
or prune directly (T1). For 3-control/ items (rules): propose (T2).

### 9. Write audit log

Append to `2-mind/garden/audit-log.md` (create if missing):
```
## YYYY-MM-DD audit pass

**Scope**: <which directories scanned>
**Findings**: stale=N · duplicates=N · contradictions=N · over-grown=N · orphans=N · low-utility=N · citation-gaps=N · journal-archived=N
**Applied** (per item): <merges, splits, archives, prunes, updates>
**Deferred / declined**: <Owner-rejected items>
**Owner-surfaced**: <symlink breaks, profile.md staleness/incompleteness, persistent citation gaps>
**Next audit**: <date or condition>
```

## Pitfalls

- **Auto-deleting**: NEVER. Always archive (move to
  `garden/archive/`) — R3 requires source preserved.
- **Touching 3-control/ autonomously**: all 3-control/ paths
  (foundation/, rule/, external/, runtime/) are T2 — propose, never
  auto-apply. The folder boundary is the tier boundary.
- **Auto-applying to 2-mind/atelier/**: atelier is the
  T2-when-content-exists exception inside `2-mind/`. Propose, don't
  apply.
- **Deleting uncited entries**: citation-gap scan flags entries
  missing `(journal …)` citations for `dream` to backfill —
  these are valid content with mis-discipline, not garbage. Do not
  prune them in the citation-gap scan.
- **Silently fixing symlinks**: broken symlinks indicate a real
  filesystem issue (often WSL DrvFs); surface to Owner before
  restoring from git.
- **Full audit when scoped audit requested**: if Owner asks
  `/audit stale`, scan only that class.
- **Skipping the audit log**: the log is the source-trail for what
  changed when — critical for future audits.

## Verification

- 7 issue classes scanned (or explicitly skipped per request scope)
- Journal entries >3 months moved to `garden/archive/<YYYY-MM>/`
- Symlinks (`CLAUDE.md`, `GEMINI.md`, `.mcp.json`, `.agents/skills`)
  verified to resolve
- `profile.md` (when present) checked for 6-field completeness +
  `last_updated` recency
- Citation-gap scan ran over `USER.md`, `garden/essential/SOUL.md`,
  `garden/<topic>.md`; gaps flagged for `dream` (T1)
- T1 changes applied directly (`2-mind/garden/` + `2-mind/forge/`);
  `2-mind/atelier/` items proposed (T2 exception)
- T2 changes ratified by Owner per item (`3-control/` items)
- `2-mind/garden/audit-log.md` updated with this pass
- `git status` reflects all applied changes
