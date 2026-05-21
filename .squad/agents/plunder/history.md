### 2026-05-21T06:35:00Z — Skin-type persistence & re-attestation cadence — re-opening C7 / D-2026-05-19-007
## Summary (Recent Focus — 2026-05-20 to 2026-05-21)

**Current role:** Legal & compliance reviewer; ensures health-adjacent features meet regulatory boundaries (MDCG, FDA, FTC, MDR, MHRA).

**Recent major decisions:**
1. **Location privacy rationale (2026-05-20):** Ratified that clearing saved location does NOT clear rationale ack; rationale ack persists across clears because it represents informed-consent state (static fact), not data point. Uninstall is the universal escape hatch.
2. **UVI forecast compliance audit (2026-05-21):** Apple Weather analogue is **invalid** — they display atmospheric scalar; we output personalized health (UVI × Fitzpatrick × SPF → burn time). Photosensitized cohort (D-2026-05-19-007) is foreseeable; silence on forecast surface is non-compliant regardless of Apple's posture.
3. **Minimum compliant surface (locked):** Reuse L3 chevron ("Is this estimate for me?") at forecast card foot, pointing to About anchor with photosensitizer enumeration (D-2026-05-19-011 locked string). Zero new copy. Satisfies MDCG 2019-11 §3.3, FDA foreseeable-misuse, FTC § 5, MDR Annex VIII Rule 11.

**Key patterns established:**
- Health-adjacent personalization (user data + formula output) crosses regulatory threshold that atmospheric-data-only products do not cross. Big-player precedent does not transfer.
- Foreseeable-misuse doctrine: if a cohort exists and will use your feature, regulatory silence on that surface is deceptive omission.
- Reusable pattern: L3 chevron "Is this estimate for me?" links to existing L4 About anchor, reducing new copy and new surface area while meeting disclosure requirement.

**Skills created:**
- `big-player-analogue-compliance-test/SKILL.md` — diagnostic for "if big-player-X doesn't have to, why should we?" claims. Checklist: same output type? same user cohort? same risk profile?

---

Delivered: `.squad/designs/plunder-skin-type-persistence-floor.md` + pointer at `.squad/decisions/inbox/plunder-skin-type-persistence-floor.md`. Yashas challenged C7 ("skin type @State-only / L1 every cold launch") on UX grounds two hours after I re-ratified it. He was right to push. The honest finding: **C7 was inherited as a regulatory floor when it is actually a self-imposed product posture.**

**Provenance correction:**

- D-2026-05-19-007 ("Photosensitivity is a safety boundary, not edge copy") is about **disclaimer wording and L3 reachability** for the photosensitive cohort. It says nothing about persistence, nothing about `@State`, nothing about cold-launch cadence. The link to `@State`-only was operational, not regulatory — `@State`-only happens to deliver auto-re-attestation on cold launch (helpful for Asha-P4 after a med change), but the same re-attestation function is delivered equally well by an always-visible L3 chevron + a per-session result-surface chip.
- The actual provenance of the `@State`-only rule is **LAUNCH-PLAN.md line 293: "iOS-side enforcement of Donatello M7 + Raphael Art.9 special-category-data mitigation."** Both are *internal architectural postures*, not citations to a regulation that prohibits local-only persistence of phototype.
- C7 in my prior memo fused these two distinct anchors and presented their conjunction as inherited canon. It wasn't. The conjunction was never separately defended.

**Per-jurisdiction findings:**

