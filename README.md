# workspace.md

> A workspace-topology specification — sibling to [agents.md](https://agents.md).

**workspace.md** describes how a directory shared between a human and
an AI agent should be organized so the agent can read, write, and
accumulate value with use. While `agents.md` describes how agents
behave, `workspace.md` describes the workspace they operate within.

Compatible with any LLM runtime — hosted CLIs (Claude Code, Codex CLI,
Gemini CLI, Cursor) and local backends (Ollama, LM Studio, MLX,
llama.cpp, vLLM). One spec, all harnesses, runtime-flexible.

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
- **`3-control/runtime/profile.md`** — per-workspace runtime profile
  template (filled at `init` time)

## Why

Most agent-workspace formats target one CLI. **workspace.md** is
runtime-agnostic by construction:

- Four mandated top folders (`0-storage/`, `1-active/`, `2-mind/`,
  `3-control/`) — Life-OS-lifecycle ordering, runtime-independent.
- Cognitive-architecture memory spec — 7 stores, 4 operating rules
  (R1–R4), 6 lifecycle skills — grounded in established memory
  theory (Schacter-Tulving, Conway, Baddeley, McGaugh, Miller,
  Ebbinghaus, Loftus, Johnson).
- Runtime-tier system (lean / standard / extended) — adapts caps to
  the binding constraint: backend `effective_context`. Local 7-13B
  model? Use `lean`. Hosted Sonnet/Opus? Use `extended`.

The spec is markdown-only. The agent runs it; no daemon, no
gateway, no binary.

## Quick adoption

```bash
git clone <this-repo> my-workspace
cd my-workspace

# In your agent CLI of choice (Claude Code, Codex CLI, Gemini CLI, ...):
# 1. Read AGENTS.md to load the 7-item read order
# 2. Run /init — verifies structure, invokes detect-runtime, proposes
#    a runtime profile for your ratification
# 3. Customize 3-control/foundation/SOUL.md to your workspace's identity
#    (the canonical SOUL.md ships with this spec-repo's own caretaker
#    identity — adopters replace it with their context)
# 4. Start your first session — session-start loads the 7-item read
#    order; session-end writes a journal entry on close
```

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

**v0.1 pre-stable** — breaking changes possible. The spec matures
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

This is a pre-stable spec. Feedback, issues, and pull requests are
welcome — especially:

- Adoption reports (which CLI? which backend? what broke?)
- Empirical cap-number observations (what worked, what didn't)
- New harnesses or backends to add to `detect-runtime` enums
- Doc clarity improvements

## License

[Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/).
See `LICENSE` for full terms.

---

*Version: v0.1 (pre-stable). One approach among many.*
