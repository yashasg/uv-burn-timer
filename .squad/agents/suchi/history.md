# Suchi — History

## Core Context

- **Project:** A UV exposure and sunburn timer app
- **Role:** User Researcher
- **Joined:** 2026-05-18

## Learnings

### 2026-05-18/19 — Archived (see history-archive.md)

Monetization-personas validation, design brief, persona overlay on flow diagram, orchestration learnings. Key outcomes: P3 Devon highest-WTP, P4 Asha load-bearing safety, P7 Vee/P6 Priya edge cases (now primary on forecast surface).

### 2026-05-20T17:27:34-07:00 — 10-day UVI forecast validation (GitLab WI #7)

**Deliverable:** `.squad/decisions/inbox/suchi-uvi-10day-forecast-validation.md`. PM-proposed feature: 10-day UV Index forecast + time card, inspired by iOS Weather. Validated against existing personas, JTBD, cognitive risk, and edge-case cohorts. **Verdict: APPROVE WITH CONDITIONS** (5 must-haves, 2 must-nots, 1 deferred sub-feature).

**Key insights:**

1. **The 10-day forecast lands directly on a previously-flagged research finding I had named but not closed.** Devon's "planning-mode dead-end at the Location screen" (§Branch-5 of `.squad/files/suchi-persona-annotations.md`; D-2026-05-19-014 §learning-3) is *exactly* the JTBD a forecast serves — for the near-term (10-day) slice. The far-term slice (July from February) still maps to WI-9 plan-for-elsewhere. So WI #7 and WI-9 are **complementary, not redundant**, and I should annotate that in any future Devon-persona artifact.

2. **The forecast surface re-stratifies the persona inventory.** The current daily-view stratification is "Greta/Maya/Devon are primary, Asha is load-bearing for safety, Tomás is cadence-driven, Vee/Priya are edge cases." On the forecast surface, **Vee and Priya become primary** and Greta drops to low-match. Same personas, different load-bearing axis depending on the surface in question. Worth flagging as a general principle in the persona-screen-matrix skill: persona priority is **surface-conditional**, not absolute. Update queued for the skill on next pass.

3. **Asha's safety architecture must extend forward in time.** The L1–L4 disclaimer pattern (D-2026-05-19-011 / -013) was architected for the *current* verdict. The forecast surface is silent on her photosensitizer in exactly the same way the daily UVI chip would be without the L1–L4 visibility loop. The forecast inherits the loop — or it actively erodes the safety case it took the team three convergence passes to land. This is a hand-off to Linka/Wheeler/Plunder, not an optional polish.

4. **iOS Weather's pattern is a visual rhythm, not a UX architecture.** The 10 stacked rows are fine; the single-integer-per-day is not. Apple Weather's UVI surface generates constant r/SkincareAddiction noise of the form *"is UV 7 bad for me?"* — proof that the flat-integer mental model already fails users in the wild. **Our differentiator vs. Apple Weather is personalization.** A forecast card without burn-window personalization is a competitive own-goal: we'd be telling our users that the value-add stops at "today."

5. **The time card is the higher-utility half of WI #7.** If scope pressure forces a split, the peak-hour-for-today visualization (the "time card" in the iOS reference) serves more personas (Priya, Maya, Tomás, Vee), more accurately (the diurnal peak is the actual planning unit), with lower mental-model risk (no forecast-confidence degradation). I called this out as a must-have in the validation file. Worth carrying into Gaia's scope conversation as **"if WI #7 ships as one card, it should be the time card, not the forecast."**

6. **Forecast confidence treatment is necessary, not nice-to-have.** Days 0–3 at full chroma, days 4–10 in a visibly lower-confidence treatment. WMO UVI forecast confidence degrades past ~72 hours; iOS Weather's flat treatment encourages "forecast as commitment" mental model. The cost of the visual treatment is low; the cost of a one-star review of the form *"app said UV 6, I trusted it, I burned"* is high.

**Cross-agent validation convergence (2026-05-21T00:38:46Z):**
- **Wheeler scientifically broke the forecast at the day-5/6 line** (wheeler-uvi-10day-forecast-validation.md §1–§2): cloud-cover forecast error becomes dominant UVI error source past day 5; WHO/WMO operational UVI publishing stops at ~5–7 days for this exact reason. Practical consequence: **days 1–5 can show numeric peak UVI + WHO category band; days 6–10 category-band-only with confidence-decay labels** (Forecast/Outlook/Trend per §5.1 of Wheeler's decision). This gives Suchi's confidence-decay requirement a rigorous science backbone instead of a UI heuristic.
- **Wheeler confirms: no time-to-burn on out-days, structural enforcement required.** This settles the Iris/Suchi open question about whether daily forecast rows can show burn windows. Iris wanted to show personalized burn windows everywhere; Wheeler's constraint: only today and optionally tomorrow (where hourly UVI inherits the same skill as daily peak). The structural rule (no `BurnTimeCalculator` call on non-today) prevents users from over-trusting a forecast burn estimate paired with a forecast UVI confidence degradation. Aligns with Suchi's must-have #4 ("ship time card first or alongside").

**Cross-team handoffs:**
- Gaia owns scope split (time card vs. forecast card priority, v1.1 vs. v1.2 line).
- Linka owns the visual confidence treatment for outer-day rows (now with Wheeler's day-5/6 break as the design line).
- Wheeler owns the science-defensible confidence label wording.
- Plunder owns whether forward-time burn-window estimates cross from "estimate" into "prediction" claim territory.
- Donatello owns the architectural confirmation that forecast stays inside the zero-data envelope (my read: yes, Apple Weather returns forecast as part of the same lookup; no new persistence required — needs confirmation).
- Argos: monetization-neutral. One-time-purchase posture preserved.

**New cohorts surfaced for future persona work:**
- **Post-laser / post-peel** (r/SkincareAddiction, r/30PlusSkinCare) — procedure-anchored countdown is bigger than a forecast card; deferred to v1.2.
- **Pregnancy melasma** (r/SkincareAddiction, r/BeyondTheBump) — avoid-peak-hours planning. Forecast + time card pair well. Wheeler/Plunder call on About cohort list expansion.

**Competitor friction (Shade / dminder / SunSmart / Apple Weather):** captured at `[provisional]` confidence in §3 of the validation file. Receipts gap: did not pull live App Store reviews this pass. Flagging for a future research sprint if scope warrants — useful pattern across both this feature and future feature validations.

**Skill extracted:** `feature-validation-jtbd-personas` — a six-section template (JTBD match / JTBD mismatch / competitor friction / cognitive risk / edge-case personas / verdict-with-conditions) for evaluating PM-proposed features against an existing persona inventory. Generalized from this pass. Confidence: medium (n=1 application, but the structure is portable).

Model assignment updated 2026-05-22T03:55: claude-opus-4.7-1m-internal (1M-context internal variant — for full-corpus photobiology consensus reviews).