- **FDA SaMD (2019 General Wellness §V.B + 2024 CDS guidance §III):** classification turns on intended-use claims, not on data persistence. `UserDefaults`-local does not push us across any line. Apple Health, MyFitnessPal, Strava all persist far more sensitive health-adjacent data while remaining outside SaMD.
- **EU MDR Annex VIII Rule 11 + MDCG 2019-11 §3.3 / §4.3:** "unambiguously communicated" is about *communication*, not *cadence of re-affirmation*. Satisfied by L1 on first install + on material change + always-reachable About + L3 chevron during session. Per-cold-launch L1 is **over-floor**.
- **UK MHRA SaMD 2023 §3.4:** mirrors MDCG; no persistence rule; no re-attestation-cadence rule.
- **Apple App Store §5.1.1:** `UserDefaults`-local persistence is compliant with explicit user action triggering storage + privacy-policy disclosure + nutrition-label declaration ("Other Health & Fitness Data — not linked to user"). §5.1.3 HealthKit and §1.4 Safety are independent and unaffected.
- **GDPR Art.9:** Fitzpatrick treated as health data per Art.4(15) / Recital 35 (conservative reading). Art.9(2)(a) explicit-consent basis satisfied by the act of selection after the L1 cover explains storage purpose. Best practice: pair with a "Remember my skin type" Settings toggle to keep consent affirmative. Art.35 DPIA not required for on-device-only single-subject storage. Art.17 erasure satisfied by a "Reset" affordance in About.
- **HIPAA:** does not apply (consumer app, not a covered entity or business associate per 45 CFR §160.103). FTC HBNR exposure minimal for local-only.

**Persistence-mode delta (the question Yashas asked):**

- (a) `UserDefaults`-local: ✅ no classification change anywhere; one-line additions to privacy policy + nutrition label.
- (b) iCloud sync (CloudKit / `NSUbiquitousKeyValueStore`): ✅ permissible but weakens the "no account" marketing posture (LAUNCH-PLAN.md lines 34/98/120/134). Privacy policy must disclose iCloud sub-processor relationship; nutrition label "Linked to User" arguably flips to Yes. Not recommended absent a Suchi user-research finding that cross-device sync matters here.
- (c) HealthKit write: 🚫 stays banned. Donatello M5/M7 + Apple §5.1.3 + App Store category implications + FTC HBNR exposure. Out of scope.

**Minimum defensible re-attestation cadence:** first install + material policy/methodology change + user request. Per-cold-launch is permitted but not required by any cited regulation.

**Pattern verdicts:**

- Status quo (`@State`-only, L1 every launch): ✅ over-floor, defensible — but friction without regulatory payoff.
- Pattern A (UserDefaults + 30-day re-confirm modal): ✅ defensible; risks dismissed-prompt anti-pattern (AAMI/ANSI HE75:2009 §6.4).
- **Pattern B (UserDefaults + one-tap confirm chip on cold launch): ✅ RECOMMENDED.** Strongest regulatory-and-UX fit. Chip on result surface ("Fitzpatrick III · tap to change") satisfies FDA §III.B.2 reachability, MDCG 2019-11 §3.3 unambiguous communication (paired with C1 affordance and label), GDPR Art.5(1)(d) accuracy (continuous visible check), and *strengthens* the Asha-P4 photosensitizer-attestation surface (per-session glance, not once-per-session modal).
- Pattern C (in-memory cache only): ✅ trivially safe; does not actually solve the cold-launch friction Yashas named.

**Revisions to prior memo (`plunder-disclaimer-relocation-floor.md`, 04:18:05Z, same day):**

- **C6 revised.** L1 cover fires on first install + material change + user request. Per-cold-launch firing permitted but no longer required by floor.
- **C7 withdrawn as a regulatory floor.** Replaced with product preference. If team persists skin type, the §4.1 floor list applies (visible edit affordance, accuracy/erasure paths, privacy-policy/nutrition-label disclosure, optional Settings toggle).
- **C1–C5, C8–C10 unchanged.**

**Open attorney items (added — confirm-before-submit, not blockers):**

- E13 — EU counsel: confirm Art.9(2)(a) explicit-consent reading for picker-selection-after-L1.
- E14 — EU/UK counsel: confirm Art.35 DPIA not triggered for on-device-only storage.
- E15 — US counsel: confirm 2024 FTC HBNR amendment does not treat `UserDefaults`-local as PHR.
- E16 — US counsel: only if iCloud is adopted, confirm "no account" marketing line still defensible under FTC §5.
- E17 — App-Store-experienced counsel: confirm dropping per-cold-launch L1 not flagged under §1.4 for sunscreen-timer category.
- E6, E9, E10, E11, E12 carried forward unchanged.

