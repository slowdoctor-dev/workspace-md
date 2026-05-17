# NEXT

Session-to-session handoff. Single-consumption working buffer:
written by `session-end` of session N; consumed and cleared by
`session-start` of session N+1.

Size soft cap is **tier-dependent** — see
`3-control/runtime/profile.md` (defaults: lean=20 / standard=30 /
extended=50). Keep terse — handoff content, not a journal.

## Outstanding

(Work in progress, paused mid-task. Include where exactly it stopped.)

## Open questions

(Decisions deferred for the Owner. Include the question + context.)

## Next-session priorities

(What to tackle first when resuming.)
