# Operating principles

Principles that guide how this workspace operates. Distinct from rules
(`../rule/`) that constrain specific actions: principles shape
judgment, rules constrain action.

Two sections — operational principles for any workspace.md adopter,
and spec-evolution principles for proposing changes to WORKSPACE.md.

---

## Operational principles

### Per-layer operation

**0-storage/** — Raw inputs only. Never edit in place. Long-term
retention; never delete casually. Source-of-truth for anything that
originated elsewhere (received documents, original media, archived
snapshots).

**1-active/** — Disposable working space. High churn, no preservation
guarantee. Drafts, scratch, in-progress work, candidate skills before
ratification. If something matters to keep, graduate it to `2-mind/`.

**2-mind/atelier/** — User-authored, agent-assisted. User's declared
stance preserved verbatim — agents may scribe, organize, cross-link,
but must not paraphrase the user's words. Brand identity, persona
definitions, principles, curated reference.

**2-mind/factory/** — Agent-authored, user-audited. Synthesized
observations, operational bookkeeping, logs, help, research synthesis.
Updated regularly without asking; audited periodically by the user.

**3-playbook/role/** — Per-agent specs. Each agent uses single-file
form (`role/<agent>.md`) or expanded subfolder form
(`role/<agent>/{AGENTS.md, rules/, ...}`) when state is non-trivial.
The tool whitelist in the agent's `AGENTS.md` is the only mechanism
for tool restriction.

**3-playbook/cue/** — Event-driven triggers (hooks, schedules, CI
workflows). Hook implementations are runtime-specific (Claude Code
hooks ≠ Gemini hooks); not portable across runtimes without rewrite.

**3-playbook/act/skill/** — Natural-language procedures. One folder
per skill containing `SKILL.md`. Agent reads and follows with judgment
along the way.

**3-playbook/act/script/** — Deterministic executable code (bash,
python, etc.). No agent judgment at runtime. Idempotent and testable
where possible.

### Runtime attachment (`4-control/runtime/`)

Each runtime gets its own subfolder. Canonical config files live in the
subfolder; symlinks bind them to the runtime's expected location:

    runtime/claude/settings.json → ~/.claude/settings.json
    runtime/gemini/config.json   → ~/.gemini/settings.json
    runtime/codex/config.toml    → ~/.codex/config.toml
    runtime/ollama/Modelfile     → (local model definition)

Editing the canonical file updates every runtime's view. Per-runtime
drift is prevented by construction. Secrets stay outside the workspace
(e.g., `~/.config/<workspace>-secrets/`).

### External connections (`4-control/external/`)

MCP servers, OpenAPI specs, webhook configs.

- **Self-owned MCP server**: source code + connection config travel
  together in `external/mcp/<server-name>/`. Tests and language tooling
  stay scoped to that folder.
- **3rd-party MCP server**: registration + connection metadata only in
  `external/mcp/registry.<format>`. No source code (lives in its own
  repo).
- **OpenAPI / REST**: spec files in `external/openapi/<service>.yaml`.
  Referenced from `act/skill/` or `act/script/` at call time.
- **Webhooks**: subscription config in `external/webhook/<source>.yaml`.
  Receiving handler lives in `act/script/`.

### Rule placement

Each rule has exactly one canonical home (see WORKSPACE.md §Rules and
principles). Cross-domain references link directly to that path.
Content that bridges constraint + methodology splits across two pages
rather than duplicating.

---

## Spec-evolution principles

Apply when proposing changes to WORKSPACE.md itself.

- **Minimalism over maximalism.** Add only when forced by practice.
  Three similar needs trigger consideration; only the third is allowed
  to introduce structure.
- **AAIF-aligned, not competing.** workspace.md is a sibling to
  agents.md, organized in the same format.
- **One approach, not THE approach.** Present as one perspective on
  workspace topology. Avoid normative universal claims.
- **Honest about novelty.** Where the spec proposes conventions, mark
  them explicitly ("proposed by this spec; not borrowed from an
  established standard").
- **Top-level numeric prefix carries meaning.** Changes to top-level
  layout must preserve or replace the 0–3 lifecycle + 4 control axis
  coherently.
- **Bias toward fewer folders.** Subfolders are lazy — created on
  second occurrence of a content kind, not preemptively.
