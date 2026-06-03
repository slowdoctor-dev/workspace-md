# workspace.md

> A workspace-topology specification — sibling to [agents.md](https://agents.md).
>
> **Status**: v0.1.1 pre-stable, starter-template form. Primarily used
> by the author (sole adopter); public for visibility and feedback.
>
> *Adopters*: this README describes the **spec project** — replace or
> delete it in your own workspace. See
> [`3-control/foundation/adoption.md`](3-control/foundation/adoption.md).

**workspace.md** describes how a directory shared between a human and
an AI agent should be organized so the agent can read, write, and
accumulate value with use. While `agents.md` describes how agents
behave, `workspace.md` describes the workspace they operate within.

Designed to be runtime-flexible across LLM runtimes — hosted CLIs
(Claude Code, Codex CLI, Gemini CLI / Antigravity CLI [`agy`], Cursor…)
and local backends (Ollama, LM Studio, MLX, llama.cpp, vLLM…). The
lists are illustrative, not exhaustive. (On the Gemini CLI → Antigravity
transition, see `3-control/runtime/antigravity-cli.md`.)

## What's here

- **`WORKSPACE.md`** — the topology specification (start here for
  understanding *what* the spec is)
- **`AGENTS.md`** — workspace-AAIF entry; the file an AI agent loads
  first when reading this repo as a workspace
- **`3-control/foundation/`** — operating principles, identity,
  memory architecture, runtime-flexibility (the spec proper)
- **`2-mind/forge/act/skill/`** — 6 lifecycle skills (init,
  session-start, session-end, dream, audit, detect-runtime) the
  agent uses to keep the workspace alive
- **`2-mind/garden/essential/`** — template seeds for adopter memory
  (USER, NEXT, SOUL working, journal/)
- **`3-control/runtime/profile.example.md`** — runtime-profile
  template; `init` copies it to `profile.md` (the active profile) and
  fills it. A fresh clone has no `profile.md` → tier defaults to
  `standard`.

## Why

Most agent-workspace formats target one CLI. **workspace.md** is
runtime-agnostic by construction:

- Four mandated top folders (`0-storage/`, `1-active/`, `2-mind/`,
  `3-control/`) — Life-OS-lifecycle ordering, runtime-independent.
- Memory architecture — 7 stores, 4 operating rules (R1–R4), 6
  lifecycle skills — drawing metaphorical inspiration from
  cognitive science (Schacter-Tulving, Conway, Baddeley, McGaugh,
  Miller, Ebbinghaus, Loftus, Johnson). The citations frame the
  design intent; they do not validate the cap numbers, which are
  defensibly grounded but not empirically tested.
- Runtime-tier system (lean / standard / extended) — adapts caps to
  the binding constraint: backend `effective_context`. Local 7-13B
  model? Use `lean`. Hosted Sonnet/Opus? Use `extended`.

The spec is mostly markdown, plus a couple of optional helper scripts
(`detect-runtime.sh`, `token-count.sh`). The agent runs it; no daemon,
no gateway, no binary service.

## Quick adoption

```bash
git clone <this-repo> my-workspace
cd my-workspace
```

Then, in your agent (Claude Code / Codex CLI / Gemini CLI / Cursor /
Hermes / ...):

1. Read `AGENTS.md` to load the 7-item read order.
2. Invoke the `init` skill — the agent follows the procedure in
   `2-mind/forge/act/skill/init/SKILL.md` (verify structure → invoke
   `detect-runtime` → propose `profile.md` for ratify). `init` is a
   markdown-described procedure, not a shell command; your agent
   reads the SKILL.md and executes the steps.
3. Customize `3-control/foundation/SOUL.md` to your workspace's
   identity. The canonical SOUL.md ships with this spec-repo's own
   caretaker identity — adopters replace the section content,
   preserving the section structure (per the Adopter note inside).
4. Start your first session — `session-start` loads the 7-item read
   order; `session-end` writes a journal entry on close.

After a few sessions, the `dream` skill (auto-invoked at
substantive-session close) distills journal entries into your
agent's persistent memory at `2-mind/garden/essential/USER.md` and
`SOUL.md` working. The `audit` skill periodically prunes and
archives.

## Reading order for new readers

If you're new to the spec, read in this order:

1. **This README** — orientation
2. **`WORKSPACE.md`** — full topology spec, conventions, known limits
3. **`3-control/foundation/PRINCIPLE.md`** — 6 core design values +
   per-layer operation
4. **`3-control/foundation/use-driven-memory.md`** — 7 stores +
   2 tiers + 4 rules + 6 skills (the cognitive memory architecture)
5. **`3-control/foundation/runtime-flexibility.md`** — how the spec
   adapts across harnesses + backends (R2 Part B mechanism)
6. **Skills**: `2-mind/forge/act/skill/<name>/SKILL.md` for each
   lifecycle skill

## Status

**v0.1.1 pre-stable** — breaking changes possible. The spec matures
with usage. Numbers (caps, thresholds) are *defensibly grounded but
not empirically validated*; first real adopter workloads will surface
where they need adjustment. See `WORKSPACE.md` §Known limitations
for acknowledged gaps.

## Relationship to agents.md

`workspace.md` is a sibling to [agents.md](https://agents.md), not a
fork. **AAIF-aligned**: this repo's `AGENTS.md` follows AAIF
conventions; `CLAUDE.md` and `GEMINI.md` symlink to it for the three
major hooked CLIs.

- `agents.md` answers: *how does this agent behave?*
- `workspace.md` answers: *how is the directory the agent works in
  organized?*

The two compose. A workspace can adopt both.

## Contributing

Currently maintained by one author; sole adopter so far. Feedback is
welcome via issues — especially:

- Adoption reports (which CLI? which backend? what broke?)
- Empirical cap-number observations (what worked, what didn't)
- New harnesses or backends to add to `detect-runtime` enums
- Doc clarity improvements

PRs may not be merged quickly while the spec is pre-stable —
substantive proposals are better discussed in an issue first.

## License

[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).
See `LICENSE` for full terms. Permissive (commercial use allowed,
no copyleft obligation on adopters' workspaces) with patent grant
and attribution requirement.

---

*Version: v0.1.1 (pre-stable). One approach among many.*
