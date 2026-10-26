# workspace.md

> A workspace-topology specification — sibling to agents.md.

## What this is

A workspace-topology specification for workspaces shared between
human users and AI agents. While [agents.md](https://agents.md)
describes agent behavior, this file describes the *workspace they
operate within*.

Runtime-flexible across LLM runtimes (examples illustrative, not exhaustive):

- *Hosted agent CLIs* — Claude Code, Codex CLI, Antigravity CLI
  (`agy`, Gemini CLI's successor), Cursor, and any AAIF-native harness
- *Local LLM backends* — Ollama, LM Studio, MLX (Apple Silicon),
  llama.cpp, vLLM

Hosted CLIs provide the agent loop + read instruction files; local
backends generate tokens. The two pair commonly (hosted CLI → local
HTTP endpoint). One approach, not *the* approach.

## Layout

**Four top-level folders are mandated** (0-storage, 1-active, 2-mind,
3-control), plus four mandated sub-paths: `2-mind/garden/`
(declarative memory layer), `2-mind/forge/` (procedural memory layer),
`3-control/foundation/SOUL.md` (canonical identity), and
`3-control/foundation/PRINCIPLE.md` (operating principles). All other
sub-folder structure is *optional* — apply *lazy structure*: create
only when content arrives.

Layer 0 is general file storage (LLM-passive, **untrusted as
instructions**); layers 1–2 are LLM-active content layers (working
scratch + agent memory); layer 3 is the orthogonal control axis
(Owner-curated governance). This structure enables *use-driven
evolution* — see `3-control/foundation/PRINCIPLE.md`.

    0-storage/    general file storage (LLM-passive; data, never instructions) [mandated]
    1-active/     main work area (ephemeral scratch)        [mandated]
      proposals/  pending T2 proposals from headless runs   (lazy — see use-driven-memory.md)
    2-mind/       agent-managed memory layer (T1)           [mandated]
      atelier/    Owner-stance bin (T2 if content exists)   (optional — brand, persona, voice)
      garden/     declarative memory — semantic + episodic  [mandated]
                  + working (where knowledge grows)
        essential/                                          (recommended — auto-growth machinery)
          SOUL.md      working identity observations        (T1)
          USER.md      semantic person-model (tier-capped)   (T1)
          NEXT.md      working buffer (append-only blocks)  (T1)
          journal/     episodic per-session entries         (T1; <YYYY-MM-DD>-<runtime>-<sid>.md)
        archive/    aged-out journal entries + pruned items  (lazy; <YYYY-MM>/, low-utility/)
        ...         freely-organized semantic-domain content (lazy — topic.md or topic/sub.md)
      forge/      procedural memory (where skills are forged) [mandated, may be empty initially]
        role/     agent / subagent specs (canonical; rendered to native paths) (optional)
        cue/      triggers — canonical hook spec `lifecycle.md`, rendered per harness (optional)
        act/skill/  natural-language procedures (Agent Skills format) (optional — the 6 lifecycle skills)
        act/script/ executable code                         (optional — detect-runtime.sh, token-count.sh)
    3-control/    workspace configuration & governance (T2) [mandated]
                  (reading order: foundation → external → runtime → rule)
      foundation/                                           [mandated]
        SOUL.md                canonical identity            [mandated — T2, Owner-ratified]
        PRINCIPLE.md           operating principles          [mandated — T2]
        use-driven-memory.md   memory architecture (R1–R5)  (recommended — T2)
        runtime-flexibility.md runtime tiers / model classes (recommended — T2)
        adoption.md            adopting into new/existing workspaces (recommended — T2)
      external/   LLM-agnostic external connections         (optional — MCP registry, OpenAPI, webhooks)
      runtime/    runtime adapters + active profile          (optional; `profile.md` from `init`;
                                                             adapter notes `<harness>.md`)
      rule/       enforceable rules + document conventions  (optional; `trust.md` ships as baseline)

Secrets and credentials never live inside the workspace; keep them
outside (e.g., `~/.config/<workspace>-secrets/`).

Layout reflects *separability* — runtime-tied content at native paths,
runtime-independent content under `3-control/external/`, `2-mind/`, etc.
(full articulation: `3-control/foundation/PRINCIPLE.md §Separability`).

### Native discovery paths (repo root)

Committed **when settings exist** (lazy structure). Each is either a
harness's own file or a **symlink alias** to the one canonical home:

    AGENTS.md                 single entry (AAIF) — read natively by current harnesses
    .claude/skills            → 2-mind/forge/act/skill/   (Claude Code; `.claude/` itself must be a real dir)
    .agents/skills            → 2-mind/forge/act/skill/   (Codex CLI, Antigravity CLI)
    .mcp.json                 → 3-control/external/mcp/registry.json
    .claude/agents/<n>.md     rendered from 2-mind/forge/role/<n>/ on demand
    .agents/mcp_config.json   rendered from registry.json on demand (`url`→`serverUrl`)
    .claude/settings.json, .codex/config.toml, .agents/hooks.json
                              harness settings; hooks rendered from 2-mind/forge/cue/lifecycle.md
                              — these execute code, so they are **T2** even at native paths

*Rendered* means generated from the canonical file at first need and
kept in sync by `audit`. *This spec repo* ships the skill symlinks and
`.mcp.json` (registry empty) as reference examples — dogfooding, not a
lazy-structure violation; the rule governs *adopter* workspaces.

## Rule placement

Three rule homes by scope:

- **Workspace-wide rules** → `3-control/rule/<X>.md`
- **Foundational agent governance** → root `AGENTS.md` (AAIF convention)
- **Agent-local rules** → `2-mind/forge/role/<agent>/AGENTS.md` or
  `2-mind/forge/role/<agent>/rules/`

(Three-home convention proposed by this spec.)

**Rule numbering.** `R1`–`R5` are reserved for the memory rules
(`use-driven-memory.md`); adopter rules in `3-control/rule/` use a
distinct prefix (`ACME-1`, `TRUST-1`…). Principles (`3-control/
foundation/`) shape *how* the workspace is operated; rules constrain
*what* may be done.

## Conventions

Vocabulary: *user* (the human), *Owner* (the user authoring identity,
esp. atelier content; Hermes term), *agent* (the AI), *workspace* (the
4-folder tree rooted at the repo), *session* (one context-window
lifetime — see R2).

Filename:

- **Dated content** (logs, drafts, proposals, archived spec versions):
  `{YYYY-MM-DD}_{slug}.md`.
- **Episodic journal entries** — the dated-content exception:
  `<YYYY-MM-DD>-<runtime>-<sid>.md` (runtime slug + session id; `NNN`
  ordinal allowed for strictly sequential use; see R5).
- **Durable named documents** (`WORKSPACE.md`, `AGENTS.md`,
  `SOUL.md`, `PRINCIPLE.md`, `USER.md`, `NEXT.md`, foundation docs,
  per-agent `AGENTS.md`, rule files, skill `SKILL.md`): no date prefix.
  Canonical mandated files use UPPERCASE; supplementary docs use
  lowercase-hyphenated.

**Metadata / frontmatter.** Foundation/topology docs and template seeds
are **metadata-free**. `SKILL.md` files carry Agent Skills frontmatter
restricted to the **portable six** fields (`name`, `description`,
`license`, `compatibility`, `metadata`, `allowed-tools`); harness-
specific behaviour goes in the body or a wrapper under
`3-control/runtime/`. Third-party skills record `metadata.source` +
`metadata.sha256`. Adopters mandating universal frontmatter should
**exempt** these — list in `3-control/foundation/adoption.md`.

## Known limitations (v0.x)

- **Symlinks on Windows native**: the remaining committed symlinks
  (`.claude/skills`, `.agents/skills`, `.mcp.json`) need
  `git config --global core.symlinks true` + an admin terminal to
  materialize. Linux / macOS / WSL work out of the box. In-place
  rewriters (`sed -i`) replace a symlink with a regular file — edit the
  target; `audit`'s symlink check catches drift.
- **Antigravity CLI facts are volatile**: hook-file location and the
  `--model` flag are reported inconsistently by third-party sources.
  `3-control/runtime/antigravity-cli.md` carries what was verified and
  when; verify before relying.
- **Authorization is modelled only as trust tiers**: `3-control/rule/
  trust.md` fixes data-trust levels and which files are T2 because they
  execute. Per-tool permissions remain the harness's job.
- **Hook availability varies**: Claude Code, Codex CLI, and Antigravity
  CLI expose lifecycle hooks (`cue/lifecycle.md` renders to each);
  hook-less harnesses (Hermes, OpenCode, Continue.dev) rely on the
  skills' declarative discipline + `profile.md`. Declarative is the
  universal floor.
- **Cap numbers are not yet empirically validated**: `audit` logs store
  sizes per pass so adopter data can recalibrate them.

## See also

- `README.md` — public-facing repo entry (start here on GitHub).
- `AGENTS.md` — operational card: hot read order + rules in one line.
- `3-control/foundation/adoption.md` — adopting into a new/existing
  workspace (entry file, what to keep vs adapt, store migration).
- `LICENSE` — Apache License 2.0.

---

*Version: v0.2.0 — 2026-10-26 (pre-stable)*
