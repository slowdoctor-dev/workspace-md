---
name: audit
description: General-purpose workspace maintenance pass. Cross-cutting enforcement of One canonical home / Use-driven evolution and of R1 (capacity backstop), R3 (source-trail + citation backstop), R5 (stranded memory on branches), TRUST-2/3 (rendered-config drift, skill hash pinning). 8-class issue scan + journal archival (>3 months → garden/archive/<YYYY-MM>/) + metrics line + audit-log write. Respects the T1/T2 boundary procedurally.
---

# audit

## When to use

- **Monthly** by default (or every N sessions, per workspace cadence)
- **On size-limit breach** (R1 cap exceeded; `dream` is the primary
  enforcer — `audit` is the backstop)
- **After bulk additions** (post-migration, post-research-heavy)
- **After a spec upgrade** (drift between summaries and canonical)
- **Explicit `/audit`** Owner invocation

`audit` is the workspace's janitor. Run from the integration branch,
preferably as a **forked subagent** (keeps the caller's cache intact).
Companion to `dream`: `dream` accumulates + consolidates at write-time;
`audit` verifies + prunes periodically.

## Requires

Requires `3-control/foundation/SOUL.md`,
`3-control/foundation/PRINCIPLE.md`, and `2-mind/garden/essential/`
to exist. If any are missing, run `init` instead of continuing.

## Quick reference

| # | Issue class | What to look for | Action | Serves |
|---|---|---|---|---|
| 1 | Stale | broken paths; `last_verified` >6 months; broken symlinks; profile.md completeness | update or prune | One canonical home + R3 |
| 2 | Duplicates | two files on one topic; rule in multiple places; **convenience-summary drift** | merge to canonical home | **One canonical home** |
| 3 | Contradictions | rules/principles in tension; old vs new claims | keep newer; annotate older | internal consistency |
| 4 | Over-grown | files exceeding their cap | split or consolidate | **R1 backstop** (× R2 tier) |
| 5 | Orphans | dead links; broken cross-refs | fix or remove | link integrity |
| 6 | Citation gaps | synthesized entries without a citation | flag for `dream` | **R3 backstop** |
| 7 | Low-utility | skills never invoked; rules never fired | archive or prune | Use-driven evolution |
| 8 | Stranded / untrusted | garden writes on unmerged branches; rendered configs drifted from canonical; imported skills with changed hash; non-portable skill frontmatter | surface / re-render / flag | **R5 + TRUST-2/3** |

Plus three mechanical steps: journal archival, **metrics line**, and
audit-log write.

## Procedure

### 1. Journal archival

Entries in `2-mind/garden/essential/journal/` with date prefix >3
months old → `git mv` to `2-mind/garden/archive/<YYYY-MM>/` (create
lazily). Archived entries stay grep-searchable.

### 2. Stale scan

**A. Broken paths in content** — grep for paths that no longer
resolve (pre-restructure paths, removed files such as `CLAUDE.md`
symlink references, `effective_context`-era wording).

**B. `last_verified` freshness** — markers older than 6 months
(frontmatter or section-level): `3-control/runtime/<harness>.md`
adapters. Propose re-verification to Owner (T2); do not auto-edit.

**C. Symlink integrity** — committed symlinks (`.claude/skills`,
`.agents/skills`, `.mcp.json`, plus any adopter-added) resolve:
`git ls-files -s` mode `120000` + target exists. WSL DrvFs and
`sed -i` silently convert symlinks to files.

**D. profile.md health** — all 6 required fields present
(`harness`, `backend_provider`, `backend_endpoint`, `backend_model`,
`model_class`, `active_tier`) or `(uncertain — …)`; `model_class` is a
known value; `last_updated` >3 months → flag.

Stale in 2-mind/ → fix (T1). Stale in 3-control/ or symlinks → propose
(T2).

### 3. Duplicate scan

- `garden/<topic>.md` overlap; `USER.md` repeated entries; skills with
  overlapping scope; rules duplicated between `3-control/rule/` and
  `forge/role/<agent>/rules/`.
- **Convenience-summary drift** — summaries must match their canonical
  source in numbers, items, and order:
  - `profile.md` *Tier reference* ↔ `runtime-flexibility.md §Tier system`
  - `dream/SKILL.md` and this file's cap tables ↔ same
  - `AGENTS.md §Hot read order` and `session-start/SKILL.md §2` ↔
    `use-driven-memory.md §Read order`
  - `detect-runtime/SKILL.md §Sub-step 4` ↔ `runtime-flexibility.md
    §Tier-derivation rule`
  - rendered hook / MCP configs ↔ `cue/lifecycle.md` /
    `external/mcp/registry.json` (see class 8)

In 2-mind/ → merge (T1). In 3-control/ → propose (T2).

### 4. Contradiction scan

PRINCIPLE.md ↔ SOUL.md ↔ WORKSPACE.md ↔ AGENTS.md consistency;
"previously X, now Y" in garden without resolution. Keep newer,
annotate older (T2 if 3-control/ involved).

### 5. Over-grown scan

Cap sources: R1 memory caps (tokens, `use-driven-memory.md §R1`),
R2 tier override (`runtime-flexibility.md`, active `profile.md`), R1
spec caps (lines). Operational tier summary — numeric values must
match `runtime-flexibility.md`:

| Tier | USER (hard / consol) | NEXT (total unconsumed) | journal/<entry> | garden-topic |
|---|---|---|---|---|
| `lean` | 500 / 400 | 170 | 1200 | 2000 |
| `standard` | 800 / 640 | 240 | 2000 | 3200 |
| `extended` | 1600 / 1280 | 400 | 4000 | 6400 |

Compare `token-count.sh <path>` against the effective cap; line count
is advisory only. Working `SOUL.md`: no cap; prune *Graduated* >6
months. Breach in `2-mind/garden/` + `forge/` → split/consolidate (T1);
in `atelier/` → propose; spec-cap breach → flag only.

### 6. Orphan + broken-ref scan

`git ls-files | xargs grep -hoE '\[.*?\]\([^)]+\)'` → check links;
check `@path` imports and cross-refs in spec docs. Fix (T1) / propose
(T2).

### 7. Citation-gap scan (R3 backstop)

Every synthesized entry carries `(journal …)`, `(auto-memory …)`, or
`(owner …)`. Walk `USER.md` (all sections), `garden/essential/SOUL.md`
(*Observations* / *Owner-signals*; *Graduated* entries carry the
graduation marker instead), `garden/<topic>.md`. Uncited → flag for
`dream` to backfill. Never delete uncited entries.

### 8. Stranded / untrusted scan (R5 + TRUST)

- **Stranded memory**: `git log --all --not main -- 2-mind/garden/`
  (or the integration branch name) → garden writes on unmerged
  branches; surface to Owner with the branch names.
- **Rendered-config drift** (TRUST-2): for each rendered file
  (`.claude/settings.json` hooks, `.codex/config.toml` servers/hooks,
  `.agents/mcp_config.json`, `.claude/agents/*.md`), compare against
  its canonical source (`cue/lifecycle.md`, `registry.json`,
  `forge/role/`) via the `rendered_from` note; propose re-render (T2).
- **Skill provenance** (TRUST-3): skills with `metadata.source`
  recompute `sha256(SKILL.md)` and compare to `metadata.sha256`;
  mismatch → flag. Skills with frontmatter outside the portable six
  fields → flag (portability).
- **Secret patterns** (TRUST-4): grep tracked files for key-like
  strings (`sk-`, `AKIA`, `-----BEGIN`); surface immediately.

### 9. Low-utility scan

Skills never invoked (journal mentions), rules never fired, garden
topics with no downstream refs. 2-mind/ → archive to
`garden/archive/low-utility/` or prune (T1); 3-control/ → propose.

### 10. Metrics line

Measure and record (feeds cap recalibration — the spec's numbers are
not yet empirically validated):

```
metrics: tier=<t> user_tok=<n> next_tok=<n> journal_entries=<n> journal_avg_tok=<n> topics=<n> consolidations_since_last=<n> archived=<n>
```

`consolidations_since_last` = count of *Consolidations applied*
footers filled since the previous audit.

### 11. Write audit log

Append to `2-mind/garden/audit-log.md` (create if missing):

```
## YYYY-MM-DD audit pass
**Scope**: <directories scanned>
**Findings**: stale=N · duplicates=N · contradictions=N · over-grown=N · orphans=N · citation-gaps=N · low-utility=N · stranded/untrusted=N · journal-archived=N
**Applied**: <merges, splits, archives, prunes, updates>
**Deferred / declined**: <Owner-rejected items>
**Owner-surfaced**: <symlink breaks, profile.md gaps, stranded branches, drifted renders, hash mismatches, secrets>
metrics: …
**Next audit**: <date or condition>
```

## Pitfalls

- **Auto-deleting**: NEVER — archive (R3).
- **Touching 3-control/ or rendered configs autonomously**: T2 —
  propose; the folder boundary and TRUST-2 are the tier boundary.
- **Auto-applying to `2-mind/atelier/`**: T2 exception — propose.
- **Deleting uncited entries**: flag for `dream`; they are valid
  content with mis-discipline.
- **Silently fixing symlinks**: surface first; a broken symlink
  usually means a filesystem or editor issue.
- **Running from a worktree**: audit edits garden; integration branch
  only (R5).
- **Full audit when a scoped audit was requested** (`/audit stale`).
- **Skipping the metrics line or audit log**: they are the source
  trail and the only data the cap numbers will ever get.

## Verification

- 8 issue classes scanned (or explicitly skipped per request scope)
- Journal entries >3 months archived
- Symlinks resolve; `profile.md` 6 fields + recency checked
- Citation-gap scan ran; gaps flagged for `dream`
- Stranded-branch, rendered-drift, skill-hash, secret scans ran
- T1 changes applied; T2 changes proposed / ratified per item
- `audit-log.md` updated with findings + metrics line
- `git status` reflects all applied changes
