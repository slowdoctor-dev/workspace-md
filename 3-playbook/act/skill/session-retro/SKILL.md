---
name: session-retro
description: Reflect on the just-completed working session and propose durable updates to 2-mind/, 3-playbook/, and 4-control/. Extracts successes (→ skills), failures (→ hooks/rules), declared preferences (→ atelier), observations (→ factory), and orientation refinements (→ principle). The user ratifies each proposed change before it is applied. Use after session-end, or invoke mid-session for partial consolidation.
---

# Session retrospective — *use-driven evolution*

## When to use

Three invocation modes:

- **Session-end chaining** — after `session-end`, convert just-closed
  session into durable assets.
- **Mid-session periodic nudge** — Hermes-style internal nudge: after
  a substantial sub-task (e.g., ≥ 5 tool calls completed, or an error
  was recovered from, or the user corrected an approach), reflect
  before continuing.
- **Explicit user invocation** — user types `/session-retro` to force
  a consolidation pass.

Operational instance of workspace.md's Core design value of
**use-driven evolution** (`4-control/principle/principle.md`): each
session should leave behind more durable assets than it started with.

Pattern lineage (full citations in References): Anthropic's *Auto
Dream*, Nous *Hermes Agent*, community `retrospective` /
`summarize-session` / `hookify` — *layer-aware* mapping onto
workspace.md's 5-folder topology.

## Steps

### 1. Gather signals from the session

Grep the conversation transcript and recent workspace edits for
high-value patterns. Be **surgical** — full token-by-token re-read is
wasteful. Target:

- **User corrections** — "no, do X instead" / "that was wrong" /
  "we're not going to do Y"
- **Explicit save requests** — "remember this" / "let's add a rule for"
  / "this is a principle"
- **Recurring themes** — same operation performed 2+ times, same
  question asked 2+ times
- **Decisions** — architecture choices, naming choices, library
  choices, version pins
- **Failures + recoveries** — what went wrong, what fixed it (the fix
  is the lesson)
- **Declared preferences / stances** — "I want X over Y", "we always
  do Z" (Owner emic content)
- **Verified facts** — research findings, source citations, anything
  the agent looked up and confirmed

#### Hermes-style skill-creation triggers (sharp criteria)

Borrowed from Hermes Agent. A *skill* should be proposed when one of
these is true:

- The agent used **≥ 5 tool calls** to complete a non-trivial workflow
- The agent **recovered from an error / dead end** to find a working path
- The **user corrected** the agent's initial approach
- The session **discovered a non-trivial workflow** (multi-step
  procedure with decision points)

If none of the above triggers fire, the session probably produced
factory notes / atelier stance / rule refinements — not a new skill.
Resist creating thin skills.

### 2. Categorize each signal across the 5 layers

For each finding, decide which layer it belongs to. Use the
*separability* principle (`4-control/principle/principle.md`): if it
is inseparable from a runtime, ignore for this skill — it stays in the
runtime's native config. Otherwise, route:

| Signal type | Target layer / location |
|---|---|
| Owner-declared preference or stance (1st-person, quotable) | `2-mind/atelier/<topic>.md` — **quote verbatim, attribute** |
| Synthesized observation / fact collation | `2-mind/factory/<topic>-notes.md` (agent-authored) |
| Reusable procedure that requires judgment | `3-playbook/act/skill/<name>/SKILL.md` |
| Mechanical task repeated ≥ 2× | `3-playbook/act/script/<name>.sh` |
| Constraint to enforce | `4-control/rule/<topic>.md` |
| Trigger (hook, schedule, CI event) | `3-playbook/cue/<...>` (runtime-specific implementation) |
| Per-agent behavior refinement | `3-playbook/role/<agent>/AGENTS.md` |
| **Universal agent instruction** (applies to ANY agent in this workspace) | root `AGENTS.md` (AAIF universal entry) |
| Workspace orientation / philosophy refinement | `4-control/principle/principle.md` Core design values |
| Repo-level intro / adopter-facing change | `README.md` |
| One-off note that doesn't fit anywhere | `2-mind/factory/session-log.md` only |

All durable workspace files are in scope — `2-mind/`, `3-playbook/`,
`4-control/`, plus root-level files (`AGENTS.md`, `README.md`,
`.gitignore`) that are not runtime-specific. Sub-folders are
*optional* per workspace.md spec (lazy-structure) — create only when
content arrives; route to where the target already exists when
possible. Files explicitly *out of scope*: runtime-native configs
(`.claude/`, `.codex/`, `.gemini/`), forwarder symlinks (`CLAUDE.md`,
`GEMINI.md`, `.mcp.json`), and `WORKSPACE.md` (governed by
`4-control/rule/contribution.md`).

Default to **NOT** creating new subfolders. Lazy structure: a new
subfolder appears only on the *second* occurrence of a content kind.
A single first occurrence goes into an existing file or the session log.

### 3. Apply quote-verbatim rule for atelier content

Owner-issued stances go into `2-mind/atelier/` with **verbatim
quoting + attribution**, not paraphrase. The wrapper (file structure,
indexing, cross-refs) is agent-authored; the Owner's words inside
must not be rewritten. This preserves emic content at the textual
level.

For example:

    # Workspace voice

    > "Direct over polite. Concrete over abstract. Numbers when
    > available." — Owner, session YYYY-MM-DD HH:MM

### 4. Present proposals to the user (ratification step)

