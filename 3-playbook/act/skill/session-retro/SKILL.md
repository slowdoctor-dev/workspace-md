---
name: session-retro
description: Reflect on the just-completed working session and propose durable updates to 2-mind/, 3-playbook/, and 4-control/. Extracts successes (→ skills), failures (→ hooks/rules), declared preferences (→ atelier), observations (→ factory), and orientation refinements (→ principle). The user ratifies each proposed change before it is applied. Use after session-end, or invoke mid-session for partial consolidation.
---

# Session retrospective — *use-driven evolution*

## When to use

Run after `session-end` to convert session experience into durable
workspace assets. Also useful mid-session when significant work has
accumulated and the user wants to consolidate before continuing.

This skill is the operational instance of workspace.md's Core design
value of **use-driven evolution** (see
`4-control/principle/principle.md`): each session should leave behind
*more* `2-mind/` knowledge and `3-playbook/` automation than it
started with.

Related exemplars: Anthropic's *Auto Dream* (background memory
consolidation), `retrospective` skill on LobeHub (per-skill learnings
logs), `summarize-session` on Awesome Skills (CLAUDE.md compaction),
`hookify` plugin (problematic behavior → hooks).

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
| Workspace orientation / philosophy refinement | `4-control/principle/principle.md` Core design values |
| One-off note that doesn't fit anywhere | `2-mind/factory/session-log.md` only |

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
  `4-control/principle/principle.md` ≤ ~200 lines suggested).
- For skills and scripts, ensure they are *self-contained*: SKILL.md
  with frontmatter + clear steps, scripts with shebang + set -euo
  pipefail + help.

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

- **Write only** to: `2-mind/atelier/`, `2-mind/factory/`,
  `3-playbook/role/`, `3-playbook/cue/`, `3-playbook/act/`,
  `4-control/rule/`, `4-control/principle/`, `1-active/skill-candidates/`.
  *Do not* edit runtime-native configs (`.claude/`, `.codex/`,
  `.gemini/`, root `.mcp.json`) — those are runtime-specific concerns
  outside this skill's separability scope.
- **Never auto-commit**. Stage edits; let the user commit (consistent
  with `session-end`).
- **Never delete** — only add, append, or modify. Deletion requires
  explicit user instruction.
- **Quote-verbatim** for Owner content; don't paraphrase emic material.

## Done criteria

- Session signals catalogued and categorized across the 5 layers
- User has ratified each proposed durable change
- Ratified changes applied (`git status` shows the additions)
- `2-mind/factory/session-log.md` appended with summary + decisions
- Skill candidates parked in `1-active/skill-candidates/` for next
  session's potential graduation

## References

- Auto Dream (Anthropic Claude Code) —
  <https://claudefa.st/blog/guide/mechanics/auto-dream> +
  <https://www.mindstudio.ai/blog/what-is-claude-code-autodream-memory-consolidation/>
- `retrospective` skill (per-skill learnings.md / failures.md) —
  <https://lobehub.com/skills/az9713-claude-code-continual-learning-skills-retrospective>
- `summarize-session` (CLAUDE.md compaction) —
  <https://awesomeskill.ai/skill/ettsted2-summarize-session>
- `session-memory` v2.0 (save/recall/consolidate CLI) —
  <https://mcp.directory/skills/session-memory>
- `hookify` (problematic-behavior → hook) —
  <https://www.claudepluginhub.com/commands/ericgrill-hookify-plugins-anthropic-hookify/commands/hookify>
- `claude-md-improver` (audit/improve CLAUDE.md, Anthropic official) —
  <https://github.com/anthropics/claude-plugins-official/blob/main/plugins/claude-md-management/skills/claude-md-improver/SKILL.md>
- Reflexion (verbal self-critique in episodic memory) —
  <https://arxiv.org/abs/2303.11366>
