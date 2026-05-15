# workspace.md

> A workspace-topology specification — sibling to agents.md.

## What this is

A directory-topology convention for workspaces shared between human
users and AI agents. Sits alongside `AGENTS.md` (which describes agent
behavior); this file describes the *workspace they operate within*.

Drop-in compatible with any LLM runtime (Claude Code, Gemini CLI,
Codex, local LLMs like Ollama / LM Studio).

One approach, not *the* approach.

## Layout

Five top-level folders. Layers 0–3 form a content lifecycle; layer 4 is
the orthogonal control axis (how the workspace itself is configured and
governed).

    0-storage/    raw assets / inputs
    1-active/     main work area
    2-mind/       curated knowledge
      atelier/    user-authored, agent-assisted
      factory/    agent-authored, user-audited
    3-playbook/   automation
      role/       agent specs (who acts)
      cue/        triggers (when / where) — hooks, schedules, CI workflows
      act/skill/  natural-language procedures (agent reads + follows)
      act/script/ executable code (deterministic; no agent judgment)
    4-control/    workspace configuration & governance
                  (reading order: principle → runtime → external → rule)
      principle/  workspace operating principles / philosophy
      runtime/    per-runtime configs (Claude Code, Gemini CLI, Codex,
                  local LLMs), canonical + symlinked
      external/   external connections (MCP servers, OpenAPI specs, webhooks)
      rule/       enforceable workspace rules + document conventions
      .env        environment variables (optional; secrets stay outside)

## Rules and principles

Three rule homes by scope:

- **Workspace-wide rules** → `4-control/rule/<X>.md`
- **Foundational agent governance** → root `AGENTS.md` (AAIF convention)
- **Agent-local rules** → `3-playbook/role/<agent>/AGENTS.md` or
  `3-playbook/role/<agent>/rules/`

Workspace operating principles (orientation, philosophy) live separately
in `4-control/principle/` — these shape *how* the workspace is operated,
distinct from rules that constrain *what* may be done.

(Convention proposed by this spec; not borrowed from an established
standard.)

## Conventions

Vocabulary: *user* (the human), *agent* (the AI), *workspace* (the
5-folder tree rooted at the repo).

Filename: `{YYYY-MM-DD}_{slug}.md` recommended.

Detailed writing/naming conventions live in `4-control/rule/`.

## See also

- `AGENTS.md` — agent-behavior spec (sibling to this file).

---

*Version: v0.1 — 2026-05-15*
