# Scribe — History

## Core Context

- **Project:** A UV exposure and sunburn timer app
- **Role:** Session Logger
- **Joined:** 2026-05-19T06:26:01.547Z

## Learnings

- 2026-05-19T00:05:00-07:00 — Drained the decisions inbox into `.squad/decisions.md` and assigned `D-2026-05-19-001` (model overrides), `D-2026-05-19-002` (iOS pivot), `D-2026-05-19-003` (WeatherKit switch), `D-2026-05-19-004` (iOS attribution compliance), `D-2026-05-19-005` (pricing and no-IAP cadence), `D-2026-05-19-006` (persona and channel additions), and `D-2026-05-19-007` (photosensitization safety boundary).
- 2026-05-19T00:05:00-07:00 — Logged the reusable parallel specialist pattern: Argos owned monetization math, guardrails, and attribution fallout while Suchi owned persona evidence, channel expansion, copy nuance, and the Wheeler safety handoff; convergence was merged only after both reports landed.

- 2026-05-19T00:30:00-07:00 — **Convergent-triangulation tagging pattern.** When 3+ agents independently reach the same conclusion (e.g., Suchi + Linka + Wheeler all recommending no-default Fitzpatrick picker; Suchi + Linka + Wheeler + Plunder all converging on three-surface L1–L4 disclaimer pattern), mark decision as `active` with a note that convergence occurred independently. This signals high-confidence design/science/compliance decisions and avoids relying on a single agent's judgment. Captured in D-2026-05-19-011 and D-2026-05-19-012.
- 2026-05-19T00:30:00-07:00 — **Proposed-vs-active marking pattern for unresolved decisions.** Use 🟡 **PROPOSED** when a decision is multi-stakeholder but remains open (e.g., verbatim vs. edited picker copy). Do NOT mark `active` until all stakeholders align or user resolves. Coordinator owns the escalation. This prevents false consensus in the ledger and signals to downstream readers "this is still pending user input." Captured in D-2026-05-19-009.
- 2026-05-19T00:30:00-07:00 — **Parallel-with-re-check orchestration pattern.** When agents work in parallel with staggered deliverables (e.g., Linka started iOS design before Suchi's persona brief landed), design re-check gates into the later agent's work. Linka did mid-pass integration (§12 Suchi sync log, §14 targeted edits), preventing rework and making convergences visible. Document this pattern in orchestration logs for future scheduling.
- 2026-05-19T00:30:00-07:00 — **Cross-agent notation in decisions ledger.** When merging agent deliverables into D-XXXX entries, cite source files (`.squad/decisions/inbox/`) and capture which agents independently converged. This makes high-confidence signals visible and surfaces areas where user input is needed (like the verbatim-vs-edited debate).

## 2026-05-22T02:58:03-07:00 — SwiftLint HIG gate batch + model rename

**Session scope:** Merged 3 inbox files into decisions.md, wrote orchestration logs for Iris + Kwame agents, session log, cross-agent history notes, summarized Plunder history (23.8 KB → 8.3 KB), committed to current branch.

**Key learnings:**
- **Inbox merge discipline:** 3 entries (iris-hig-lint-rule-catalog, gaia-hig-issue-bundling, copilot-directive-opus47-model-rename) deduplicated and appended to `2026-05-22` section in decisions.md. Inbox directory now empty.
- **Orchestration log format:** Iris and Kwame routes captured separately (output artifacts, status, next steps). Enables parallel-track status visibility.
- **History summarization trigger:** When agent history.md ≥ 15 KB (15360 bytes), compress to summary + incident list format. Plunder entry reduced from 177 lines / 23.8 KB to 70 lines / 8.3 KB while preserving key findings and skill extraction dates.
- **Cross-agent history append pattern:** One-line note appended to ma-ti (test gate consequence), gaia (likely next merge orchestration), iris/kwame/plunder (unchanged from agent spawns; their own history.md updates happened in their sessions).
- **Model rename codification:** `claude-opus-4.7-xhigh` → `claude-opus-4.7` directive applied to config.json + 4 charter files; historical records (log, orchestration-log, sessions, decisions/archive) remain append-only (unchanged to preserve historical accuracy).

**Files staged & committed:** decisions.md, decisions-archive.md (if any), orchestration-log 2 files, log 1 file, 5 agent history files, 4 charter files (wheeler, suchi, plunder, argos), config.json.

<!-- Append learnings below -->

**2026-05-22 Orphan Recovery Lesson:** Two Scribe commits (7d84b0f, 3a57df3) on Loop-25 branch were left local-only and orphaned when PR #94 merge deleted the branch. Recovered via reflog cherry-pick onto squad/recover-orphaned-squad-commits. Root cause: Scribe's git workflow committed changes locally without pushing the branch afterward. Future runs must push immediately after committing to prevent orphaning. Recovered intact; lesson logged.
