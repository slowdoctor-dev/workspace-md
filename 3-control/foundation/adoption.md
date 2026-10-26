# Adoption

How to adopt workspace.md — into a fresh repo or one that already has
content. Covers first use, the entry file, how much to keep vs adapt,
the spec-vs-adopter boundary, store migration, and the conventions
adopters most often collide with.

## First use (quick start)

Starting a brand-new workspace? Use this repo as the template:

1. **Clone it as your workspace** — `git clone <repo> my-workspace`.
2. **Re-home the spec-vs-yours files** — see *Spec repo vs your
   workspace* below (replace the `SOUL.md` identity, re-home the
   `AGENTS.md` intro line, replace/delete `README.md`).
3. **Run `init`** — your agent reads
   `2-mind/forge/act/skill/init/SKILL.md`: it verifies structure, runs
   `detect-runtime`, proposes `3-control/runtime/profile.md` for you
   to ratify (a fresh clone ships none → tier defaults to `standard`),
   and exposes the native aliases your harness needs.
4. **Start working** — `session-start` loads the 5-item hot read
   order; `session-end` writes a journal entry + `NEXT.md` block;
   `dream` distils journals into `USER.md` + working `SOUL.md` after
   substantive sessions.

Don't pre-populate the memory seeds (`USER.md`, `NEXT.md`, working
`SOUL.md`) — they fill through use.

## Entry file

`AGENTS.md` is the single entry. Current harnesses read it natively
(Codex CLI, Claude Code ≥2.1.277, Antigravity CLI, Cursor, Copilot…),
so **no symlinked `CLAUDE.md` / `GEMINI.md` is shipped** (removed in
v0.2.0). If a session cannot read `AGENTS.md` (older Claude Code,
some Bedrock sessions, a harness without AAIF support), add a one-line
fallback file and commit it:

```
# CLAUDE.md
@AGENTS.md
```

Keep `AGENTS.md` an **operational card** (≤80 lines): hot read order,
rules in one line, native-alias map. Explanatory prose belongs in
`README.md`; spec text in `WORKSPACE.md`. Context files that read like
a README measurably lower agent success and raise cost (ETH 2026).

## Conformance & flexibility

workspace.md is *one approach, not THE approach* — adopt the
load-bearing parts and adapt the rest. Three levels:

### Core — keep (load-bearing)

- the 4 top folders (`0-storage/ 1-active/ 2-mind/ 3-control/`)
- the mandated sub-paths: `2-mind/garden/`, `2-mind/forge/`,
  `3-control/foundation/SOUL.md`, `3-control/foundation/PRINCIPLE.md`
- the session-boundary discipline (R2 — writes settle between
  sessions; `session-start` loads, `session-end` writes)

### Recommended — keep unless you have a reason

- the 6 lifecycle skills
- the `garden/essential/` stores + rules R1, R3, R4, R5
- the runtime profile + tier *mechanism*; `cue/lifecycle.md` where
  your harness has hooks; `rule/trust.md`

### Adapt freely — calibrate to your context

- the cap *numbers* — defensibly grounded, not empirically validated
- naming conventions, which optional folders you create, journal id
  scheme (`NNN` vs session id)
- your own rules in `3-control/rule/` (non-`Rn` prefix)
- identity / person content (`SOUL.md`, `USER.md`) — workspace-
  specific, not spec-fixed
- harness-native memory: keep it on as an inbox `dream` ingests, or
  turn it off (`3-control/runtime/<harness>.md`)

Rule of thumb: **keep the skeleton and the session rhythm; treat the
numbers, names, and optional structure as defaults, not law.**

## Spec repo vs your workspace

The upstream repo is both the spec definition and the clonable starter
template, so some shipped files describe *the spec project*. On
adoption, re-home them:

| File | Ships as | On adoption |
|---|---|---|
| `3-control/foundation/SOUL.md` | spec-repo caretaker identity | **Replace** section contents (keep section structure) |
| `AGENTS.md` | card for the spec's own workspace | **Re-home** the first line; keep §Hot read order + §Rules + §Per-runtime entry |
| `README.md` | public entry for the spec project | **Replace or delete** |
| `WORKSPACE.md`, `PRINCIPLE.md`, `use-driven-memory.md`, `runtime-flexibility.md`, this file | the spec proper | **Keep verbatim**; upgrade by pulling new spec versions |
| `3-control/rule/trust.md`, `2-mind/forge/cue/lifecycle.md` | baseline rule / hook spec | **Keep**; extend with your own entries |
| `3-control/runtime/<harness>.md` | adapter notes with `last_verified` | **Keep the ones you use**; delete the rest |
| `garden/essential/{USER,NEXT,SOUL}.md`, `journal/ENTRY-TEMPLATE.md` | template seeds | **Keep** — they fill via use |

No generator yet (v0.x); re-homing is manual. `init` briefs it.

## Private memory

`USER.md` and the journal describe a person. In a **public** repo
either keep `2-mind/garden/essential/` in a private submodule / second
remote, or add it to `.gitignore` and accept that memory is then
machine-local. Record the choice in `USER.md`'s header.

## Adopting into an existing workspace (non-greenfield)

If you already have equivalent structures (`owner-profile.md` ≈
`USER.md`, `log.md` ≈ `journal/`), decide **per store** how the spec
store relates to yours — never two stores with overlapping roles and
no canonical source:

- **Supersede** — migrate into the spec store, retire the old one with
  a freeze banner (see *Freezing a store*).
- **Wrap** — keep the large store as system of record; the spec store
  holds the *hot subset* loaded at session-start. Cite the source per R3.
- **Coexist** — keep both with an explicit, documented boundary.

Pick one *before* the first `dream`/`audit` pass. Record the choice in
the store's header. For a pre-existing **`AGENTS.md`**, see
`2-mind/forge/act/skill/init/SKILL.md §Existing AGENTS.md handoff`.

## Headless and cloud sessions

Scheduled runs, CI, and cloud sessions cannot ratify T2 in-session.
They write T1 freely (journal, `NEXT.md` block) and route T2 through
the **PR channel**: branch + PR, merge = ratify, with a record in
`1-active/proposals/`. Use runtime slug `cron` / `ci` / `cloud` in the
journal filename.

## Metadata / frontmatter convention

Foundation/topology docs and template seeds are **metadata-free**.
`SKILL.md` files carry Agent Skills frontmatter limited to the
portable six fields (`WORKSPACE.md §Conventions`). If your workspace
mandates universal frontmatter, **exempt**:

- verbatim spec docs and `3-control/foundation/` canonical docs
- `garden/essential/` template seeds
- lifecycle skills under `2-mind/forge/act/skill/`
- **`journal/*.md`** — intentionally frontmatter-free; the Started /
  Closed / Runtime / Working-dir header is their R3 metadata. Pin it
  once in `ENTRY-TEMPLATE.md` and keep it identical across runtimes.

## Freezing a store

When you retire a store (banner `⛔ RETIRED / FROZEN` or `status:
frozen`), the freeze does **not** propagate to instruction sites that
still tell agents to write to it. Grep for active verbs (`append|write|
record|log to`) near the frozen filename across `2-mind/forge/` +
`2-mind/garden/` and redirect or remove them. `audit`'s contradiction +
orphan scans are the backstop; the freeze author is the first line.