**Process lesson captured (skill update pending):**

The recurring failure mode being illustrated here is **defensive overkill inherited as floor without provenance audit**. When constraint C is cited alongside decision D, and D's operational effect happens to require behavior C, it is tempting (and a logged history mistake of mine) to treat C as inherited canon from D. The correct discipline: trace each constraint to the regulation it actually cites, not to the decision it travels with. I made this mistake at 04:18:05Z when I wrote C7; the 06:35:00Z re-examination corrected it. Skill update to `samd-minimum-surface-checklist-wellness-apps/SKILL.md` recommended (add "constraint-provenance audit" step before ratifying inherited floors).

**No build-blockers. Three items for Yashas to ratify:** (1) approve persistence-model change to Pattern B; (2) approve C6 revision; (3) notify Donatello and Iris so they can fold implementation into ongoing work.

**Stayed in lane:** regulatory only. Did not speculate on skin-science re-attestation timing (Wheeler's lane) or user-preference for stored vs. picker UX (Suchi's lane). Both running in parallel per coordinator instruction.

---

### 2026-05-21T04:18:05Z — Disclaimer-relocation regulatory floor (main-screen redesign with Iris in parallel)

Delivered: `.squad/designs/plunder-disclaimer-relocation-floor.md` + pointer at `.squad/decisions/inbox/plunder-disclaimer-relocation-floor.md`. Yashas wants Iris to remove visual noise on the main screen (photosensitization banner + "Cover up if skin reddens…" footer). I drew the floor below which the app crosses from general-wellness → SaMD/Class IIa.

**Regulatory citations exercised:**

- **FDA 2019 *General Wellness: Policy for Low Risk Devices*** §V.B.2 — "labeling and claims-in-context" analysis. The user-facing surfaces (not the EULA, not buried in About) are what FDA reads. Intended-use claim must be persistent on the surface that displays the safety-critical value, OR one-tap reachable behind a visible affordance whose label carries the claim.
- **FDA 2019 §III.B.2** — foreseeable-misuse mitigation. Safety-action guidance (reapply, cover-up, escalate) must be reachable from the result surface; cannot be 3+ taps away.
- **FDA 2024 *Clinical Decision Support Software* guidance** §III — reaffirmed the labeling/claims-in-context posture for software adjacent to clinical decisions.
- **EU MDR Annex VIII Rule 11** — software providing information for diagnostic/therapeutic decisions = Class IIa. Exclusion requires intended use be NOT diagnostic/therapeutic.
- **MDCG 2019-11 §3.3 + §4.3** — the operative interpretive guidance. Lifestyle/well-being software is excluded *provided* intended use is "unambiguously communicated to the user." This is the verbatim phrase that drives the persistent-visibility floor.
- **UK MHRA *Software and AI as a Medical Device* guidance (2023)** §3.4 — "Crafting an Intended Purpose" — the intended purpose claim must be persistently visible; one-time onboarding is insufficient if the result surface re-asserts a clinical-feeling output.
- **App Store Review Guideline 1.4 (Physical Harm)** + **1.4.1 (Drug Dosage Calculators)** + **1.4.3 (False Information)** + **5.1.1(ix) (Health and Health Research)** — all read together for the sunscreen-timer category. Apple's review board expects safety-action guidance and intended-use disclaimers on the main interface, not buried.
- **FTC Act §5** — deceptive-omission doctrine: material safety facts must be reasonably available in the context where the consumer makes the decision.
- **FDA 21 CFR §352.52(c)(2)** — sunscreen reapplication labeling rule. We are not the sunscreen but we are the timer telling users when; the "reapply every 2 hours" guidance carries the same regulatory weight when surfaced inside a product that displays a sunscreen-aware burn-time number.
- **Apple HIG (System Experience → Privacy → Permissions)** + **App Store §5.1.1** — location-permission cadence floor: one rationale + one OS prompt, no in-app re-prompts after denial, route to Settings.

