# Runtime flexibility

How workspace.md adapts to different runtimes so R2 Part B (session-
start load fits runtime budget) is enforced. Sibling to
`use-driven-memory.md` — separates runtime concerns from cognitive
architecture.

## Two-axis runtime framing

"Runtime" is a pair: **(harness, backend)**.

- **Harness** = the agent CLI / UI wrapping the agent loop (Claude
  Code, Codex CLI, Gemini CLI, Cursor, Hermes Agent, OpenCode,
  Continue.dev, custom scripts, …).
- **Backend** = the LLM that generates tokens (hosted: Anthropic /
  OpenAI / Google APIs; local: Ollama, LM Studio, MLX/omlx,
  llama.cpp, vLLM).

The two are independent: a hosted CLI can point at a local backend
via OpenAI-compat proxy (e.g., Claude Code → LiteLLM → Ollama).
Tier depends on **backend `effective_context`**; harness determines
which enforcement mechanisms (hooks, MCP) are available.

## Three patterns

How runtime pairings combine in practice:

- **Pattern A — hosted CLI + hosted backend** (Claude Code direct,
  Codex CLI direct, Gemini CLI direct). Tier inferable from known
  constants.
- **Pattern B — hosted CLI + local backend via OpenAI-compat**
  (Claude Code → LiteLLM → Ollama). Tier driven by local backend's
  effective context; query `/v1/models` of the local endpoint.
- **Pattern C — hook-less harness with native capability detection**
  (Hermes Agent, OpenCode, Continue.dev). Same detection mechanism;
  harness lacks hook surface but `detect-runtime` still works.

## Tier system

Three tiers — `lean`, `standard`, `extended` — override R1 natural
caps when the runtime constrains or expands the session-start
budget. **`standard` is the R1 baseline**; `lean` reduces caps for
constrained runtimes; `extended` raises them for hosted-large
runtimes.

| Tier | USER (hard / consol) | NEXT | journal/<entry> | garden/<topic> flag | Target runtime |
|---|---|---|---|---|---|
| **lean** | 60 / 50 | 20 | 100 soft | 200 | local 7-13B (Llama 3.1 8B, Qwen 2.5 7B, Mistral 7B); ≤16K effective |
| **standard** | 100 / 80 | 30 | 200 soft | 300 | **R1 baseline** — local 30-70B, hosted-modest (Haiku, GPT-4o-mini) |
| **extended** | 200 / 160 | 50 | 400 soft | 500 | hosted-large (Claude Sonnet/Opus, GPT-4, Gemini Pro) |

Session-start budgets: **lean ≈ 15K · standard ≈ 19K · extended ≈ 29K tokens**.

This is the **canonical home** for the cap numbers. `profile.md`
may carry a summary, but the source of truth is here.

## Tier-derivation rule

`detect-runtime` skill produces the inputs; this rule maps them to
a tier:

| effective_context | Model class | Tier |
|---|---|---|
| ≤ 16K | any | `lean` |
| 16K - 64K | any | `standard` |
| > 64K | hosted-large (Sonnet/Opus, GPT-4, Gemini Pro) | `extended` |
| > 64K | hosted-modest (Haiku, GPT-4o-mini, Gemini Flash) | `standard` (attention-quality cap) |
| uncertain / detection failed | — | `standard` (R1 baseline) |

## Mixed-runtime rule

If multiple runtimes share a workspace (e.g., Claude Code AND local
Ollama used in different sessions), pick the **most constrained**
active tier. Writes from constrained sessions are always readable by
extended sessions; the reverse silently overflows.

## Active selection

Stored at `3-control/runtime/profile.md` — T2 (Owner-ratified) at
`init` time, re-ratify on runtime change detected by
`session-start`. `dream` and `audit` read profile.md for active
caps. Default if `profile.md` absent: `standard` (R1 baseline
applies as-is).

profile.md is the per-workspace state file; this doc is the
universal spec. profile.md fields are defined here; profile.md's
`active_tier` must be one of the tiers defined here.

## Detection mechanism

Runtime detection is owned by the `detect-runtime` skill
(`2-mind/forge/act/skill/detect-runtime/SKILL.md`). It runs three
sub-steps:

1. **Harness** — agent self-introspection + env-var / folder
   verification
2. **Backend** (provider + endpoint + model) — agent
   self-identification + per-harness config + `/v1/models` probe
3. **Effective context** — agent self-knowledge + hosted constants
   table OR local endpoint query

Invoked in three modes: by `init` (bootstrap), by `session-start`
(drift check, every session), and rarely by `audit` (freshness
re-check of the known-constants table when `last_verified` is
>6 months old). Owner can also invoke `/detect-runtime` directly
after switching backends. Optional helper script at
`2-mind/forge/act/script/detect-runtime.sh` automates the procedure
for shell-capable harnesses.

## Graceful degradation

Real-functioning guarantees when detection is partial or impossible:

- **Detection sub-step returns uncertain** → record
  `(uncertain — <reason>)` in profile.md `notes` and proceed with
  `standard` tier.
- **Agents without shell/network access** (some constrained
  harnesses) → skip endpoint queries; rely on agent self-
  introspection + Owner declaration only.
- **Headless / non-interactive runs** (cron, CI) → can't ratify
  mid-job; assume `standard` and flag for next interactive session.
- **Signal disagreement** (e.g., agent self-says "Claude Sonnet 4.6"
  but `/v1/models` returns "qwen2.5-coder:32b") → surface to Owner;
  never silently pick.

## Freshness discipline

The known-constants table inside `detect-runtime/SKILL.md` carries
`last_verified: YYYY-MM-DD` per row. `audit`'s stale-scan flags
entries older than 6 months for Owner re-verification (matches the
existing freshness pattern). New model classes (Claude 5, Gemini
Ultra, GPT-5, etc.) are added by Owner edit — not auto-discovered.

## Enum policy

`harness` and `backend_provider` in profile.md are **open enums** —
listed values are common cases; `custom` is the always-valid
catch-all. Adding a new harness or provider does not break existing
profiles. The tier-derivation rule above operates on
`effective_context` (numeric), so unknown harness/provider values
still flow through correctly.
