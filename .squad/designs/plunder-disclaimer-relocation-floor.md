# Disclaimer-Relocation Regulatory Floor — Main-Screen Minimum-Surface Memo

**Author:** Plunder (Legal & Compliance)
**Date:** 2026-05-21T04:18:05Z
**Requested by:** Yashas (Coordinator)
**Addressee:** Iris (UI/UX redesign, working in parallel); copy: Suchi, Wheeler, Gaia, Scribe
**Scope:** Main-screen relocation of (a) `reapplicationFooter` ("Cover up if skin reddens…"), (b) `photosensitizationBannerLabel` ("Meds or photosensitive conditions? Learn more"), (c) location-permission rationale repetition.
**Status:** Proposed — regulatory floor below which the app changes classification. Iris designs above this line; she cannot design below it.

---

## §1 Classification stake

**UV Burn Timer sits in the "general-wellness / informational" classification today.** It is not a medical device under any of: FDA SaMD (per the 2019 *General Wellness: Policy for Low Risk Devices* §V.B; reaffirmed in 2024 *Clinical Decision Support Software* guidance §III), EU MDR Annex VIII Rule 11 (per MDCG 2019-11 §3.3 / §4.3), or UK MHRA *Software and AI as a Medical Device* guidance (2023 §3.4, "Crafting an Intended Purpose"). What keeps us inside that classification — and outside the SaMD Class IIa bucket that would require notified-body review, post-market surveillance, and CE/UKCA marking — is **three load-bearing properties of the user-facing surfaces**: (1) the result-surface number is **persistently framed as informational, not measurement** ("Not medical advice"); (2) **safety-mitigation guidance** (reapply, cover-up, escalate on reddening) is **reachable from the result surface, not buried** (FDA 2019 §III.B.2 foreseeable-misuse doctrine; FTC §5 deceptive-omission); (3) the **photosensitive cohort has a targeted-disclosure path from every result surface** (D-2026-05-19-007 ratified; MDCG 2019-11 §3.3 "intended use unambiguously communicated"). Relocate any of these three off the main screen *with no equivalent reach-back* and we cross the line. Relocate them while preserving a one-tap reach-back from a visible affordance and we remain on the safe side.

---

## §2 Per-item verdict

### 2.1 `reapplicationFooter` — "Cover up if skin reddens. Reapply sunscreen at least every 2 hours regardless of timer. Informational only. Not medical advice. Skin response varies."

**Triage:** ⚠️ **Borderline — partial relocation OK, full removal NOT OK.**

This block does **four jobs**. They have different regulatory weights, so the relocation must be analyzed clause-by-clause. Treating the block as monolithic is the failure mode.

| # | Clause | Job | Regulatory anchor | Minimum surface |
|---|---|---|---|---|
| A | "Cover up if skin reddens." | Safety-mitigation action (biological-feedback override) | FDA 2019 §III.B.2 (foreseeable-misuse mitigation); App Store §1.4 (Physical Harm) | One-tap reachable from result surface; trigger visible without scrolling |
| B | "Reapply sunscreen at least every 2 hours regardless of timer." | Safety-mitigation action + model-assumption disclosure | FDA 21 CFR §352.52(c)(2) (sunscreen reapplication labeling at point of use); App Store §1.4 | One-tap reachable from result surface; trigger visible without scrolling |
| C | "Informational only. Not medical advice." | Intended-use claim / SaMD classification anchor | FDA 2019 General Wellness §V.B.2 (claims-in-context); MDCG 2019-11 §3.3 ("unambiguously communicated"); UK MHRA 2023 §3.4 | **Persistent on every result surface** OR visible-affordance label that opens to it in one tap |
| D | "Skin response varies." | Variance / individual-applicability hedge | Reinforces C; FTC §5 (avoids implicit certainty claim) | Co-locate with C |

**What can move:**
- Sentences A + B can move to an info sheet reachable from a visible main-screen affordance, **provided** (i) the trigger affordance is visible without scrolling on the result surface, (ii) the sheet opens without a network call (offline-safe), (iii) the round trip is ≤ 1 tap.
- Sentences C + D can also move to the same sheet, **provided** the visible affordance carrying them is labeled with at least one of: "Informational only," "Not medical advice," or an equivalent SaMD-anchor phrase (the current `disclaimerLinkLabel = "Informational only. Not medical advice."` already qualifies).

