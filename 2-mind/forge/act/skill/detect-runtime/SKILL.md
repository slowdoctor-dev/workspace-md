---
name: detect-runtime
description: Detect (harness, backend, model_class) for this workspace and derive the recommended R2 tier. Invoked by `init` (bootstrap), `session-start` (drift check), or explicit `/detect-runtime`. Owner ratifies results into active `3-control/runtime/profile.md` per T2 discipline.
---

# detect-runtime

## When to use

- **From `init`** — bootstrap; produce the initial profile.md draft for Owner ratify from `profile.example.md`
- **From `session-start`** — cheap re-detect every full session start; compare against active profile.md; propose re-ratify on drift
- **Explicit `/detect-runtime`** — Owner invocation after switching harness or backend

## Requires

Requires `3-control/foundation/SOUL.md`,
`3-control/foundation/PRINCIPLE.md`, and `2-mind/garden/essential/`
to exist. If any are missing, run `init` instead of continuing.

Operationalizes `3-control/foundation/runtime-flexibility.md
§Detection mechanism`. The spec carries **no vendor constants table**
(removed v0.2): the running agent knows its own model; the class enum
is coarse enough to survive model releases.

## Quick reference

Single principle: **the running agent IS the runtime instance** —
agent self-introspection is the primary signal; objective signals
(env vars, config files, endpoint queries) cross-check. Mismatch =
report to Owner; never silently resolve.

| Sub-step | Primary signal | Verification | Fallback |
|---|---|---|---|
| 1. Harness | Agent self-introspection | Env var → repo config folder → user-level config | `custom` |
| 2. Backend (provider + endpoint + model) | Agent self-identification | Per-harness config read; if local-via-proxy, probe localhost `/v1/models` | Ask Owner |
| 3. Model class | Agent self-knowledge of its model | Hosted: model-id family; Local: parameter count from model id / `/api/show` | `uncertain` |

Optional helper: `2-mind/forge/act/script/detect-runtime.sh`
automates the objective checks (1B/1C, 2B/2C, local 3B) and emits
JSON. It cannot perform agent self-introspection (Step 0); the agent
supplies that before interpreting helper output.

## Procedure

### Step 0 — Agent self-introspection (cannot be scripted)

Record your own primary signal: which harness loaded you (discovery
file path, visible tools, system context), which model you are, and
roughly how large it is. Scripts see none of this; their output is
verification, not the result.

### Sub-step 1 — Detect harness

**A. Self-introspection** (primary): `AGENTS.md` loaded natively →
`codex-cli` / `claude-code` (2.1.277+) / `antigravity` / `cursor` /
other AAIF-native harness — disambiguate with B/C. `CLAUDE.md`
present and loaded → `claude-code`. `.agents/` aliases + `agy` →
`antigravity`.

**B. Env var / config verification** (objective):

| Signal | Harness |
|---|---|
| `CLAUDE_PROJECT_DIR` or `.claude/` | `claude-code` |
| `CODEX_PROJECT_DIR` or `.codex/config.toml` | `codex-cli` |
| `AGY_*`, `agy --version`, `~/.config/agy/` | `antigravity` |
| `GEMINI_PROJECT_DIR` or `.gemini/` (no `agy`) | `gemini-cli` (legacy) |
| `.cursor/` | `cursor` |
| `~/.hermes/config.yaml` | `hermes` |
| `.config/opencode/opencode.json` | `opencode` |
| `.continue/config.yaml` | `continue` |

**Resolution**: self-introspection must match ≥1 objective signal.
Conflict → ask Owner. No signals → `custom`.

**Gemini / Antigravity collision**: both present → warn in
`signal_disagreements` and point to
`3-control/runtime/antigravity-cli.md` (shared `~/.gemini/GEMINI.md`
leaks rules).

### Sub-step 2 — Detect backend (provider + endpoint + model)

**A. Self-identification** (primary): "What model am I?" Hosted
models reliably know; local fine-tunes may misreport.

