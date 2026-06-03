# Adoption

How to adopt workspace.md — into a fresh repo or one that already has
content. Covers the spec-vs-adopter boundary, store migration, and the
conventions adopters most often collide with.

## Spec repo vs your workspace

The **upstream workspace.md repo** is both the spec definition and the
clonable starter template. That dual role means some shipped files
describe *the spec project*, not *your workspace*. On adoption, re-home
them (this keeps this file true even when kept verbatim downstream):

| File | Ships as | On adoption |
|---|---|---|
| `3-control/foundation/SOUL.md` | spec-repo caretaker identity | **Replace** the section contents (keep the section structure) — see its Adopter note |
| `AGENTS.md` | "This repo defines the workspace.md specification…" | **Re-home** the intro to describe *your* workspace; keep the §Reading order + per-runtime mapping (or rely on the canonical read order in `use-driven-memory.md`) |
| `README.md` | public entry for the spec project ("sole adopter…") | **Replace or delete** — it documents the spec project, not your workspace |
| `WORKSPACE.md`, `PRINCIPLE.md`, `use-driven-memory.md`, `runtime-flexibility.md`, this file | the spec proper | **Keep verbatim** — this is the spec you adopted; upgrade by pulling new spec versions |
| `garden/essential/{USER,NEXT,SOUL}.md`, `journal/ENTRY-TEMPLATE.md` | empty seeds | **Keep** — they fill via use, never pre-populate |

The spec deliberately does not auto-rewrite these on clone (no
generator yet, v0.x). Until a `template/` skeleton is split out, the
re-homing above is manual. `init` briefs it.

## Adopting into an existing workspace (non-greenfield)

The memory model assumes an empty start that grows. If you already
have equivalent structures (e.g. an `owner-profile.md` ≈ `USER.md`, a
`log.md` ≈ `journal/`), decide **per store** how the spec store relates
to your pre-existing one — do not leave two stores with overlapping
roles and no canonical source:

- **Supersede** — migrate content into the spec store, retire the old
  one with a freeze banner (see *Freezing a store* below). Best when
  the old store maps cleanly onto the spec store.
- **Wrap** — keep the large pre-existing store as the system of
  record; let the spec store hold the *hot subset* the agent loads at
  session-start (e.g. `USER.md` = distilled top of a bigger profile).
  Cite the source in each entry per R3.
- **Coexist** — keep both with an explicit, documented boundary (which
  store owns what). Only when the roles genuinely differ; record the
  split so it isn't mistaken for drift.

Pick one *before* the first `dream`/`audit` pass so consolidation
doesn't fork the content. Record the choice in the store's header.

For a pre-existing **`AGENTS.md`** specifically (common for AAIF
adopters), see `2-mind/forge/act/skill/init/SKILL.md §Existing AGENTS.md
handoff`.

## Metadata / frontmatter convention

The spec is **metadata-free**: spec files and template seeds carry no
`domain:` / `data_sensitivity:` (or any) YAML frontmatter. If your
workspace mandates universal frontmatter, **exempt** the following so
the carve-out is expected rather than a per-path surprise in your
linter:

- Verbatim spec docs (`WORKSPACE.md`, `PRINCIPLE.md`,
  `use-driven-memory.md`, `runtime-flexibility.md`, this file)
- `3-control/foundation/` canonical docs
- `garden/essential/` template seeds
- Imported lifecycle skills under `2-mind/forge/act/skill/`
- **`journal/*.md` entries** — `ENTRY-TEMPLATE.md` ships without
  frontmatter, so entries written by `session-end` inherit that.
  Journal entries are **intentionally frontmatter-free**; the
  R3 episodic header (Started / Closed / Runtime / Working dir) is
  their metadata. Do not let one runtime add frontmatter and another
  omit it — the silence here was the bug (issue #15); this pins it.

If instead you *want* journal frontmatter, change `ENTRY-TEMPLATE.md`
once and remove `journal/*.md` from the exemption list — but pin it in
one place either way.

## Freezing a store

When you retire / freeze a store (banner like `⛔ RETIRED / FROZEN`, or
a `status: frozen` header), the freeze does **not** auto-propagate to
instruction sites that still tell agents to write to it. Before
considering a freeze done, grep for active verbs (`append|write|record|
log to`) near the frozen filename across `2-mind/forge/` +
`2-mind/garden/` and redirect or remove them — a freeze can otherwise
land "green" while live skill/orientation pages still route writes into
the dead store (issue #16). `audit`'s contradiction + orphan scans are
the backstop; the freeze author is the first line.