**What cannot move:**
- We cannot delete the persistent intended-use anchor (C) from every result surface AND simultaneously hide it behind ≥ 2 taps. That combination crosses MDCG 2019-11 §3.3 "unambiguously communicated" and FDA 2019 §V.B.2 "claims-in-context." Pick one: persistent ambient text, OR a visible affordance whose label carries the claim.
- We cannot put A + B exclusively in About → Citations → bottom-of-page. The path from result-surface → safety-mitigation must be ≤ 1 tap. App Store §1.4 will reject a sunscreen timer that hides "reapply every 2 hours" behind 3 navigation steps.

**Today's surface** (`PersistentFooter` in `.safeAreaInset(edge: .bottom)`) carries C + D as ambient text AND offers an "Informational only. Not medical advice." link to About. **That is over-floor.** The floor allows either:
- **Pattern P1 (preserve ambient):** keep one short ambient line on the result surface (e.g., the existing 4-sentence block, or a compressed variant — see §4) and drop the redundant link;
- **Pattern P2 (preserve affordance):** drop the ambient block, keep a visible labeled affordance whose label carries the intended-use claim ("Informational only. Not medical advice." or equivalent) and which opens a sheet containing A + B + the long-form hedge in one tap.

Either P1 or P2 is on the safe side. **Mixing — removing ambient block AND removing the labeled affordance — is below the floor.**

### 2.2 `photosensitizationBannerLabel` — "Meds or photosensitive conditions? Learn more"

**Triage:** ✅ **CAN move off the main screen — under one condition.**

**What it is regulatorily.** This banner is the persona-keyed *targeted-disclosure trigger* for the photosensitive cohort (Asha — P4). The trigger exists because UV-index alone is not the controlling variable for that cohort (isotretinoin, tetracyclines, fluoroquinolones, thiazides, sulfonamides, amiodarone, voriconazole, methotrexate, NSAIDs, phenothiazines, St John's Wort; lupus, vitiligo, albinism, porphyrias, XP; post-laser/peel/retinoid; pregnancy — enumerated at D-2026-05-19-007 and rendered in `aboutEstimateApplicability` at `ProductCopy.swift` line 119). The legal load is FDA 2019 General Wellness §III.B.2 foreseeable-misuse + MDCG 2019-11 §3.3 unambiguous-communication, satisfied today by the **three-surface visibility pattern** (D-2026-05-19-011): L1 cover, L2 footer, L3 result-surface affordance.

**The redundancy.** The main screen currently carries **two** L3-tier surfaces pointing to the same About anchor: the yellow banner at the top of the scroll (`photosensitizationBanner`, line 247 of `AppViews.swift`) AND the verdict-card chevron labeled `mainVerdictCaveatLinkLabel = "Meds + conditions can shorten this. Learn more"` (line 835). Per D-2026-05-19-011 the floor is **one** L3 affordance reachable from the result surface. Two is over-floor.

**Verdict.**
- ✅ **The yellow banner can be removed from the main screen entirely**, *provided* the verdict-card chevron (`mainVerdictCaveatLinkLabel`) remains visible from the result surface and continues to deep-link to the `aboutEstimateApplicability` anchor.
- 🚫 **Both cannot be removed.** If Iris's redesign also relocates `mainVerdictCaveatLinkLabel` off the main screen, then either (a) the banner must stay, or (b) a new single-tap result-surface affordance landing on the same About anchor must be introduced. **At least one L3-tier surface on the main screen, always.** This is the plain-language floor of D-2026-05-19-007 + D-2026-05-19-011 + D-2026-05-19-013 + D-2026-05-19-014. The chevron pattern itself is detailed in `.squad/skills/persona-keyed-disclaimer-visibility/SKILL.md` (Linka's skill, inherited).
- ⚠️ Surfaces where the targeted-disclosure trigger **already appears and must continue to appear regardless of main-screen design** (these are NOT substitutes for the main-screen L3 — they are additive): (i) L1 first-launch full-screen cover (the `photosensitizerDisclaimerLine` row + the `see About` inline link, already wired at line 1188 / 1196 of `AppViews.swift`); (ii) skin-type picker footer (`skinTypePickerFooter` already enumerates "photosensitizing medications" — line 115 of `ProductCopy.swift`); (iii) Settings → skin-type sheet (`skinTypeSettingsFooter` — line 117); (iv) About → `aboutEstimateApplicability` anchor as the L4 destination.

