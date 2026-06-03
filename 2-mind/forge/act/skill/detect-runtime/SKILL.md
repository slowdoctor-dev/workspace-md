---
name: detect-runtime
description: Detect (harness, backend, effective_context) for this workspace and derive the recommended R2 tier. Invoked by `init` (bootstrap), `session-start` (drift check), or explicit `/detect-runtime`. Owner ratifies results into active `3-control/runtime/profile.md` per T2 discipline.
---

# detect-runtime

## When to use

- **From `init`** — bootstrap; produce initial profile.md draft for Owner ratify from `profile.example.md`
- **From `session-start`** — cheap re-detect every session; compare against active profile.md when present; propose re-ratify on drift
- **Explicit `/detect-runtime`** — Owner invocation after switching harness or backend
- **From `audit`** (rare) — freshness re-check of `last_verified` constants

## Requires

Requires `3-control/foundation/SOUL.md`,
`3-control/foundation/PRINCIPLE.md`, and `2-mind/garden/essential/`
to exist. If any are missing, run `init` instead of continuing.

Operationalizes the detection mechanism described in
`3-control/foundation/runtime-flexibility.md §Detection mechanism`.

## Quick reference

Single principle: **the running agent IS the runtime instance** —
agent self-introspection is the primary signal; objective signals
(env vars, config files, endpoint queries) cross-check. Mismatch =
report to Owner; never silently resolve.

Harness is an open enum. Known values:
`claude-code`, `codex-cli`, `gemini-cli`, `antigravity`, `cursor`,
`hermes`, `opencode`, `continue`, `custom`.

| Sub-step | Primary signal | Verification | Fallback |
|---|---|---|---|
| 1. Harness | Agent self-introspection | Env var → repo config folder → user-level config | `custom` |
| 2. Backend (provider + endpoint + model) | Agent self-identification | Per-harness config read; if local-via-proxy, probe localhost ports for `/v1/models` | Ask Owner |
| 3. Effective context | Agent self-knowledge | Hosted: known-constants table (below); Local: `/v1/models` response + attention-cliff clamp | Owner declaration |

Optional helper: `2-mind/forge/act/script/detect-runtime.sh`
automates objective verification only: Sub-step 1B/C/D, Sub-step
2B/C, Sub-step 3C (local endpoint) only, then Step 4 tier derivation
and Step 5 JSON emission. Hosted Sub-step 3B is the agent's
cross-check against the SKILL known-constants table, not scripted. The
helper cannot perform Step 0 / Sub-step A agent self-introspection.
The running agent supplies that primary signal before interpreting the
helper output.

## Procedure

### Step 0 — Agent self-introspection (cannot be scripted)

Before running any helper, the agent records its own primary signal:
which harness loaded it, which model it is using, and what context
window it believes it has. This comes from the runtime's system
context, visible tools, loaded discovery file, and model
self-knowledge. Scripts cannot see this layer, so their output is
advisory verification, not the complete detection result.

### Sub-step 1 — Detect harness

**A. Agent self-introspection** (primary): the agent introspects
"What harness loaded me?" — answers come from its system prompt
content, discovery file path (`CLAUDE.md` → claude-code; `AGENTS.md`
direct → codex-cli; `GEMINI.md` → gemini-cli; `.agents/` aliases →
antigravity), env vars visible to it, and which tools / MCP servers
are registered.

**B. Env var verification** (objective):

| Env var present | Harness confirmed |
|---|---|
| `CLAUDE_PROJECT_DIR` | `claude-code` |
| `CODEX_PROJECT_DIR` | `codex-cli` |
| `GEMINI_PROJECT_DIR` | `gemini-cli` |
| `AGY_*` (various) | `antigravity` |
| `CURSOR_*` (various) | `cursor` |
| `HERMES_*` (varies) | `hermes` |

**C. Repo-level config presence** (medium reliability):

| Path exists | Harness wired here |
|---|---|
| `.claude/settings.json` | `claude-code` |
| `.codex/config.toml` | `codex-cli` |
| `.gemini/settings.json` | `gemini-cli` |
| `.agents/...` | `antigravity` |
| `.cursor/...` | `cursor` |
| `.config/opencode/opencode.json` | `opencode` |
| `.continue/config.yaml` | `continue` |

**D. User-level config** (lowest reliability):

