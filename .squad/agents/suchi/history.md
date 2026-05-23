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

## 2026-05-22 — Loop-27 review

**Goal 3 (User scenarios captured) verdict: PASS.**

Loop-27 shipped HIG-only token cleanup — `@ScaledMetric` wiring so the ≥44×44pt tap-target rule already documented in the LANE 2 HIG note block (`user-flow-onboarding-main-spec.md` line 70: "≥44×44pt targets, … Dynamic Type AX5 reflow") is now *actually* honored at AX5 sizes, not just nominally at default size. No copy, IA, flow, or persona-keyed behavior moved. LANE 4 overlays describe *behavioral* annotations (L1 visibility loop, no-default Fitz picker, window-elapsed surfacing, pull-to-refresh) — none of which are pixel-bound. Loop-27 therefore strengthens the persona overlays it doesn't contradict.

**Spot-checks against shipped behavior:**

- **P4 Asha (row 4):** L1 disclaimer + toolbar ⓘ `EstimateInfoButton` → `AboutView(highlightEstimateApplicability: true)` is annotated as "MOST IMPORTANT L3 TAP." At AX5, the ⓘ now scales with the toolbar bar-button — it stays reachable instead of collapsing under a too-small chrome. The "load-bearing visibility loop" on L1 is unaffected by the scaling pass (it's a presentation policy, not a metric). **Overlay matches shipped behavior.** ✅
- **P5 Tomás (row 5):** "His safety moment — window-elapsed" depends on the user *seeing and tapping* the elapsed-window surface in field conditions (trail, sweat, sometimes gloves, often a larger Dynamic Type bump because he's a 40-something runner). Loop-27's `@ScaledMetric` pass is the literal mechanism that makes this tap survive AX5. **Overlay matches shipped behavior, and is materially better-served post-Loop-27.** ✅
- **P3 Devon (row 3, no-default Fitz picker):** Devon is the "I-understand validator" — at AX5 his confirmation button and Fitz row hit-tests both stay ≥44pt now. Reachability concern noted in the spawn context is satisfied. **Overlay matches.** ✅

**Loop-28 persona-keyed gaps surfaced:** None new. The Loop-27 scope was narrow and clean; no inbox decision filed. The standing P6 Priya / P7 Vee gaps already tracked on the forecast surface (see 2026-05-20 entry) remain the live persona-keyed work — they predate this loop and aren't touched by it.

**No-op for Suchi's domain confirmed.** Carrying forward.

---

## 2026-05-22: Loop-28 closure — No new persona gaps; LANE 4 overlays intact

**Suchi (persona research) perspective:** Loop-28 shipped 4 refactoring WIs (toolbar, chip/footer, hardcoded-frame-dimensions audit, matched-brace helper). All HIG-only changes; no user-flow spec, persona copy, or accessibility persona touch-point logic modified. LANE 4 personas (Greta / Maya / Devon / Asha / Tomás) remain unchanged and on-canvas. No new persona-keyed gaps surfaced. Standing P6 Priya / P7 Vee gaps (forecast surface, pre-Loop-28) remain live work item. Carry-forward: WI-2-flake investigation (UI cold-start timing race).

**2026-05-22T18:30:00Z** — Loop-29 iter-2 closure complete: 3 PRs merged (#106 WI-29-7, #107 WI-29-6, #108 WI-29-4). Goals 4/5 ✅, Goal-5 hardware-blocked. Decisions merged, orchestration-log + session-log recorded. Ready for Loop-30 planning.

### 2026-05-22T22:15:00Z — Loop-30 closure — final review delivered. Goals: 4/5 PASS (Goal-5 hardware-blocked). 8 PRs merged. 10 WIs carry-forward.

## 2026-05-23T01:14:18Z — WI-L32-TOMAS-SCAN (P2) — LocationRationaleOnboardingView scannability audit for Tomas

READ-ONLY audit. Measured `ProductCopy.locationRationaleBody` (`app/Sources/UVBurnTimerCore/ProductCopy.swift:107-112`, rendered at `LocationRationaleOnboardingView.swift:50` with `.font(.body)`).

**Counts:** 359 chars · 64 words · 4 sentences (85/128/74/69 chars). Estimated **~8 rendered lines** at default Dynamic Type body on iPhone 17 Pro default width (≈44–48 chars/line at SF 17pt over a ~370pt content column).

**Tomas budget** (established here since `suchi-persona-annotations.md` had no prior Tomas scannability gates): ≤2 sentences, ≤~110 chars, ≤~20 words, ≤2 short rendered lines, glance-to-Continue under 3s.

**Verdict: FAIL** — production body is ~3.3× over char budget, 2× over sentence budget, ~4× over line budget. Body is privacy-load-bearing (GDPR / Plunder lane / Iris policy alignment), so this is a density-vs-completeness tension, not a defect.

Filed `.squad/decisions/inbox/suchi-wi-l32-tomas-scan.md` with FAIL analysis + two proposed tighter copy alternatives (Option A 94 chars / Option B 107 chars) for Iris+Wheeler+Plunder copy review, plus a "summary on top, receipts in a disclosure below" compromise pattern that would preserve Greta/Maya's needs. Production string **not modified**. Flagged the two pinning unit tests in `LocationRationaleOnboardingTests.swift:135,155` for Wheeler if copy lands.
