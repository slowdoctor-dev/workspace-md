# Runtime profile — EXAMPLE / template

> **This is `profile.example.md`, not an active profile.** A fresh
> clone ships **no** `profile.md`, so the documented *absent → default
> `standard`* path applies until `init` runs. `init` copies this
> template to `3-control/runtime/profile.md` and fills it after Owner
> ratifies `detect-runtime` results. Do not treat the values below as
> ratified state.

**Purpose**: the active `profile.md` is the T2-ratification record of
the runtime tier for this workspace. Tier governs USER / NEXT / journal
/ garden caps used by `dream` and `audit`. Written by `init` after
Owner ratifies detection from `detect-runtime`; read by all memory
skills. Drift between `profile.md` and a fresh `detect-runtime` run
triggers a re-ratify prompt at `session-start`.

T2 (Owner-ratified). Default if `profile.md` absent: `standard` (R1
baseline applies as-is). See `3-control/foundation/runtime-flexibility.md`
for the full mechanism (tier system, model classes, derivation rule,
detection, graceful degradation).

---

**harness**: (unfilled — `init` writes after detection)
**backend_provider**: (unfilled — `init` writes after detection)
**backend_endpoint**: (unfilled — `init` writes after detection)
**backend_model**: (unfilled — `init` writes after detection)
**model_class**: (unfilled — `init` writes after detection)
**active_tier**: standard
**effective_context**: (optional — record when cheaply known)
**last_updated**: (unfilled)
**notes**: (template — `init` will replace on first run)

Field reference (6 required + 2 optional):
- `harness` — agent CLI / UI wrapping the agent loop (`claude-code` |
  `codex-cli` | `antigravity` | `cursor` | `hermes` | `opencode` |
  `continue` | `gemini-cli` (legacy — retired 2026-06-18 outside
  Enterprise) | `custom`; open enum)
- `backend_provider` — LLM token generator (`anthropic` | `openai` |
  `google` | `ollama` | `lm-studio` | `mlx` | `llama-cpp` | `vllm` |
  `custom`; open enum)
- `backend_endpoint` — URL (hosted SDK default OR e.g.
  `http://localhost:11434/v1`)
- `backend_model` — model id (e.g. `claude-opus-5-5`, `qwen3:32b`).
  **Descriptive vs prescriptive**: where the Owner picks the model
  this is prescriptive (what the workspace targets); where the harness
  auto-selects, record the observed selection with an `auto:` prefix
  (e.g. `auto:gemini-3-flash`).
- `model_class` — `hosted-frontier` | `hosted-small` | `local-large` |
  `local-small` | `uncertain` (open enum; defined in
  `runtime-flexibility.md §Model classes`). **Drives the tier.**
- `active_tier` — `lean` | `standard` | `extended` (Owner-ratified;
  may differ from detection's recommendation)
- `effective_context` *(optional)* — integer tokens when cheaply known
  (Models API `max_input_tokens`, local `/v1/models`). Used only as a
  sanity check: ≤16K forces `lean`.
- `last_updated` — `YYYY-MM-DD` of most recent ratification
- `notes` — Owner annotations: rationale, exceptions, class judgment
  calls for mid-size local models

---

## Tier reference

Full cap table at `3-control/foundation/runtime-flexibility.md`.
Summary (tokens; line counts are a secondary advisory):

| Tier | USER (hard / consol) | NEXT | journal/<entry> | garden/<topic> flag |
|---|---|---|---|---|
| `lean` | 500 / 400 | 170 | 1200 soft | 2000 |
| `standard` | 800 / 640 | 240 | 2000 soft | 3200 |
| `extended` | 1600 / 1280 | 400 | 4000 soft | 6400 |

`standard` = R1 natural baseline. `lean` and `extended` are R2
runtime-tier overrides.

## Mixed-runtime rule

If multiple runtimes share this workspace, set `active_tier` to the
**most constrained** of the set. Writes from constrained sessions are
always readable by extended sessions; the reverse silently overflows.

## When to re-ratify

- Switching primary runtime (e.g., moving hosted → local-only)
- Adding a new local model that changes the constrained-tier
- Owner judgment ("we're using more journal detail; bump to extended")

Run `init` again, or edit the active `profile.md` directly + commit
(not this `profile.example.md` template).
