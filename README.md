# workspace.md

> A workspace-topology specification — sibling to [agents.md](https://agents.md).
>
> **Status**: v0.2.0 pre-stable, starter-template form. Primarily used
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
(Claude Code, Codex CLI, Antigravity CLI [`agy`], Cursor…) and local
backends (Ollama, LM Studio, MLX, llama.cpp, vLLM…). Lists are
illustrative, not exhaustive.

## What's here

- **`WORKSPACE.md`** — the topology specification (start here for
  *what* the spec is)
- **`AGENTS.md`** — the operational card every harness loads first:
  hot read order + rules in one line
- **`3-control/foundation/`** — operating principles, identity,
  memory architecture (R1–R5), runtime tiers, adoption
- **`2-mind/forge/act/skill/`** — 6 lifecycle skills (init,
  session-start, session-end, dream, audit, detect-runtime) in the
  Agent Skills open format; exposed at `.claude/skills` and
  `.agents/skills`
- **`2-mind/forge/cue/lifecycle.md`** — canonical hook spec, rendered
  to each harness's hook format
- **`3-control/rule/trust.md`** — baseline trust tiers (what is data,
  what executes, what is T2)
- **`3-control/runtime/`** — adapter notes per harness
  (`claude-code.md`, `codex-cli.md`, `antigravity-cli.md`) +
  `profile.example.md`

## Why

Most agent-workspace formats target one CLI. **workspace.md** is
runtime-agnostic by construction:

- Four mandated top folders (`0-storage/`, `1-active/`, `2-mind/`,
  `3-control/`) — runtime-independent.
- Memory architecture — 7 stores, 5 operating rules (R1–R5), 6
  lifecycle skills — drawing metaphorical inspiration from cognitive
  science (Schacter-Tulving, Conway, Baddeley, McGaugh, Miller,
  Ebbinghaus, Loftus, Johnson) and informed by 2026 agent-memory
  results (small consolidated stores win; sleep-style consolidation).
- Progressive disclosure — a ≈6K-token hot load at session start;
  everything else on demand. Context windows are 1M now; attention
  is not.
- Runtime-tier system (lean / standard / extended) keyed to **model
  class**, not raw context size.
- Concurrency-aware — worktrees, subagents, headless runs: journal
  ids, append-only `NEXT.md`, memory on the integration branch, PR
  merge as ratification.

The spec is markdown plus two optional helper scripts. The agent
runs it; no daemon, no gateway, no binary service.

## Quick adoption

```bash
git clone <this-repo> my-workspace
cd my-workspace
```

Then, in your agent (Claude Code / Codex CLI / Antigravity CLI / Cursor
/ Hermes / ...):

1. It reads `AGENTS.md` natively (fallback: a one-line `CLAUDE.md`
   containing `@AGENTS.md`).
2. Invoke the `init` skill — the agent follows
   `2-mind/forge/act/skill/init/SKILL.md` (verify structure → run
   `detect-runtime` → propose `profile.md` for ratify → expose native
   aliases).
3. Customize `3-control/foundation/SOUL.md` to your workspace's
   identity (replace section content, keep structure).
4. Start your first session — `session-start` loads the hot read
   order; `session-end` writes a journal entry on close.

After a few sessions, `dream` distills journal entries (and your
harness's own auto memory, as an inbox) into
`2-mind/garden/essential/USER.md` and working `SOUL.md`. `audit`
periodically prunes, archives, and logs store sizes.

## Reading order for new readers

1. **This README** — orientation
2. **`WORKSPACE.md`** — topology, conventions, known limits
3. **`3-control/foundation/PRINCIPLE.md`** — 7 core design values
4. **`3-control/foundation/use-driven-memory.md`** — stores, tiers,
   R1–R5, skills
5. **`3-control/foundation/runtime-flexibility.md`** — model classes
   and tiers
6. **Skills**: `2-mind/forge/act/skill/<name>/SKILL.md`

## Status

**v0.2.0 pre-stable** — breaking changes possible. v0.2.0 is a
breaking release: single `AGENTS.md` entry (symlinks removed), 5-item
hot read order, model-class tiers, Gemini CLI retired, R5 concurrency,
harness-memory inbox, trust tiers. Cap numbers remain *defensibly
grounded but not empirically validated*; `audit` now logs the data to
fix that.

## Relationship to agents.md

`workspace.md` is a sibling to [agents.md](https://agents.md), not a
fork. **AAIF-aligned**: this repo's `AGENTS.md` follows AAIF
conventions and is read natively by current harnesses.

- `agents.md` answers: *how does this agent behave?*
- `workspace.md` answers: *how is the directory the agent works in
  organized?*

The two compose. A workspace can adopt both.

## Contributing

Currently maintained by one author; sole adopter so far. Feedback is
welcome via issues — especially adoption reports (which harness? which
backend? what broke?), empirical cap observations (`audit`'s metrics
lines are the format), new harnesses for `detect-runtime`, and doc
clarity. PRs may not be merged quickly while pre-stable — discuss
substantive proposals in an issue first.

## License

[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).
See `LICENSE`.

---

*Version: v0.2.0 (pre-stable). One approach among many.*