| Path exists | Harness available |
|---|---|
| `agy --version` succeeds | `antigravity` |
| `~/.config/agy/credentials.json` | `antigravity` |
| `~/.gemini/antigravity-cli/` | `antigravity` |
| `~/.hermes/config.yaml` | `hermes` |
| `~/.continue/config.yaml` | `continue` |

**Resolution**: self-introspection result must match ≥1 objective
signal. Conflict → ask Owner. No signals at all → `custom`.

**Gemini / Antigravity collision warning**: if both Gemini CLI and
Antigravity signals are present, emit a warning in
`signal_disagreements`. Surface this to Owner and point to the
canonical adapter notes at `3-control/runtime/antigravity-cli.md`; do
not silently treat the two harnesses as equivalent.

### Sub-step 2 — Detect backend (provider + endpoint + model)

**A. Agent self-identification** (primary): "What model am I?" —
hosted-large models reliably know their identity. Local fine-tunes
may misidentify (a Llama variant may not know its quantization).

**B. Per-harness config read** (objective):

- **Hosted CLI** (Claude Code / Codex CLI / Gemini CLI):
  - If `OPENAI_BASE_URL` env var set → harness is routed through an
    OpenAI-compat proxy (could be local: `localhost:11434` Ollama or
    `localhost:1234` LM Studio; OR remote: LiteLLM gateway etc.).
    Query that URL's `/models` endpoint to discover backend.
  - Else → harness's native provider (Anthropic / OpenAI / Google)
  - Model id from harness settings file
- **Hermes**: read `~/.hermes/config.yaml` for `provider`,
  `base_url`, `model`
- **OpenCode**: read `.config/opencode/opencode.json`
- **Continue.dev**: read `.continue/config.yaml`

**C. Local-port probe** (custom or uncertain harness): first valid
`/v1/models` response wins:

```bash
curl -s http://localhost:11434/v1/models   # Ollama
curl -s http://localhost:1234/v1/models    # LM Studio
curl -s http://localhost:8080/v1/models    # llama.cpp default
curl -s http://localhost:8000/v1/models    # vLLM default
```

**Resolution**: self-identification verified against config-read or
endpoint result. Disagreement (e.g., self says "Claude Sonnet 4.6"
but `/v1/models` returns `qwen2.5-coder:32b`) → likely proxy
mismatch; surface to Owner.

If objective detection returns an unknown or empty model, do not infer
a tier from the absence. Detection is advisory; the ratified active
`3-control/runtime/profile.md` value remains authoritative for the
current session. If active profile.md is absent, fall back to
`standard` and flag uncertainty for Owner ratification.

### Sub-step 3 — Determine effective_context

**A. Agent self-knowledge** (primary): "What is my context window?"
— hosted-large models typically know their published max.
Cross-verify against the known-constants table.

**B. Known constants (hosted backends):**

last_verified: 2026-05-17

| Provider | Model class | Effective context | Caveat |
|---|---|---|---|
| Anthropic | Claude Sonnet/Opus 4.x | 200,000 (1,000,000 with beta header) | hosted-large — full attention across range |
| Anthropic | Claude Haiku | 200,000 | hosted-modest — quality lower past ~64K |
| OpenAI | GPT-4 family | 128,000 | hosted-large — full attention near full range |
| OpenAI | GPT-4o-mini | 128,000 | hosted-modest — lower past ~64K |
| Google | Gemini Pro | 1,000,000 | hosted-large — claimed full; community ~500K |
| Google | Gemini Flash | 1,000,000 | hosted-modest-equivalent — smaller model than Pro, attention quality lower past ~64K |

**C. Local endpoint query**:

```bash
# Ollama
curl -s http://localhost:11434/v1/models | jq '.data[].id'
curl -s http://localhost:11434/api/show -d '{"name":"<model>"}' | jq '.parameters'

# LM Studio / llama.cpp / vLLM
curl -s "${BACKEND_ENDPOINT}/v1/models" | jq '.data[] | {id, context_length, max_model_len}'
```

**Effective context formula** (local):

```
effective_context = min(
  theoretical_max,           # model card
  configured_context,        # runtime's actual config (Ollama defaults to 4K!)
  attention_quality_cliff    # 7-13B → ~16K, 30-70B → ~64K, 200B+ MoE → full
)
```

