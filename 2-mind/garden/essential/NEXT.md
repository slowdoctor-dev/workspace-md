# NEXT

Session-to-session handoff. Single-consumption: written by
`session-end` of session N, consumed and cleared by `session-start`
of session N+1.

Natural cap (R1): **240 tokens soft** (~30 lines, advisory). Runtime
tier (R2) may scale: lean → 170, extended → 400. See
`3-control/runtime/profile.md`. Keep terse: handoff, not a journal.

## Outstanding

Work in progress, paused mid-task. Include exactly where it stopped.

## Open questions

Decisions deferred for the Owner. Include question + context.

## Next-session priorities

What to tackle first when resuming.