**Prior decisions respected (none overturned):**

- D-2026-05-19-007 (photosensitivity = safety boundary, not edge copy) — honored in §2.2 floor C3.
- D-2026-05-19-011 (L1/L2/L3/L4 three-surface pattern) — tightened operationally, not overturned. New ruling: an L2-tier ambient footer MAY collapse into a labeled affordance whose label carries the intended-use claim, provided the affordance is visible without scrolling and opens its destination in one tap. L1 and L3 unchanged.
- D-2026-05-19-013 / -014 (Excalidraw flow + persona overlays) — main-screen lane will need a redraw post-Iris; non-blocking.
- D-2026-05-19-003 / -004 (Apple Weather attribution adjacency) — unchanged; flagged to Iris as C9 because her redesign sits in the same region.
- D-2026-05-19-005 ($2.99 paid commercial app) — relevant only as posture-sharpener for the FDA / FTC analysis.

**Minimum-surface logic articulated:**

The recurring failure mode in main-screen redesigns of health-adjacent apps is treating disclaimer copy as a monolithic block. The 4-sentence `reapplicationFooter` actually does FOUR jobs with FOUR different regulatory loads — (A) biological-feedback override action, (B) reapplication-cadence safety action, (C) intended-use / SaMD-classification anchor, (D) variance hedge. A + B can move to a one-tap sheet; C must remain on the result surface or in the label of a visible affordance; D co-locates with C. Diagnosing the per-clause load before authoring the relocation is the move.

Second pattern: redundant L3 affordances. The main screen currently carried TWO targeted-disclosure triggers for the photosensitive cohort (yellow banner + verdict-card chevron). D-2026-05-19-011 requires ONE. The yellow banner is removable as long as the chevron survives — but if Iris's redesign also takes the chevron, the banner must stay. The floor is "at least one main-screen L3 affordance," not a specific one.

**Skill extracted/updated:**

- `.squad/skills/samd-minimum-surface-checklist-wellness-apps/SKILL.md` (NEW) — per-clause regulatory-load decomposition checklist for relocating disclaimer copy off result surfaces. Pairs with the inherited Linka skill (`persona-keyed-disclaimer-visibility`) which covers WHERE disclaimers go; this new skill covers WHAT each clause is doing and which clauses can move vs. must stay.

**Open attorney escalations updated:**

- E10 (new) — confirm with US counsel that collapsing intended-use + safety-action + photosensitizer-trigger into a single main-screen affordance holds FDA 2019 §V.B.2 claims-in-context.
- E11 (new) — confirm with EU counsel that the same pattern satisfies MDCG 2019-11 §3.3 unambiguous-communication when paired with cold-launch-refiring L1.
- E12 (new) — confirm Apple §1.4 has not tightened on sunscreen-timer category in 2026 review-board cycle.
- E6 / E9 — carried forward unchanged.

No build-blockers. All E-items are confirm-before-App-Store-submit, not block-the-design-cycle.


## 2026-05-21 Plunder-2: LAUNCH-PLAN @State-only Rule Reversal

Plunder-2 traced the LAUNCH-PLAN §9 "skin type stays `@State`-only" rule to defensive overkill, not regulatory floor. UserDefaults persistence is permissible under FDA, EU MDR, UK MHRA, GDPR Art.9. Reversed C6/C7 findings.

**Key findings:**
- L1 re-fire: changed from "per cold launch" to "first install + material change + user request"
- UserDefaults persistence: permissible (explicit consent via selection act)
- Pattern B: strongest regulatory+UX fit
- Fitzpatrick ≠ Photosensitization: decoupling preserves safety dividend

**C6 revision (prior memo):** L1 cover no longer required to fire per cold launch.