### Sub-step 4 — Derive tier

Apply the canonical tier-derivation rule from
`3-control/foundation/runtime-flexibility.md`:

| effective_context | Model class | Tier |
|---|---|---|
| ≤ 16K | any | `lean` |
| 16K - 64K | any | `standard` |
| > 64K | hosted-large (Sonnet/Opus, GPT-4, Gemini Pro) | `extended` |
| > 64K | hosted-modest (Haiku, GPT-4o-mini, Gemini Flash) | `standard` (attention cap) |
| uncertain / detection failed | — | `standard` (R1 baseline) |

In drift-check mode, profile.md is authoritative when detection is
uncertain. Use the detected tier only as a proposed change after
Owner re-ratification; do not silently replace the active tier.

### Sub-step 5 — Produce result

Emit a profile-draft proposal with 6 detected fields. The tier
field is emitted as `recommended_tier` (a proposal); on Owner ratify
it becomes `active_tier` in `3-control/runtime/profile.md`.

```
harness:             <detected>
backend_provider:    <detected>
backend_endpoint:    <detected>
backend_model:       <detected>
effective_context:   <detected>
recommended_tier:    <derived per rule>     # → active_tier on ratify
```

Plus any `signal_disagreements:` flagged for Owner attention.

**Bootstrap mode** (called from `init`): present result to Owner
for field-by-field T2 ratify; create active profile.md from
`3-control/runtime/profile.example.md` on accept.

**Drift-check mode** (called from `session-start`): compare result
against active profile.md when present. If `harness`, `backend_model`, or
`effective_context` differ → surface diff + propose re-ratify.
Default on drift = continue with profile.md's tier for this session;
do not silently change. Return value: `{matches: true|false, diff: …}`
plus the standard result fields.

**Freshness-check mode** (called from `audit`, rare): re-verify
the known-constants table (above, §3 B) against current vendor
documentation. If any constant has shifted (e.g., Claude Sonnet
context bumped, GPT-5 family released) → propose updates to Owner
with a new section-level `last_verified:` date. Do not auto-apply — the table is
T1 in `detect-runtime/SKILL.md` but its accuracy affects every
detection downstream; Owner-ratify the table update.

## Pitfalls

- **Trusting self-identification blindly**: local fine-tunes may
  misreport. Always cross-verify against objective signals.
- **Treating the helper as full detection**: the script cannot perform
  Step 0 / Sub-step A self-introspection. Combine helper output with
  the running agent's own runtime signal before deciding whether
  signals match.
- **Silently picking on signal disagreement**: surface to Owner.
  Disagreement IS the signal.
- **Guessing from an empty model**: unknown model/context means
  detection is uncertain. Use profile.md's active tier for the
  current session, or `standard` if no active profile exists.
- **Ignoring Gemini / Antigravity collisions**: emit the warning, point
  to `3-control/runtime/antigravity-cli.md`, then let Owner decide
  whether separate runtime config is needed.
- **Auto-bumping known-constants without re-verification**: model
  vendors change context windows (e.g., Claude beta header). Update
  the section-level `last_verified:` date when you change the table.
- **Skipping the attention-quality cliff for local**: model cards
  claim 128K but quality cliffs at 16K for 7-13B. Always clamp.
- **Running detect-runtime in non-interactive context expecting
  ratify**: ratification requires Owner; in headless mode, return
  result + flag for next interactive session.
- **Network calls without Owner awareness**: Sub-step 2 port probes
  + Sub-step 3 endpoint queries touch localhost. Document in the
  Owner-facing brief when running for the first time.

## Verification

- Result has all 6 fields populated (harness, backend_provider,
  backend_endpoint, backend_model, effective_context,
  recommended_tier — becomes `active_tier` in profile.md on ratify),
  with `(uncertain — <reason>)` annotations where detection failed
- Tier derivation matches the canonical rule in
  `runtime-flexibility.md`
- Signal disagreements surfaced to Owner; not silently resolved
- For bootstrap mode: active profile.md created only on Owner ratify; all
  6 fields persisted; `last_updated` set to today
- For drift-check mode: re-ratify proposed if `harness`,
  `backend_model`, or `effective_context` differ; current session
  continues with existing profile.md tier
- For freshness-check mode: known-constants table re-verified; table
  updates Owner-ratified; section-level `last_verified:` date bumped