**Why one main-screen affordance is non-negotiable.** The L1 cover fires only at cold launch. The persona we are protecting (Asha) is in a *foreseeable-misuse state on every session* — she changes medication, recovers from a procedure, picks up an antibiotic course. She must be able to reach the photosensitizer enumeration from the result surface *during the session*, not only at app start. Buried in Settings is the failure mode FDA 2019 §III.B.2 and FTC §5 deceptive-omission both reach. See also `.squad/skills/big-player-analogue-compliance-test/SKILL.md` (the "Apple doesn't do this" failure pattern; same logic applies to "Settings is good enough" claims).

### 2.3 Location-permission rationale repetition

**Triage:** ✅ **Reducing to a single rationale + single OS prompt is fully compliant. No regulatory floor below that.**

Location permission is **Apple-HIG-regulated, not health-regulated**. None of FDA SaMD, EU MDR, or UK MHRA speak to permission-prompt cadence. Apple's controlling rules:

- **HIG → System Experience → Privacy → Permissions:** "Request permissions only when needed and explain why. Don't keep asking after a person declines."
- **App Store Review Guideline 5.1.1 (Data Collection and Storage):** "Apps must respect the user's permission settings and not attempt to manipulate, trick, or force people to consent to unnecessary data access." Repeated in-app re-prompts after denial = §5.1.1 violation territory.
- **iOS Core Location:** `requestWhenInUseAuthorization()` is **OS-deduplicated** — once the user has chosen Allow/Deny/Allow Once, the system handles the state. The app cannot re-trigger the native prompt. Sending the user to Settings is the only legitimate path after denial.

**Verdict:** ✅ Show the rationale card **once** (the existing `LocationRationaleCard` gated by `!locationPromptGate.hasAcknowledgedRationale` at line 92 is correct in shape). After the user either acknowledges or denies, the rationale card should not re-appear within the same session. In the denied-state empty state, `locationDeniedEmptyState` already directs the user to Settings — that's the correct HIG-pattern terminus. **The current implementation is at-floor or above-floor.** If Iris/Kwame want to reduce the number of distinct surfaces that mention location, no regulatory rule blocks that. (The privacy-policy disclosure of the rounded-coordinate retention — `locationPrivacyLine`, `cacheRetentionLine` — must remain in About, but is independent of the main-screen rationale UI.)

---

## §3 Iris's constraints — the boundary she designs within

These are the lines she cannot cross. Within them, she has complete authority on placement, visual prominence, ordering, and typography.