**B. Per-harness config** (objective): `OPENAI_BASE_URL` /
`ANTHROPIC_BASE_URL` set → routed through a proxy (local Ollama /
LM Studio, or LiteLLM) — query `<base>/models`. Else native provider
+ model id from harness settings. Hermes / OpenCode / Continue: read
their config files.

**C. Local-port probe** (uncertain harness): first valid `/v1/models`
wins — `:11434` Ollama, `:1234` LM Studio, `:8080` llama.cpp, `:8000`
vLLM.

**Resolution**: disagreement (self says "Claude Opus 5.5", endpoint
says `qwen3:32b`) → likely proxy mismatch; surface to Owner. Empty
model → `uncertain`; do not infer a tier from absence.

### Sub-step 3 — Determine model class

Classes per `runtime-flexibility.md §Model classes`:
`hosted-frontier` · `hosted-small` · `local-large` · `local-small` ·
`uncertain`.

- **Hosted**: from the model-id family — vendor top/mid tier →
  `hosted-frontier`; fast/cheap tier (`haiku`, `mini`, `nano`,
  `flash`, `lite`) → `hosted-small`.
- **Local**: parameter count from the model id (`:8b`, `-32b`) or
  `ollama show <model>`; ≥30B → `local-large`, ≤13B → `local-small`,
  14–27B → Owner judgment (record in `notes`).
- **Optional `effective_context`**: record when one call gives it
  (Anthropic Models API `max_input_tokens`; local `/v1/models`
  `context_length` / `max_model_len`; `ollama show` → `num_ctx`).
  Only used as a sanity check.

```bash
curl -s http://localhost:11434/v1/models | jq '.data[].id'
curl -s "${BACKEND_ENDPOINT}/v1/models" | jq '.data[] | {id, context_length, max_model_len}'
```

### Sub-step 4 — Derive tier

Canonical rule (`runtime-flexibility.md §Tier-derivation rule`):
`hosted-frontier` → `extended`; `hosted-small` / `local-large` →
`standard`; `local-small` → `lean`; `uncertain` → `standard`.
**Override**: `effective_context` known and ≤16K → `lean` + flag
"local window misconfigured (e.g., Ollama default)".

In drift-check mode profile.md is authoritative when detection is
uncertain; the detected tier is a *proposal* for re-ratify only.

### Sub-step 5 — Produce result

```
harness:             <detected>
backend_provider:    <detected>
backend_endpoint:    <detected>
backend_model:       <detected>
model_class:         <detected>
recommended_tier:    <derived per rule>     # → active_tier on ratify
effective_context:   <optional integer>
signal_disagreements: [<strings>]
```

**Bootstrap mode** (from `init`): present field-by-field for T2
ratify; create active profile.md from `profile.example.md` on accept.

**Drift-check mode** (from `session-start`, full starts only — not
re-entry): compare against active profile.md. `harness`,
`backend_model`, or `model_class` differ → surface diff + propose
re-ratify; continue this session with profile.md's tier. Return
`{matches: true|false, diff: …}` plus the result fields.

## Pitfalls

- **Trusting self-identification blindly**: local fine-tunes
  misreport; cross-verify.
- **Treating the helper as full detection**: it cannot do Step 0.
- **Silently picking on disagreement**: disagreement IS the signal.
- **Deriving a tier from an empty model**: `uncertain` → profile.md's
  tier, or `standard`.
- **Reintroducing a constants table**: vendor context windows change
  faster than a spec can track; classify by family, verify nothing.
- **Running in headless mode expecting ratify**: return result +
  queue the proposal (`use-driven-memory.md §Ratification channels`).
- **Network calls without Owner awareness**: port probes touch
  localhost; mention it in the first-run brief.

## Verification

- Result has `harness`, `backend_provider`, `backend_endpoint`,
  `backend_model`, `model_class`, `recommended_tier` populated (or
  `(uncertain — <reason>)`); `effective_context` optional
- Tier derivation matches the canonical rule
- Signal disagreements surfaced, not silently resolved
- Bootstrap: active profile.md created only on Owner ratify;
  `last_updated` = today
- Drift-check: re-ratify proposed on `harness` / `backend_model` /
  `model_class` change; session continues with existing tier
