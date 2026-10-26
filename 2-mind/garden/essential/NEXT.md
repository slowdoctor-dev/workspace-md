# NEXT

Session-to-session handoff. **Append-only blocks** (R5): each
`session-end` (or `PreCompact` checkpoint) appends one block; the next
full `session-start` consumes *all* blocks and clears the file back to
this header. Never edit or merge another session's block.

Natural cap (R1): **240 tokens soft, total across unconsumed blocks**
(~30 lines, advisory). Runtime tier (R2) may scale: lean → 170,
extended → 400. See `3-control/runtime/profile.md`. Keep terse:
handoff, not a journal.

Block shape:

```
### <runtime>/<sid> @ <YYYY-MM-DDTHH:MM>
**Outstanding**: work in progress — exactly where it stopped
**Open questions**: decisions deferred for the Owner, with context
**Next-session priorities**: what to tackle first
```

<!-- blocks below this line; file is cleared to here on consumption -->

### cloud/01JBv5 @ 2026-10-26T12:55
**Outstanding**: v0.2.0 merged to `main`. No `profile.md` yet — run `init` (expect claude-code / anthropic / hosted-frontier / extended; mixed-runtime rule if local backends are used).
**Open questions**: reword canonical `SOUL.md §Avoid` "per-runtime entry (→ AGENTS.md)" for the card concept? Archive `1-active/2026-10-26_improvement-proposal.md` now or let `audit` do it?
**Next-session priorities**: confirm `AGENTS.md` loads natively without `CLAUDE.md`; run `init`; first `audit` pass for a metrics baseline.