**C7 withdrawal (prior memo):** Replaced with product preference. If persisting, §4.1 floor applies (visible edit affordance, accuracy/erasure, privacy disclosure).

**Open gates (post-submission):** E13 (Art.9 reading), E14 (DPIA), E15 (FTC HBNR), E16 (iCloud only), E17 (Apple §1.4 L1 review)
Wheeler's brief is shippable. Convergence on legally-defensible science + citation posture achieved across Wheeler, Suchi, Linka, and Plunder. Argos's App Store rewrites are the remaining ✅ blocker for submit-readiness.

### 2026-05-20T17:43:54-07:00 — UVI 10-day forecast disclaimer call; "if Apple doesn't need it, we don't either" pushback

Delivered: `.squad/decisions/inbox/plunder-uvi-forecast-disclaimer-call.md`. Verdict: **⚠️ borderline → rewrite required.** The user's premise (Apple-as-analogue) is regulatorily wrong; the user's preference (don't add visual noise) is honorable and can be met without giving up the safety boundary. Summary:

**Apple Weather is not a valid analogue.** Apple shows raw atmospheric UVI in a general-weather product — no personalization layer, no health claim. Our app computes a body-keyed output: Fitzpatrick × SPF × UVI → personalized burn window today, personalized category band per day on the forecast. **The personalization layer that makes us valuable is the same layer that puts us inside the rule set Apple sits outside of.** Cite — the line that draws it: FDA 2019 *General Wellness Policy* §III.B (intended-use claim limited to general wellness; foreseeable cohort use creates a disclosure obligation); MDCG 2019-11 §3.3/§4.3 (software performing calculation on individual data is MDSW; lifestyle-and-well-being software is not, *provided intended use is unambiguously communicated to the user*). The L3 reach-back is the unambiguity mechanism. Drop it and we weaken our own MDSW-exclusion argument.

**Foreseeable-misuse doctrine attaches even with Wheeler's §5.4 hedge** (no burn-time minutes on out-days). The category band itself is read inside our app's "your skin" context. For an Asha-class user (isotretinoin, tetracyclines, fluoroquinolones, thiazides, sulfonamides, amiodarone, voriconazole, methotrexate, St John's Wort; post-laser / post-peel / post-retinoid-initiation per D-2026-05-19-007), a "low UVI Thursday" forecast cell is foreseeably read as "Thursday is safe to plan exposure" — and we know (Wheeler says so in writing) that UVI is not the controlling variable for that cohort. Foreseeable-misuse doctrine (FDA 2019 §III.B.2; FTC §5 deceptive-omission line; emerging health-app duty-of-care case law e.g. *Babylon Health* MHRA 2020, US period-tracker class actions 2021–2023) requires the warning to be reachable from the result surface, not buried in Settings.

**Prior decisions bind by their plain terms; cannot be implicitly satisfied.** D-2026-05-19-007 elevated photosensitization from "edge copy" to "safety boundary" — a safety boundary is a property of the product, not of a single screen. D-2026-05-19-013 explicitly required *visibility from the result surface*, not attestation, not Settings-buried. The forecast surface is a NEW result surface that produces personalized outputs. By the plain terms of both decisions, it requires its own re-surfacing of the L3 affordance. The L1 cover fires only at cold launch (won't survive into a forecast-only-tap user journey); L2 footer is reused and inert (gets us "not medical advice" but not the cohort reach-back); the verdict-card L3 doesn't render on the forecast tab. Therefore explicit re-surfacing is needed.

**Minimum compliant surface — the actual answer Iris implements:**

- One chevron-disclosure affordance at the foot of the forecast card. Label: *"Is this estimate for me?"* — the existing locked L3 string. **Zero new copy.** Deep-links to the existing About `notForMe` anchor where the D-2026-05-19-007 photosensitizer enumeration already lives.
- Wheeler's drafted §5.3 paragraph relocates from "on-card seed copy" → "About destination paragraph." Same wording, different surface. The drug-class enumeration stays at the destination, never on the forecast card.
- L2 footer is reused unchanged. No second footer line. No yellow box. No banner. No modal. No inline drug-class enumeration on-surface.
- One sentence Iris can ship from: *"Forecast surface gets the existing 'Is this estimate for me?' chevron, pointed at the existing About anchor. No new copy. No new surface. Same L3 pattern, ported."*

**Why this honors the user's underlying preference:** the user is right that Apple's clean visual rhythm is the design target. The L3 chevron is one secondary-color line — strictly smaller visual surface than Wheeler's full §5.3 paragraph proposal, strictly larger than zero. The Apple-restraint visual cadence is preserved; the safety-boundary obligation is preserved. Both honored.

**Skill extracted:** `.squad/skills/big-player-analogue-compliance-test/SKILL.md` — generalizable protocol for evaluating "regulator X doesn't make big-player Y do this, so we shouldn't have to either" arguments. The pattern is recurring: it surfaced once on WeatherKit attribution (D-2026-05-19-003/004 — same fallacy, Apple's own attribution scheme was the right answer there), and now on the forecast disclaimer. It will recur. Codifying.

**Open attorney escalations updated:** E9 (new) — confirm with outside counsel that the L3-chevron-only pattern on a numeric-suppressed (day-6+) burn-time-suppressed (all out-days) forecast surface holds general-wellness intended-use under FDA 2019 + MDCG 2019-11. Pre-counsel read: yes. Confirm-before-submit, not a build-blocker.

**Cross-check with Wheeler and Suchi:**
- Wheeler (WI-7 §5.3): wording preserved; relocation from on-card to About destination preserves scientific intent. Wheeler to confirm the relocation.
- Suchi ("non-negotiable" Asha-reachability): the chevron-on-result-surface pattern is precisely the architecture Suchi was protecting. Substance honored; form minimized. Asking Suchi to confirm.

**No code modifications by this proposal** — Scribe to merge; Kwame to wire the existing L3 NavigationLink into the forecast view; Iris owns chevron placement.

### 2026-05-21T00:55:49Z — Round 2 verdict: Apple analogue is not valid; L3 chevron pattern required

- **Apple Weather is not a valid analogue.** They display atmospheric scalar (UVIndex from NOAA / meteorological model). We personalize: UVI × Fitzpatrick × SPF → BurnTime (health-adjacent output). Personalization triggers regulatory scope (MDCG 2019-11 §3.3, FDA foreseeable-misuse, FTC § 5 deceptive-omission, MDR Annex VIII Rule 11, UK MHRA 2022).
- **Photosensitized cohort is foreseeable:** D-2026-05-19-007 enumerates them (isotretinoin, tetracyclines, fluoroquinolones, thiazides, sulfonamides, amiodarone, voriconazole, NSAIDs, phenothiazines, methotrexate, St John's Wort; conditions: lupus, porphyrias, XP, post-procedure). Silence on the forecast surface while they use the picker is non-compliant.
- **Minimum compliant surface:** Reuse existing L3 chevron ("Is this estimate for me?") at foot of forecast card, navigating to About anchor where photosensitizer enumeration already lives. Zero new copy required — reuses locked D-2026-05-19-011 string. This pattern satisfies both D-2026-05-19-013 and D-2026-05-19-007 by their plain terms on the forecast surface.
- **Reusable diagnostic created:** `.squad/agents/plunder/skills/big-player-analogue-compliance-test/SKILL.md` — for future "if big-player-X doesn't have to, why should we?" challenges. Checklist: (1) same output type? (2) same user cohort? (3) same risk profile? If any mismatch, analogue fails.
- **Handoffs:** Card footnote copy finalized (Iris); picker sheet body hedge ("Estimated; UV forecasts can be off by ±1–2 UVI beyond a few days"); day-8–10 picker refusal message; photosensitization re-disclosure on picker sheet (carry from D-2026-05-19-013 wording).
- **Orchestration log:** `.squad/orchestration-log/2026-05-21T00:55:49Z-plunder.md`

