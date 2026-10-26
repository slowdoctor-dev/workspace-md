# Runtime flexibility

How workspace.md adapts to different runtimes so R2 Part B (session-
start load fits the attention budget) is enforced. Sibling to
`use-driven-memory.md` — separates runtime concerns from cognitive
architecture.

## Two-axis runtime framing

"Runtime" is a pair: **(harness, backend)**.

- **Harness** = the agent CLI / UI wrapping the agent loop (Claude
  Code, Codex CLI, Antigravity CLI, Cursor, Hermes Agent, OpenCode,
  Continue.dev, custom scripts, …).
- **Backend** = the LLM that generates tokens (hosted: Anthropic /
  OpenAI / Google APIs; local: Ollama, LM Studio, MLX/omlx,
  llama.cpp, vLLM).

The two are independent: a hosted CLI can point at a local backend
via an OpenAI-compat proxy (e.g., Claude Code → LiteLLM → Ollama).
Tier depends on the backend's **model class**; harness determines
which enforcement mechanisms (hooks, MCP, subagents) are available.

## Three patterns

- **Pattern A — hosted CLI + hosted backend** (Claude Code direct,
  Codex CLI direct, Antigravity CLI direct). Model class is known from
  the model id.
- **Pattern B — hosted CLI + local backend via OpenAI-compat**
  (Claude Code → LiteLLM → Ollama). Model class from the local model's
  parameter count; query `/v1/models` of the local endpoint.
- **Pattern C — hook-less harness** (Hermes Agent, OpenCode,
  Continue.dev). Same detection; declarative enforcement only.

## Why model class, not context size (v0.2)

Through v0.1 the tier was derived from `effective_context`. By late
2026 that axis stopped discriminating: hosted models of every size
ship ≥1M-token windows and local models ship 128K+. The binding
constraint moved to **attention quality** (context rot: output quality
degrades well before the advertised window), **cost**, and **prompt-
cache stability**. Model class is a proxy for the first; R2 Part B's
hot-load budget caps the other two. `effective_context` remains a
sanity check for misconfigured local runtimes (Ollama's default
window can be 2–4K regardless of the model card).

## Tier system

Three tiers — `lean`, `standard`, `extended` — override R1 natural
caps. **`standard` is the R1 baseline**; `lean` reduces caps for
constrained runtimes; `extended` raises them for frontier runtimes.

Caps are in **tokens** (primary unit since v0.1.1); line counts are a
secondary English-density advisory (≈100/30/200/300 lines at
`standard`). See `use-driven-memory.md §R1` for why token-primary.

| Tier | USER (hard / consol) | NEXT | journal/<entry> | garden/<topic> flag | Target model class |
|---|---|---|---|---|---|
| **lean** | 500 / 400 | 170 | 1200 soft | 2000 | `local-small` (≤13B) |
| **standard** | 800 / 640 | 240 | 2000 soft | 3200 | **R1 baseline** — `local-large` (30B+), `hosted-small` |
| **extended** | 1600 / 1280 | 400 | 4000 soft | 6400 | `hosted-frontier` |

(All values are tokens. Measure with `2-mind/forge/act/script/token-count.sh`.)

**Hot-load budget** (R2 Part B — the 5-item session-start load):
**lean ≈ 4K · standard ≈ 6K · extended ≈ 9K tokens**. Reference docs
(`WORKSPACE.md`, `PRINCIPLE.md`, this file, `use-driven-memory.md`)
are read on demand and do not count against it.

This is the **canonical home** for the cap numbers. `profile.md` and
the skills may carry a summary table; those legitimately differ in
column shape, so the discipline is that the **numeric cap values must
match** this table (not byte-for-byte layout). The source of truth is
here.

## Model classes (open enum)

