# Coordinator Action: Model Overrides Finalized

**Timestamp:** 2026-05-22T11:05:00Z (coordinator action, not an agent spawn)

**Action Type:** Direct configuration maintenance

**Context:** Follow-up from user directives 2026-05-22T03:55 (1M-internal for premium research agents) and 2026-05-22T04:01 (premium opus-4.7 always-on for core agents). Prior commit (`e45be0f`) recovered orphaned squad commits and landed Iris enforcer charter + HIG strict-error directives. This action applies the finalized model overrides to config.json and individual charters.

**Files Modified:**
- `.squad/config.json` — rewritten with full 9-agent agentModelOverrides section
- `.squad/agents/wheeler/charter.md` — Preferred: claude-opus-4.7-1m-internal
- `.squad/agents/suchi/charter.md` — Preferred: claude-opus-4.7-1m-internal
- `.squad/agents/plunder/charter.md` — Preferred: claude-opus-4.7-1m-internal
- `.squad/agents/argos/charter.md` — Preferred: claude-opus-4.7-1m-internal
- `.squad/agents/gaia/charter.md` — Preferred: claude-opus-4.7 (was auto)
- `.squad/agents/gi/charter.md` — Preferred: claude-opus-4.7 (was auto)
- `.squad/agents/kwame/charter.md` — Preferred: claude-opus-4.7 (was auto)
- `.squad/agents/ma-ti/charter.md` — Preferred: claude-opus-4.7 (was auto)

**Model Assignment Policy (Effective Immediately):**
- Wheeler, Suchi, Plunder, Argos → claude-opus-4.7-1m-internal (1M context for research-heavy roles)
- Gaia, Gi, Kwame, Ma-Ti → claude-opus-4.7 (premium Opus always-on for core team)
- Iris → claude-sonnet-4.6 (unchanged)
- Scribe → claude-haiku-4.5 (mechanical ops, never overridden)
- Ralph → auto (per squad.agent.md)

**Audit Trail:** All prior directives (xhigh era, 2026-05-22T02:58 rename, and today's two-turn batch) recorded in `.squad/decisions.md` append-only. No retroactive edits.