- **C1.** The main screen must carry **at least one visible affordance** that either (a) contains the phrase "Informational only" / "Not medical advice" / an equivalent SaMD-anchor in its label, OR (b) reveals that phrase within one tap from a visible trigger. Reachability metric: visible-without-scrolling on first paint of the result state.
- **C2.** The main screen must carry **at least one visible affordance** that opens (within one tap, no network call) a destination containing both: (i) "Cover up if skin reddens" or an equivalent biological-feedback-override action, AND (ii) "Reapply sunscreen at least every 2 hours" or an equivalent reapplication-cadence reminder. **Both clauses, same one tap.** They may be in the same sheet as C1.
- **C3.** The main screen must carry **at least one visible affordance** (the L3 chevron pattern, per the inherited Linka skill) that opens (within one tap, no network call) the `aboutEstimateApplicability` anchor in About — i.e., the photosensitizer / condition / procedure / pregnancy enumeration. **This affordance is allowed to be the same affordance as C1/C2 if the destination sheet contains all three.**
- **C4.** Constraints C1–C3 can be merged into **one** main-screen affordance whose destination sheet contains the safety guidance + intended-use claim + photosensitizer enumeration. One affordance is the minimum; more is permissible. **Zero affordances on the main screen is below the floor.**
- **C5.** Destination sheets opened by C1/C2/C3 must (i) open without a network call, (ii) be dismissable with a standard iOS gesture (swipe down or "Done"), (iii) be screen-reader-accessible (existing `accessibilityIdentifier` + `accessibilityHint` patterns suffice).
- **C6.** The L1 first-launch full-screen cover (`DisclaimerCover`) stays as-is. It is the once-per-session deep-content surface and is regulatorily independent of the main-screen redesign. Do not weaken L1 in pursuit of main-screen simplicity.
- **C7.** Re-attestation cadence is unchanged: skin type stays `@State`-only (Donatello M7 / D-2026-05-19-007); L1 re-fires on every cold launch. Nothing in the relocation alters that contract.
- **C8.** Location rationale: a single in-session presentation is the floor. After acknowledge or deny, do not re-present within the same session. (No regulatory pressure to make it more prominent than today; Iris may compress it visually.)
- **C9.** The Apple Weather attribution lockup (D-2026-05-19-003 / -004) must remain adjacent to any surface displaying WeatherKit data. This is unaffected by disclaimer relocation but flagged here because Iris's redesign touches the same scroll region.
- **C10.** Strings: if a clause is relocated to a sheet, the *string itself* does not need to change (see §4 for the exceptions). If a clause is removed from a surface where it was the only carrier of a regulatory load, the carrier must move to the new surface, not disappear. **Substance is the floor; form is Iris's call.**

---

## §4 Rewrites — where relocation requires re-wording

Most clauses survive the move unchanged. Two need attention.

### 4.1 If `reapplicationFooter` is split across surfaces

If Iris splits the four-clause block so that the safety-mitigation guidance (A + B) goes into a destination sheet while a compressed phrase stays on the main screen as the affordance label, the on-main-screen label must still carry **C** (the intended-use claim). The current `disclaimerLinkLabel = "Informational only. Not medical advice."` is exactly the right form and length. No rewrite needed if Iris reuses it.

If Iris wants a single shorter label that collapses C + the trigger semantics ("Tap for safety guidance" alone is **below floor** — it loses C), use one of these locked variants. Each carries C in the label itself:

- ✅ `"Informational only. Not medical advice."` (current `disclaimerLinkLabel`, ratified)
- ✅ `"Estimate only — not medical advice. Safety tips →"` (new variant — adds a destination cue; carries C; ≤ 8 words)
- ✅ `"Not medical advice. Tap for sun-safety tips."` (new variant — front-loads C; ≤ 7 words)
- 🚫 `"Sun-safety tips"` alone (loses C; below floor)
- 🚫 `"Learn more"` alone (loses C and is generic; below floor and below Apple §1.4.3 specificity expectation)

### 4.2 If the destination sheet inherits A + B from the relocation

The current full string is fine to drop into the sheet verbatim. One small tightening when it lives in a sheet rather than an ambient footer: split the safety action from the disclaimer hedge so a screen reader doesn't fuse them.

- **Current (ambient line):** *"Cover up if skin reddens. Reapply sunscreen at least every 2 hours regardless of timer. Informational only. Not medical advice. Skin response varies."*
- **Sheet variant (proposed — same words, two stanzas):**
  > **If the timer disagrees with your skin, your skin is right.**
  > Cover up if your skin reddens. Reapply sunscreen at least every 2 hours regardless of the timer.
  >
  > UV Burn Timer is informational only and is not medical advice. Skin response varies.

  The bolded line is a new framing, not a new claim; it preserves regulatory substance while making the sheet readable as guidance rather than fine-print. Wheeler should sign off on the framing as scientifically accurate (it is — biological feedback overrides any model). If Wheeler objects, drop the bold line and use the two stanzas as plain paragraphs.

- ⚠️ Do **not** add new factual claims to the sheet during relocation. No new science, no new categories of medication, no new condition list beyond what `aboutEstimateApplicability` already contains. Relocation is a UI move, not a content expansion.

### 4.3 `photosensitizationBannerLabel` — no rewrite if it is removed

If the banner is deleted (and the L3 chevron `mainVerdictCaveatLinkLabel` stays), no rewrite is required anywhere. The chevron string is already locked under D-2026-05-19-011 / -013 and carries the targeted-disclosure load.

