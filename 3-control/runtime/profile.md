# Runtime profile

**Purpose**: T2-ratification record of the active runtime tier for
this workspace. Tier governs USER / NEXT / journal / garden caps
used by `dream` and `audit`. Written by `init` after Owner ratifies
detection results from `detect-runtime`; read by all memory skills.
Drift between this file and a fresh `detect-runtime` run triggers a
re-ratify prompt at `session-start`.

T2 (Owner-ratified). Default if absent: `standard` (R1 baseline
applies as-is). See `3-control/foundation/runtime-flexibility.md`
for the full mechanism (tier system, derivation rule, detection,
graceful degradation).

---

**harness**: (unfilled — `init` writes after detection)
**backend_provider**: (unfilled — `init` writes after detection)
**backend_endpoint**: (unfilled — `init` writes after detection)
**backend_model**: (unfilled — `init` writes after detection)
**effective_context**: (unfilled — `init` writes after detection)
**active_tier**: standard
**last_updated**: (unfilled)
**notes**: (template — `init` will replace on first run)

Field reference:
- `harness` — agent CLI / UI wrapping the agent loop (`claude-code` |
  `codex-cli` | `gemini-cli` | `cursor` | `hermes` | `opencode` |
  `continue` | `custom`; open enum)
- `backend_provider` — LLM token generator (`anthropic` | `openai` |
  `google` | `ollama` | `lm-studio` | `mlx` | `llama-cpp` | `vllm` |
  `custom`; open enum)
- `backend_endpoint` — URL (hosted SDK default OR e.g.
  `http://localhost:11434/v1`)
- `backend_model` — model id (e.g. `claude-sonnet-4-6`,
  `qwen2.5-coder:32b`)
- `effective_context` — integer tokens (from `/v1/models` query or
  known constant; see `detect-runtime/SKILL.md` §3)
- `active_tier` — `lean` | `standard` | `extended` (Owner-ratified;
  may differ from detection's recommendation)
- `last_updated` — `YYYY-MM-DD` of most recent ratification
- `notes` — Owner annotations: rationale, exceptions, declared
  attention-quality observations

---

## Tier reference

Full cap table at `3-control/foundation/runtime-flexibility.md`.
Summary:

| Tier | USER (hard / consol) | NEXT | journal/<entry> | garden/<topic> flag |
|---|---|---|---|---|
| `lean` | 60 / 50 | 20 | 100 soft | 200 |
| `standard` | 100 / 80 | 30 | 200 soft | 300 |
| `extended` | 200 / 160 | 50 | 400 soft | 500 |

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

Run `init` again or edit this file directly + commit.