| `model_class` | Meaning | Examples (illustrative, Oct 2026) |
|---|---|---|
| `hosted-frontier` | vendor's top tier; full attention over long contexts | Claude Opus / Fable, GPT-5.x (non-mini), Gemini 3.x Pro |
| `hosted-small` | vendor's fast/cheap tier | Claude Haiku, GPT-5.x mini/nano, Gemini Flash |
| `local-large` | ≥30B parameters (dense or active MoE) | Qwen3 32B+, Llama 4 Maverick, DeepSeek-V3 class |
| `local-small` | ≤13B parameters | Llama 3.x 8B, Qwen3 8B, Gemma 3 12B, Mistral 7B |
| `uncertain` | detection failed or conflicting | — |

Hosted mid-tier models (Claude Sonnet, Gemini Pro non-3.x, etc.) are
`hosted-frontier` for tier purposes. Mid-size local models (14–27B)
are `local-large` if quantization is ≥Q5, else `local-small` — Owner
judgment; record it in `profile.md notes`.

## Tier-derivation rule

`detect-runtime` produces the inputs; this rule maps them to a tier:

| `model_class` | Tier |
|---|---|
| `hosted-frontier` | `extended` |
| `hosted-small` | `standard` |
| `local-large` | `standard` |
| `local-small` | `lean` |
| `uncertain` | `standard` (R1 baseline) |

**Override**: if `effective_context` is known and ≤16K tokens (a
misconfigured local window), the tier is `lean` whatever the class,
and `detect-runtime` flags the misconfiguration.

## Mixed-runtime rule

If multiple runtimes share a workspace (e.g., Claude Code AND local
Ollama used in different sessions), pick the **most constrained**
active tier. Writes from constrained sessions are always readable by
extended sessions; the reverse silently overflows.

## Active selection

Stored at `3-control/runtime/profile.md` — T2 (Owner-ratified),
created by `init` from the shipped `profile.example.md` template, and
re-ratified on runtime change detected by `session-start`. `dream` and
`audit` read profile.md for active caps. A fresh clone ships no
`profile.md`; default if absent: `standard` (R1 baseline applies
as-is).

profile.md is the per-workspace state file; this doc is the
universal spec. profile.md fields are defined here; its
`active_tier` must be one of the tiers above and its `model_class`
one of the classes above (or a documented custom value).

## Detection mechanism

Owned by the `detect-runtime` skill
(`2-mind/forge/act/skill/detect-runtime/SKILL.md`). Three sub-steps:

1. **Harness** — agent self-introspection + env-var / folder check
2. **Backend** (provider + endpoint + model) — agent
   self-identification + per-harness config + `/v1/models` probe
3. **Model class** — from the model id (hosted) or parameter count
   (local); `effective_context` recorded when cheaply available
   (Models API `max_input_tokens`, `/v1/models` `context_length`)

Invoked by `init` (bootstrap), by `session-start` (drift check), or
explicitly (`/detect-runtime`) after switching backends. The spec
carries **no vendor constants table** (removed in v0.2): the agent
knows its own model, and the class enum is coarse enough to survive
model releases without edits.

## Graceful degradation

- **Detection sub-step uncertain** → record `(uncertain — <reason>)`
  in profile.md `notes`; proceed with `standard`.
- **No shell / network** → skip endpoint queries; self-introspection
  + Owner declaration only.
- **Headless / non-interactive runs** (cron, CI, cloud) → can't
  ratify mid-job; assume `standard` and queue the proposal
  (`use-driven-memory.md §Ratification channels`).
- **Signal disagreement** (agent self-says "Claude Opus 5.5" but
  `/v1/models` returns `qwen3:32b`) → surface to Owner; never
  silently pick.
- **Hook-less harness** → R2 enforcement is declarative (skills +
  `profile.md`) rather than hook-driven; the universal floor.

## Enum policy

`harness`, `backend_provider`, and `model_class` in profile.md are
**open enums** — listed values are common cases; `custom` /
`uncertain` are always valid. Adding a new harness or provider does
not break existing profiles. The tier-derivation rule operates on
`model_class`, so unknown harness/provider values still flow through.