If the banner is moved rather than deleted (e.g., to the result-detail sheet), retain the string as-is. The wording is ratified.

---

## §5 What I'd want to see in the launch-ready version — open questions for outside counsel

None of these is a build-blocker. All five are confirm-before-App-Store-submit, not block-the-design-cycle.

- **E10 (new).** Confirm with outside US counsel that **collapsing C1 + C2 + C3 into a single main-screen affordance** holds the FDA 2019 General Wellness §V.B.2 "claims-in-context" reading. My read: yes, provided the affordance label carries the intended-use claim and the destination sheet carries the safety actions + photosensitizer enumeration. Cite the affordance label + the one-tap sheet contents as the "labeling" object for the §V.B.2 analysis. Pre-counsel verdict: safe. Confirm-before-submit.
- **E11 (new).** Confirm with EU counsel that **the same single-affordance pattern satisfies MDCG 2019-11 §3.3 "unambiguously communicated"** when paired with the L1 cover re-firing per cold launch. My read: yes, the L1 cover provides the unambiguous communication at session entry; the single result-surface affordance preserves it through the session. Pre-counsel verdict: safe.
- **E12 (new).** Confirm with App Store-experienced counsel that **Apple Review §1.4 (Physical Harm)** has not tightened on sunscreen-timer apps in the 2026 guideline cycle. The 2024 guideline language is the controlling text in our pre-counsel read; no signaled tightening at the 2026 WWDC review-board update.
- **E6 (carried forward, from 2026-05-19).** Disclaimer wording — full pass by outside counsel for the L1 cover body, the chevron label, the sheet body, the App Store description. No change from prior; relocation doesn't add a new claim, only redistributes existing ones.
- **E9 (carried forward, from 2026-05-21).** L3-chevron-only pattern under FDA 2019 + MDCG 2019-11 for personalized-output surfaces (the forecast tab specifically). Already pending confirmation. The disclaimer relocation does not change E9's posture; if anything, it tightens our position because the result-surface L3 is preserved.

---

## §6 Quick verdict summary (for stand-up)

| Item | Verdict | One-line floor |
|---|---|---|
| `reapplicationFooter` (full block) | ⚠️ Borderline — partial relocation OK | At least one main-screen affordance carries C ("Not medical advice"); destination opens A + B in one tap, no network. |
| `photosensitizationBannerLabel` (banner) | ✅ Can be removed | Provided `mainVerdictCaveatLinkLabel` (L3 chevron) stays visible from the result surface. Never both gone. |
| Location rationale repetition | ✅ Compress to one freely | Apple HIG floor: one rationale + one OS prompt; after denied, route to Settings. No health-regulatory pressure. |

---

## §7 Decisions respected / built on

- **D-2026-05-19-003 / -004** — Apple Weather attribution adjacency. Untouched by this memo; flagged in C9 because Iris's redesign sits in the same region.
- **D-2026-05-19-005** — $2.99 one-time wedge. Untouched; relevant only because "paid commercial app" sharpens the FDA / FTC posture relative to a free hobby app.
- **D-2026-05-19-007** — Photosensitivity is a safety boundary, not edge copy. **Honored.** §2.2 floor C3 is the direct expression of -007 on the redesigned surface.
- **D-2026-05-19-011** — L1/L2/L3/L4 three-surface visibility pattern. **Honored.** L1 unchanged; L2 may compress to an affordance (within the §2.1 floor); L3 preserved as the single main-screen chevron; L4 (About) unchanged.
- **D-2026-05-19-013** — Excalidraw user-flow canon (onboarding + main screen). The relocation will trigger a canvas update for the main-screen lane; Iris owns that follow-up.
- **D-2026-05-19-014** — Persona overlay annotations. P4 Asha row directly drives §2.2. P3 Tomás and P1 Greta are unaffected.

**No prior decision is overturned by this memo.** It tightens the operational floor below D-2026-05-19-011 (specifically: what "L2 footer" means once the surface can be a labeled affordance rather than ambient text) and codifies the redundancy diagnosis (banner + chevron = double L3; floor is one).

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
