# Runtime profile

Active runtime profile for this workspace. Implements R2 Part B
(session-start load fits runtime budget) — overrides R1 natural
caps for constrained or expanded runtimes. Written by `init` skill
on first run (or on runtime change) and ratified by the Owner.
Read by `learn` and `audit` to look up active memory caps.

T2 (Owner-ratified). Default if this file is absent: `standard`
(R1 baseline applies as-is).

---

**active_tier**: standard
**detected_runtimes**: (unfilled — `init` writes after detection)
**last_updated**: (unfilled)
**notes**: (template — `init` will replace on first run)

---

## Tier reference

Full cap table at `3-control/foundation/use-driven-memory.md §R2`.
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