Show all proposals as a categorized list with brief rationale and a
preview diff per item. Use a structured format:

    Proposed changes from session YYYY-MM-DD HH:MM:

    ### Skill candidates (2)
    1. `act/skill/refactor-toml/` — codify the TOML edit pattern
       used 3× this session. Diff: <preview>
    2. `act/skill/check-runtime-attach/` — based on the verification
       sequence we ran. Diff: <preview>

    ### Rule candidates (1)
    3. `4-control/rule/no-destructive-commands-without-confirm.md`
       — extracted from corrections in turns 17, 24. Diff: <preview>

    ### Atelier additions (1)
    4. `2-mind/atelier/workspace-voice.md` — Owner's stance from
       turn 9, quoted verbatim. Diff: <preview>

    ### Factory additions (1)
    5. `2-mind/factory/runtime-research-2026-05-16.md` — research
       findings collated. Diff: <preview>

    Ratify (y/n/modify) per item:

The user accepts, rejects, or modifies each. The skill **does not
autonomously apply** changes to `2-mind/atelier/`,
`4-control/principle/`, or `4-control/rule/` without explicit
ratification. Other layers (factory, skill, script) may apply with
softer confirmation, depending on user preference.

### 5. Apply ratified changes

For each accepted item:

- Edit the file (or create it). Honor the *one canonical home* rule —
  if a similar entry exists, append/merge rather than create duplicate.
- Resolve contradictions: prefer the more recent / corrected
  information; remove or annotate the older.
- Stay within structural limits (e.g.,
  `4-control/principle/principle.md` ≤ ~200 lines suggested,
  individual atelier stance file ≤ ~100 lines).
- **Consolidate-before-append** (Hermes pattern): if a target file is
  approaching its structural limit (≥ 80% of suggested size), perform
  a consolidation pass — merge near-duplicate entries, shorten
  verbose-but-repetitive material — *before* adding the new entry.
  Avoid letting files grow unbounded.
- For skills, follow the **standard SKILL.md section structure**
  (Hermes convention): `When to Use` / `Quick Reference` (one-screen
  command/API table) / `Procedure` (numbered steps) / `Pitfalls` /
  `Verification` (how the agent knows it's done). YAML frontmatter
  includes `name`, `description`, and optionally
  `requires_tools` / `fallback_for_tools` (Hermes compatibility
  metadata so the skill is hidden when prerequisites are absent and
  surfaces as a fallback when primary tools are missing).
- For scripts, ensure they are *self-contained*: shebang +
  `set -euo pipefail` + brief help text in header.

### 6. Append to session log

Append a structured entry to `2-mind/factory/session-log.md`. Create
the file if absent (it's a typical factory page — synthesized
operational bookkeeping).

    ## YYYY-MM-DD HH:MM — session retrospective

    **What this session did**: <2–3 line summary>

    **Durable assets added**:
    - `act/skill/refactor-toml/SKILL.md` (skill)
    - `4-control/rule/no-destructive-commands-without-confirm.md` (rule)
    - `2-mind/atelier/workspace-voice.md` (Owner stance, verbatim)

    **Rejected / deferred** (with reason):
    - `act/skill/check-runtime-attach/` — too thin, parked

    **Cross-session signals to watch**:
    - <patterns that recurred but didn't yet qualify for codification>

### 7. (Optional) Surface skill candidates for future graduation

Items that *almost* qualify as skills but lacked the second
occurrence — surface them as graduation candidates in
`1-active/skill-candidates/<name>/`. They wait for the next session
that exercises the same pattern, at which point session-retro can
ratify and promote them to `3-playbook/act/skill/`.

## Safety / scope constraints

- **In scope**: durable content layers (`2-mind/`, `3-playbook/`,
  `4-control/`), `1-active/skill-candidates/`, and non-runtime-specific
  root files (`AGENTS.md`, `README.md`, `.gitignore`).
- **Out of scope** (separability + governance): runtime-native configs
  (`.claude/`, `.codex/`, `.gemini/`, root `.mcp.json`), forwarder
  symlinks (`CLAUDE.md`, `GEMINI.md`), `WORKSPACE.md` (follows
  `contribution.md`), `LICENSE` (legal).
- **Never auto-commit**, **never delete** (append/modify only),
  **quote-verbatim** for atelier Owner content.

## Done criteria

- Session signals catalogued and categorized across the 5 layers
- User has ratified each proposed durable change
- Ratified changes applied (`git status` shows the additions)
- `2-mind/factory/session-log.md` appended with summary + decisions
- Skill candidates parked in `1-active/skill-candidates/` for next
  session's potential graduation

## Companion skill — `workspace-audit`

`session-retro` (this skill) handles **accumulation** — adding new
durable artifacts from session experience. Over time the workspace
accumulates content that needs **maintenance** (pruning, consolidating,
resolving contradictions, removing orphans).

Maintenance is a separate skill: `workspace-audit`. Run it
periodically (monthly / quarterly) or after bulk additions. The two
skills are complementary — accumulation grows the workspace,
maintenance keeps it sharp.

## References

- Auto Dream (Anthropic) — <https://claudefa.st/blog/guide/mechanics/auto-dream>
- Hermes Agent (Nous Research) — <https://hermes-agent.nousresearch.com/docs/> + memory architecture <https://vectorize.io/articles/hermes-agent-memory-explained> + skill triggers <https://hermes-agent.nousresearch.com/docs/developer-guide/creating-skills>
- `retrospective` — <https://lobehub.com/skills/az9713-claude-code-continual-learning-skills-retrospective>
- `summarize-session` — <https://awesomeskill.ai/skill/ettsted2-summarize-session>
- `hookify` — <https://www.claudepluginhub.com/commands/ericgrill-hookify-plugins-anthropic-hookify/commands/hookify>
- `claude-md-improver` — <https://github.com/anthropics/claude-plugins-official/blob/main/plugins/claude-md-management/skills/claude-md-improver/SKILL.md>
- Reflexion (verbal self-critique) — <https://arxiv.org/abs/2303.11366>
