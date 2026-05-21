# Skin-Type Persistence & Re-Attestation Cadence — Regulatory Floor Memo

**Author:** Plunder (Legal & Compliance)
**Date:** 2026-05-21T06:35:00Z
**Requested by:** Yashas (Coordinator)
**Addressee:** Yashas; copy: Donatello, Iris, Suchi, Wheeler, Gaia, Scribe
**Reopens:** D-2026-05-19-007 (operational anchor only); the rule under review actually originates with Donatello M7 + Raphael Art.9 — see §1.
**Status:** Proposed — re-examination of a previously-ratified constraint. I am proposing a floor *lower* than the status quo. Per Squad protocol, modification requires Yashas approval; nothing changes until the coordinator ratifies.

---

## §0 TL;DR

- The "skin type stays `@State`-only / L1 fires every cold launch" posture is **self-imposed defensive overkill**, not a regulatory floor. No regulation I can cite requires it.
- Persisting skin type to **`UserDefaults` (on-device, local-only)** does NOT change our SaMD classification under FDA, EU MDR, or UK MHRA; does NOT trigger Apple Health-category review under §5.1.1; and is permissible under GDPR Art.9 with explicit-consent legal basis (the act of selection itself qualifies).
- **iCloud sync** is a marginal step up (adds privacy-nutrition-label disclosure obligations but no classification change). **HealthKit write** is the only persistence option that materially changes our regulatory position — and we should not take it.
- The minimum defensible re-attestation cadence is **on first install + on material policy/methodology change + on user request**. Per-cold-launch re-attestation is permissible but not required.
- Recommended verdict on Yashas's four-pattern question:
  - Status quo (`@State`-only + L1 every launch): ✅ over-floor, defensible, but UX cost without regulatory payoff
  - **Pattern A** (UserDefaults + 30-day re-confirm modal): ✅ defensible
  - **Pattern B** (UserDefaults + one-tap confirm chip on cold launch): ✅ **RECOMMENDED** — meets the floor cleanly, preserves the per-session "user looks at their phototype before relying on the number" moment that the L1 cover currently serves, eliminates the friction Yashas is naming
  - **Pattern C** (in-memory cache only, lost on termination): ✅ trivially safe but barely improves UX
- The L1 `DisclaimerCover` does **not** have to fire on every cold launch. The C6 floor I ratified two hours ago was over-tight. I am revising C6 in §3 of this memo.

---

## §1 Re-reading D-2026-05-19-007 and the actual provenance of the `@State`-only rule

Yashas is challenging "C7: skin type stays `@State`-only (Donatello M7 / D-2026-05-19-007); L1 re-fires on every cold launch" — a constraint I ratified at 2026-05-21T04:18:05Z in `.squad/designs/plunder-disclaimer-relocation-floor.md`. The honest reading is that **C7 fused two distinct constraints from two different decisions and presented their conjunction as a single inherited floor.** It wasn't, and the conjunction was never separately defended.

### 1.1 What D-2026-05-19-007 actually says

Verbatim from `.squad/decisions.md` line 1703–1708:

> **D-2026-05-19-007 — Photosensitivity is a safety boundary, not edge copy**
> Decision: Keep the current strong disclaimer language and get Wheeler review on whether the verdict card needs an explicit note that photosensitizing medications or conditions can make the estimate overstate safe time.
> Rationale: Suchi surfaced direct persona evidence that Fitzpatrick/MED-based timing can understate risk for Accutane, lupus, vitiligo, and similar cases.

D-007 is a **disclaimer-wording / safety-surface visibility decision.** It says nothing about persistence. It says nothing about re-attestation cadence. It says nothing about `UserDefaults` vs `@State`. Its operational effect on the photosensitive cohort (Asha) is that she must always be able to *reach* the photosensitizer enumeration during a session — i.e., **L3 reach-back must exist on the result surface.** That's the C3 floor of my prior memo, which is separately defended and is not being re-opened.

D-007 has been *cited alongside* the `@State`-only rule (e.g., LAUNCH-PLAN.md line 293; decisions.md line 700) because the `@State`-only behavior **happens to deliver** an operational benefit relevant to D-007 — namely, that if the user closes and reopens the app after starting a new medication, the cold launch re-fires L1 and the photosensitizer disclosure flows again. But this is a *consequence* of the persistence model, not a *requirement* of D-007. Asha can re-attest equally well by tapping a one-tap chip, by re-confirming a 30-day modal, or by reaching the L3 chevron on her own — all of which exist regardless of the persistence model.

### 1.2 What Donatello M7 actually says

LAUNCH-PLAN.md line 293, verbatim:

> **Skin type + SPF:** `@State` SwiftUI properties only — **NOT `@AppStorage`, NOT `UserDefaults`**. This is the iOS-side enforcement of Donatello M7 + Raphael Art.9 special-category-data mitigation. Skin type and SPF must live in app memory only — equivalent to URL-hash in the web prototype.

Two named anchors: (a) **Donatello M7** ("zero-data architecture"), and (b) **Raphael Art.9** (GDPR Article 9 special-category-data mitigation). Neither is a citation to a regulation — both are *internal architectural postures* adopted as defense-in-depth.

- **Donatello M7** is a self-imposed product posture ("we don't store any data we don't have to"), not a regulatory citation. It has product-marketing value ("no account, no tracking" — see LAUNCH-PLAN.md lines 34, 98, 120, 134) and reduces attack surface, but is not anchored in a specific regulatory rule that prohibits local-only persistence of phototype data.
- **Raphael Art.9** refers to GDPR Article 9 (special-category data). Art.9 does **not** prohibit storage of health data — it requires a **legal basis**. Art.9(2)(a) "explicit consent" is one such basis, and the act of a user selecting their own Fitzpatrick type on a picker after seeing the L1 disclaimer is, on the conservative reading, explicit consent. (See §2.5 for the full GDPR analysis.)

### 1.3 Conclusion on §1

The `@State`-only rule is **defensive overkill stacked on top of a product-posture choice**, not a regulatory floor. C7 in my prior memo presented it as inherited canon; it is more accurately characterized as a product-design preference dressed in regulatory language. The honest move is to re-evaluate whether the product-design preference is worth the friction Yashas is naming, and to be explicit that we have regulatory latitude here, not regulatory constraint.

---

## §2 Per-jurisdiction analysis

### 2.1 FDA — General Wellness Policy (2019) §V.B + 2024 CDS Software guidance §III

**Question asked:** Does on-device persistence of Fitzpatrick skin type push us across the line from "general wellness software" to "device software function" (SaMD)?

**Answer: No.**

The 2019 General Wellness Policy carves out from device regulation any low-risk product whose intended use is general wellness ("maintaining or encouraging a general state of health"). The §V.B classification analysis turns on **(i) the intended-use claim**, **(ii) whether the product makes a disease- or condition-specific claim**, and **(iii) whether the risk profile is low**. None of these three triggers turn on whether the app remembers a user-entered phototype across launches.

The 2024 *Clinical Decision Support Software* guidance §III is consistent: the line between SaMD and non-SaMD CDS turns on whether the software's output is intended to drive a clinical decision and whether the clinician (or user) can independently review the basis for the recommendation. Persistence of user-entered inputs is not a factor in either analysis.

**Where persistence WOULD matter under FDA:** if the app *generated* a stored health-profile inference (e.g., "based on your repeated UV exposure pattern, you appear to be at elevated melanoma risk"), that would be a different analysis — that's a derived health claim, and storage of the derived claim could be evidence of intent to perform ongoing health monitoring (which would weigh toward SaMD classification). We don't do that. We store a single user-entered ordinal value (I–VI).

**Citation specificity:** FDA-2019-D-2745 (the General Wellness guidance) §V.B.2 examples include "products that track activity, sleep, weight, or diet to encourage a healthy lifestyle." Storage of those inputs is implicit in every example — Apple Health, MyFitnessPal, Strava, etc. all persist user-entered health-adjacent data without crossing into SaMD. The Fitzpatrick selector is on the same side of the line.

**Verdict:** ✅ No FDA pressure against persisting skin type to local storage.

### 2.2 EU MDR Annex VIII Rule 11 + MDCG 2019-11 §3.3 / §4.3

**Question asked:** Does Annex VIII Rule 11 (software providing information used to make decisions for diagnostic or therapeutic purposes = Class IIa) get triggered by persistence?

**Answer: No.**

Rule 11 turns on **intended purpose**, not on data persistence. MDCG 2019-11 §3.3 (the operative interpretive guidance for the medical-device-software borderline) frames the qualifier as "intended purpose unambiguously communicated to the user." §4.3 adds that lifestyle and well-being software is excluded **provided** intended purpose is non-medical.

The "unambiguously communicated" language is about *communication*, not about *cadence of re-affirmation*. MDCG 2019-11 nowhere requires that the intended-purpose statement be re-displayed on every session. It requires that it be communicated:

- at the point the user adopts the software (first install);
- whenever the intended purpose materially changes (a methodology change, a new disclaimer, a new safety claim);
- and reachable on demand during use.

A persistently-stored phototype with an always-reachable About screen carrying the intended-purpose statement, plus an L1 re-fire on first install and on material policy change, **satisfies §3.3 on its face.** Per-cold-launch L1 firing is over-floor under MDCG 2019-11.

**Where MDR Annex I §10 (information supplied with the device) bites:** this requires safety information to be "easily understandable" and reachable. The L3 chevron / About screen pattern (D-2026-05-19-011) satisfies §10 regardless of the persistence model.

**Verdict:** ✅ No EU MDR pressure against persisting skin type to local storage. ✅ No EU MDR requirement for per-cold-launch L1 re-fire.

### 2.3 UK MHRA *Software and AI as a Medical Device* guidance (2023) §3.4 "Crafting an Intended Purpose"

The MHRA guidance mirrors MDCG 2019-11 closely. §3.4 emphasizes that the intended purpose must be **persistently visible during clinical-feeling outputs**, but accepts that "persistent" is satisfied by a clearly-labeled affordance reachable from the output surface — i.e., the L3 chevron pattern we already operate, which is independent of the persistence model.

§3.4 does not address re-attestation cadence. MHRA Guidance 16 ("Off-label use") is the closest re-attestation analog, and it speaks to *re-confirming intended use when the user attempts an off-label action*, not to periodic re-firing of disclaimers.

**Verdict:** ✅ No MHRA pressure against persisting skin type. ✅ No MHRA requirement for per-cold-launch L1 re-fire.

### 2.4 Apple App Store Review Guideline 5.1.1 (Data Collection and Storage) + 1.4 (Safety)

**5.1.1(i) Data Collection and Storage:** Requires data minimization, user consent, and transparency about what is collected. *Encourages* but does not mandate ephemeral storage of health-adjacent inputs. Storing skin type to `UserDefaults` (local-only) with explicit user action triggering the storage is **compliant** under 5.1.1(i) provided the privacy policy and the App Store privacy nutrition label disclose the storage.

**5.1.1(ix) Health and Health Research:** Applies to apps conducting human-subjects research, gathering health information for medical research, or otherwise behaving as research instruments. **Does not apply to us.** A consumer estimation tool that lets the user save their input for convenience is not a research instrument.

**5.1.3 HealthKit:** Applies only if you read from or write to HealthKit. **Does not apply to us** (we don't use HealthKit). If we ever wrote skin type to HealthKit, §5.1.3 would trigger Health-category review under Apple's stricter rules — see §2.7.

**1.4 (Safety) / 1.4.1 (Drug Dosage Calculators) / 1.4.3 (False Information):** All concern the *advice given* and *reachability of safety information*, not data persistence. Our compliance with 1.4 is governed by the C1–C4 floors in my prior memo, not by persistence.

**Apple Data Use Disclosures (privacy nutrition label):** If we persist skin type to `UserDefaults`, we declare:
- Data type: "Health & Fitness → Other Health & Fitness Data"
- Linked to user: **No** (because we have no user account or identifier)
- Used to track: **No**
- Purpose: "App Functionality"

This is a *small additional declaration*, not a classification change. The nutrition label remains in the same posture as today (no third-party SDKs, no tracking, no account).

**Verdict:** ✅ No Apple App Store pressure against persisting skin type to `UserDefaults`. The privacy nutrition label needs a one-line update.

### 2.5 GDPR Article 9 — Special-Category Data

**Question 1: Is Fitzpatrick skin type "data concerning health" under Art.4(15)?**

The conservative reading is **yes**. Art.4(15) defines "data concerning health" as "personal data related to the physical or mental health of a natural person, including the provision of health care services, which reveal information about his or her health status." Recital 35 expands this broadly: "all data pertaining to the health status of a data subject which reveal information relating to the past, current or future physical or mental health status of the data subject." Fitzpatrick type indicates a person's UV susceptibility — a physical-health characteristic with risk-stratification implications. The EDPB and several national DPAs (CNIL, ICO) have applied Art.4(15) broadly in adjacent cases (skin-tone data, allergy data, dietary-restriction data when used for health purposes).

I'll treat it as health data. Defense-in-depth, and matches the Raphael Art.9 posture cited in LAUNCH-PLAN.md.

**Question 2: Does Art.9 prohibit storage?**

**No.** Art.9(1) prohibits *processing* of special-category data **unless** one of the Art.9(2) exemptions applies. The relevant exemption for a consumer wellness app is:

- **Art.9(2)(a) — Explicit consent.** "The data subject has given explicit consent to the processing of those personal data for one or more specified purposes."

The act of a user selecting their Fitzpatrick type on the picker, having just seen the L1 disclaimer that explains the app uses skin type to estimate burn time, is — on the conservative reading — explicit consent for the specified purpose of computing the estimate. To make this airtight, we should:

1. **Have the L1 disclaimer cover explicitly say** something like: "You will tell us your skin type so we can estimate your burn time. This stays on your phone."
2. **Make persistence a user-visible affirmative act.** This is the key design question. Two compliant patterns:
   - **(P-implicit)** Auto-persist on selection, with the L1 cover prominently stating the storage. Acceptable but not best practice for special-category data.
   - **(P-explicit)** Auto-persist on selection AND surface a Settings toggle ("Remember my skin type · ON") that the user can disable at any time. **Best practice.** This is what most GDPR-compliant consumer health apps do (Apple Health, Strava, MyFitnessPal all allow disabling persistence of sensitive inputs).
3. **Document the storage** in the privacy policy / About screen with the standard "what we store, where it lives, how to delete it" disclosure. The "how to delete it" is critical: a "Reset all data" affordance (already present in our app's About → Reset model, per Donatello-related work; confirm with Donatello) satisfies Art.17 right-to-erasure for local-only data trivially.

**Question 3: Does the data subject's location (EU vs. non-EU) matter?**

Art.3 territorial scope: GDPR applies to any app that "offers goods or services" to EU data subjects. We offer in the EU. Apply GDPR globally as the default — it's the strictest, and uniform UX is simpler than geo-gating.

**Question 4: Does on-device-only storage need a Data Protection Impact Assessment?**

DPIA is required under Art.35 when processing is "likely to result in a high risk to the rights and freedoms of natural persons," with §35(3)(b) explicitly listing "processing on a large scale of special categories of data." On-device-only storage of a single user's own self-entered phototype, never transmitted to a controller, is **not** "large-scale processing" by a controller — there is no controller-side aggregate. We are arguably not even a "controller" for the on-device storage; the data subject is in control. Conservative reading: DPIA not required for `UserDefaults`-local. Document the analysis in the privacy policy.

**Verdict:** ✅ GDPR Art.9 permits `UserDefaults` persistence of Fitzpatrick type with explicit consent. Best practice: a user-visible "Remember my skin type" toggle in Settings, defaulting to ON after the user selects a type the first time, with a clear off path.

### 2.6 GDPR delta for iCloud sync (CloudKit / `NSUbiquitousKeyValueStore`)

iCloud sync moves the storage from "purely on-device" to "transmitted across the user's own devices via Apple-controlled infrastructure." The regulatory delta:

- **Art.9 analysis: unchanged.** Same explicit-consent basis. The data still goes only to the same user's own devices.
- **Art.28 (processor):** Apple becomes a sub-processor for the iCloud transit/storage. Apple publishes a GDPR Article 28 data processing addendum for iCloud/CloudKit; relying on it is standard practice. Reference: Apple's "iCloud GDPR" published terms.
- **Privacy-policy disclosure:** We must disclose iCloud sync explicitly. Standard language exists ("If you have iCloud enabled, your skin-type selection syncs across your devices via Apple iCloud, encrypted in transit and at rest. We do not have access to this data.").
- **Privacy nutrition label:** Same "Health & Fitness → Other Health & Fitness Data" declaration. The "Linked to User" flag arguably flips to **Yes** because iCloud accounts are user-identifying. This is a defensible nutrition-label change but it weakens our "no account" marketing posture (LAUNCH-PLAN.md lines 34, 98).
- **App Store Review:** iCloud-using apps face mildly higher scrutiny under §5.1.1(v) ("Account Sign-In") but only if the app *requires* iCloud — and we wouldn't.

**Verdict:** ✅ iCloud sync is legally permissible but is a **marketing-posture step backward** (weakens the "no account" line). Not recommended unless there's product evidence (Suchi's lane) that users want cross-device sync for this app. I would not recommend iCloud sync absent a user-research finding.

### 2.7 HealthKit write — separate analysis, recommended against

Writing Fitzpatrick to HealthKit is a different regulatory animal:

- **Apple App Store §5.1.3 (HealthKit):** Apps that use HealthKit are subject to heightened review, including a documented purpose for each data type written, and prohibition on writing false or arbitrary data. Reviewers may push back on "wellness estimator" apps writing to HealthKit on the theory that the data isn't from an authoritative measurement source.
- **Apple HealthKit category implications:** Apps that write to HealthKit are typically reviewed as "Health & Fitness" category. **LAUNCH-PLAN.md line 281 + 299 expressly forbids Health & Fitness category** ("Utilities only — Karai recommendation; Donatello M5"). HealthKit write would force a category change.
- **FTC Health Breach Notification Rule (16 CFR Part 318), recently expanded (2024):** Applies to "vendors of personal health records" — interpreted in the 2024 amendment to include consumer health apps that collect identifying health info from individuals. Storing skin type in HealthKit pulls us closer to "PHR vendor" framing.
- **Donatello M7:** Explicitly prohibits HealthKit. Not re-opened by this memo.

**Verdict:** 🚫 HealthKit write is off the table. Not because GDPR or FDA prohibit it, but because Donatello M5/M7 already foreclosed it and the App Store category implications are unwanted. Out of scope for this memo. **Recommended floor: do not introduce HealthKit at any point.**

### 2.8 HIPAA — ruling it out

HIPAA (45 CFR Parts 160, 162, 164) applies only to "covered entities" — healthcare providers that transmit health information electronically in connection with a HIPAA-covered transaction (claims, eligibility checks, etc.), health plans, and healthcare clearinghouses — and to their "business associates." A direct-to-consumer iOS app sold on the App Store, with no relationship to any covered entity, is **not** a covered entity and is **not** a business associate. HIPAA does not apply. (The 45 CFR §160.103 definitions are explicit.)

The closest analog in the consumer-app space is the **FTC Health Breach Notification Rule** (already addressed in §2.7 in the HealthKit context). For local-only `UserDefaults` storage that never leaves the device, the HBNR's "breach of unsecured PHR-identifiable health information" trigger is structurally hard to reach — there's no transmission, no controller-side store, no aggregation. Conservative reading: HBNR exposure is minimal for `UserDefaults`-local.

**Verdict:** ✅ HIPAA does not apply. FTC HBNR exposure is minimal for local-only.

---

## §3 Verdicts on the four patterns

### Status quo — `@State`-only, no persistence, L1 fires on every cold launch

**Triage:** ✅ **Over-floor. Defensible but unnecessary.**

This is the safest possible posture. It also produces the UX friction Yashas is naming. The friction has no regulatory payoff. The only operational benefit is that if Asha (P4) starts a new medication and re-launches, she sees L1 again — but that benefit can be delivered by any of Patterns A, B, or C with appropriate L3-chevron reach-back during the session (which the C3 floor of my prior memo already requires regardless of persistence model).

**Regulatory citations:** Donatello M7 (self-imposed); Raphael Art.9 (precautionary, not required).

**Recommendation:** Move off this posture unless Suchi's parallel user-research finding indicates that returning users genuinely value the per-launch re-attestation moment.

---

### Pattern A — `UserDefaults` persistence + re-confirmation modal every 30 days

**Triage:** ✅ **Defensible. Conservative. Acceptable but heavier-than-needed.**

**What's compliant:**
- GDPR Art.9(2)(a) explicit-consent basis satisfied by initial selection + L1 framing.
- GDPR Art.5(1)(d) "accuracy" principle weakly supports periodic re-confirmation of stored personal data; 30 days is well within any defensible interpretation of "kept up to date." (90 days, annually, or even "never automatically" are also all defensible — Art.5(1)(d) does not specify cadence, only the duty to maintain accuracy.)
- FDA / MDR / MHRA neutral.
- App Store §5.1.1 neutral.

**What to watch:**
- The 30-day modal IS the friction Yashas is naming, just spread out. If users dismiss it 12 times a year, you've created a banner-blindness pattern that arguably *weakens* the safety-attestation function (FDA 2019 §III.B.2 reading — repeated dismissed prompts train the user to ignore safety surfaces).
- A 30-day cadence is **a product decision dressed in regulatory language**. There is no regulation that picks 30 days.

**Citation:** GDPR Art.5(1)(d) (data accuracy); FDA 2019 §III.B.2 (foreseeable-misuse — *caveat*: dismissed-prompt training is a documented anti-pattern in the FDA Human Factors guidance, AAMI/ANSI HE75:2009 §6.4).

**Verdict:** ✅ Compliant. Not my recommended pattern — risks the dismissed-prompt anti-pattern. If chosen, pair with a clear "you can change this anytime in Settings" message in the modal itself so users understand why they're being asked.

---

### Pattern B — `UserDefaults` persistence + one-tap confirmation chip on every cold launch

**Triage:** ✅ **RECOMMENDED. Best regulatory-and-UX fit.**

The pattern: on cold launch, the result surface shows something like *"Skin type: Fitzpatrick III · tap to change"* as a chip or affordance. The chip is the user's per-session glance-and-confirm moment — they see their stored value, they tap if it's wrong, they leave it alone if it's right. The full picker only appears on tap.

**What's compliant:**
- GDPR Art.9(2)(a) explicit-consent: satisfied by initial selection.
- GDPR Art.5(1)(d) accuracy: continuously satisfied — the user sees their stored value on every session and can correct in one tap.
- FDA 2019 §III.B.2 foreseeable-misuse: **strongly satisfied.** The chip is a visible per-session attestation moment without modal friction. Asha sees her stored phototype next to a chip that says "tap to change" — and if she just started Accutane, she has an obvious affordance to act on. The chip is itself the cohort-disclosure trigger if labeled well.
- MDCG 2019-11 §3.3 "unambiguously communicated": satisfied as long as the chip label or its adjacent surface carries the intended-use claim ("Informational only. Not medical advice." or the equivalent affordance from C1 of the prior memo).
- App Store §1.4 / §5.1.1: satisfied.

**Recommended chip label patterns** (any of these works):
- ✅ `"Fitzpatrick III · tap to change"` (basic; the surrounding intended-use claim from C1 carries the regulatory load)
- ✅ `"Skin type: III (tap to change). Meds or conditions can shorten this →"` (combines chip with the C3 L3 photosensitizer reach-back — elegant, single affordance carries two loads)
- 🚫 `"Skin type: III"` alone (no edit affordance — fails Art.5(1)(d) "kept up to date" in spirit; user can't see how to correct stored data)
- 🚫 `"III"` alone (loses the intended-use framing; reads like a measurement rather than a self-declared input)

**The Asha (P4) re-attestation question, resolved.** Suchi's parallel work is in her lane, but the regulatory analysis is: an always-visible chip on the result surface is a **stronger** photosensitizer-attestation surface than the cold-launch L1 cover, because L1 fires once-per-session and then disappears, while the chip is visible *every time the user looks at the burn-time number*. Asha taps the chip → picker reopens → photosensitizer hint surfaces again. This is **at-floor or above-floor** for D-2026-05-19-007's operational intent.

**Citation:** FDA 2019 §III.B.2 (foreseeable-misuse mitigation must be reachable from result surface — ≤ 1 tap); MDCG 2019-11 §3.3 (unambiguous communication preserved); GDPR Art.5(1)(d) (accuracy); App Store §1.4 (reachability of safety-relevant guidance).

**Verdict:** ✅ **This is the recommended pattern.** It resolves the UX friction Yashas named, preserves all regulatory functions, and arguably *improves* the photosensitizer-cohort safety posture relative to the status quo by making the attestation moment a per-session glance rather than a once-per-session modal.

---

### Pattern C — No persistence, in-memory cache only (lost on app termination)

**Triage:** ✅ **Trivially compliant. Negligible UX improvement.**

**What's compliant:** Everything. There is no persisted data at all. This is *more* defensive than the status quo from a privacy perspective (the in-memory cache also disappears on termination, just like `@State` does today). The only difference vs. the status quo is that within a single launch session, backgrounding and resuming preserves the selection — but the status quo already does that with `@State` since iOS preserves view state across `.background` ↔ `.active` transitions for most app lifecycles.

**Why it barely helps:** Yashas's complaint is specifically about **cold-launch friction** ("every time we open the app"). Pattern C does not address cold launch — the cache is gone, the picker re-opens, the friction remains. C is essentially the status quo with marginally better warm-resume behavior.

**Verdict:** ✅ Compliant. Does not solve the named problem. Not recommended as the answer to Yashas's UX question.

---

## §4 Recommended floor and recommended ceiling

### 4.1 Recommended floor (what MUST be true)

1. **Persistence model is the team's choice.** No regulation forces `@State`-only or any specific persistence mode. Any of: ephemeral, `UserDefaults`-local, or iCloud-synced is regulatorily permissible. **HealthKit is out (per Donatello M5/M7, unchanged).**
2. **If skin type is persisted to `UserDefaults` (or iCloud), the user must be able to:**
   - (a) See their stored value from the result surface in ≤ 1 tap (an edit affordance) — satisfies Art.5(1)(d) accuracy + FDA §III.B.2 reachability.
   - (b) Change their stored value from the result surface in ≤ 1 tap (the picker reopens) — satisfies Art.5(1)(d) accuracy.
   - (c) Delete their stored value from somewhere reachable in About / Settings (a "Reset stored data" affordance) — satisfies GDPR Art.17 right-to-erasure for on-device storage.
   - (d) Know that the value is stored (a single line in the L1 cover and/or About screen) — satisfies Art.13 information-to-data-subject + GDPR fair-processing principle.
3. **L1 `DisclaimerCover` must fire at minimum on:**
   - (i) First install / first launch (initial intended-use communication, MDCG 2019-11 §3.3).
   - (ii) Material change to disclaimer copy, calculation methodology, or sources (re-communication of intended use after change, MDCG 2019-11 §3.3 + UK MHRA §3.4).
   - (iii) Explicit user request from About ("Replay onboarding") — courtesy, not regulatory.
4. **L3 chevron on the result surface (photosensitizer reach-back) must remain visible during every session**, regardless of persistence model. This is C3 of the prior memo, separately defended, **not re-opened.**
5. **Privacy nutrition label / privacy policy** must accurately describe whatever persistence is chosen. If `UserDefaults`-local: one-line addition ("Other Health & Fitness Data — stored on device — not linked to user"). If iCloud: additional disclosure of sync.

### 4.2 Recommended ceiling (what is also permissible but not necessary)

1. Per-cold-launch L1 re-fire. **Permissible but not required.** Trades user friction against a marginal defense-in-depth posture. My recommendation: drop it.
2. Periodic re-confirmation modals (Pattern A). **Permissible but not required.** Trades user friction against Art.5(1)(d) accuracy reassurance. My recommendation: skip; rely on the always-visible Pattern B chip instead.
3. Settings toggle: "Remember my skin type" defaulting to ON. **Permissible and recommended-best-practice** for explicit-consent hygiene under Art.9. Low UX cost; high consent-quality benefit. **Recommended.**

### 4.3 What I'm revising from the prior memo

- **C6 (L1 cover stays as-is, fires every cold launch):** Revised. New C6 floor: **L1 cover fires on first install, on material policy/methodology change, and on user request. Per-cold-launch firing is permitted but no longer required by my floor.**
- **C7 (skin type stays `@State`-only):** **Withdrawn as a regulatory floor.** Replaced with a *product preference* that the team may keep or revise on UX grounds. If the team chooses to persist, the §4.1 list above is the new floor.
- All other constraints (C1–C5, C8–C10) **unchanged.**

### 4.4 If the team adopts Pattern B (my recommendation), what concretely changes

- **Add to floor:** Result-surface chip showing stored phototype, with tap-to-change affordance reaching the picker in 1 tap.
- **Add to floor:** Settings toggle "Remember my skin type" defaulting to ON; OFF reverts to per-session behavior.
- **Add to floor:** Reset affordance in About (Art.17 erasure).
- **Add to floor:** One-line privacy-policy / About disclosure of `UserDefaults` storage.
- **Update privacy nutrition label** before App Store submit.
- **Remove from floor:** Per-cold-launch L1 firing (becomes optional, not required).
- **Unchanged:** L1 firing on first install + material change; L3 chevron on result surface; all C1–C5 / C8–C10 constraints from prior memo.

---

## §5 Open attorney questions — confirm-before-submit, not block-the-design-cycle

These are genuinely-must-confirm-before-launch items. Same posture as E10–E12 from the prior memo: confirm-before-App-Store-submit, not block-the-design-cycle.

- **E13 (new).** Confirm with EU counsel that **the act of selecting a Fitzpatrick value on the picker, with the L1 cover having stated the storage purpose, constitutes "explicit consent" under GDPR Art.9(2)(a)** in the EDPB's current interpretation. My read: yes, especially with a visible "Remember my skin type" toggle providing affirmative control. **Confirm before submit, especially for EU launch.**
- **E14 (new).** Confirm with EU / UK counsel that **on-device-only storage of Fitzpatrick (`UserDefaults`, no transmission)** does **not** trigger Art.35 DPIA requirements. My read: no — there is no "large-scale processing by a controller" when the data lives on the data subject's own device. Confirm.
- **E15 (new).** Confirm with US counsel that the **2024 FTC Health Breach Notification Rule amendment** does **not** treat on-device-only storage as creating a "personal health record" under 16 CFR Part 318. My read: no — there is no aggregation, no transmission, no service-provider relationship. Confirm.
- **E16 (new).** If we adopt iCloud sync (Pattern B-iCloud variant — **not** my recommendation), confirm with US counsel that the marketing line "no account, no tracking" remains defensible under FTC §5 unsubstantiated-claim doctrine. My read: borderline. iCloud arguably *is* an account dependency, even though it's the user's own Apple ID. Recommend avoiding iCloud to preserve marketing-language posture.
- **E17 (new).** Confirm with Apple-experienced counsel that **dropping the per-cold-launch L1 re-fire** is not flagged by Apple Review under §1.4 as a degradation of safety surfaces for the sunscreen-timer category. My read: no, because the L3 chevron + the new Pattern B chip together preserve the safety-surface visibility more strongly than the dismissed-once L1 does. But this is a posture change reviewers may notice, so **confirm before submit**.
- **E10–E12** (from prior memo) carried forward unchanged.
- **E6, E9** (carried forward, from 2026-05-19 / 2026-05-21) — no change.

**Nothing in this memo is a build-blocker.** The persistence-model decision can be made today; the attorney items above can be confirmed in parallel with implementation and before App Store submit.

---

## §6 Decisions respected / built on / revised

- **D-2026-05-19-003 / -004** (Apple Weather attribution adjacency). Untouched.
- **D-2026-05-19-005** ($2.99 paid commercial app). Untouched; sharpens the FDA / FTC posture but does not affect persistence analysis.
- **D-2026-05-19-007** (Photosensitivity is a safety boundary, not edge copy). **Honored — and clarified.** D-007 is about disclaimer wording and L3 reachability for the photosensitive cohort; it does not speak to persistence. The operational link between `@State`-only and D-007's re-attestation behavior is **delivered equally well** by Pattern B's always-visible chip + L3 chevron. D-007's substantive concern (Asha can always reach the photosensitizer enumeration) is *strengthened*, not weakened, by Pattern B.
- **D-2026-05-19-011** (L1/L2/L3/L4 three-surface pattern). Honored.
- **D-2026-05-19-012** (no-default Fitzpatrick picker). **Reaffirmed and slightly tightened in context.** On first install, the picker still has no default — the user must select. On subsequent launches under Pattern B, the picker defaults to the stored value but is one tap away from any value, and the chip's "tap to change" affordance preserves the no-default *spirit* by making the stored value visible-and-mutable rather than silently-applied.
- **D-2026-05-19-013 / -014** (Excalidraw flow + persona overlays). The flow diagram will need a small update if Pattern B is adopted (the cold-launch lane shows the chip rather than the picker). Iris / Linka follow-up.
- **`plunder-disclaimer-relocation-floor.md`** (my prior memo, 2026-05-21T04:18:05Z). **C6 revised and C7 withdrawn as a regulatory floor** per §4.3 above. C1–C5, C8–C10 unchanged.
- **Donatello M7** (zero-data architecture). **Re-characterized, not overturned.** M7 remains the product-marketing-posture default ("no account, no tracking"). I'm noting that the iOS-side enforcement language in LAUNCH-PLAN.md line 293 ("`@State` SwiftUI properties only — NOT `@AppStorage`, NOT `UserDefaults`") is *stricter than M7 itself requires for skin type specifically*, given that `UserDefaults`-local with explicit consent is compliant with both M7's intent and Raphael Art.9. **Recommend Donatello and Yashas jointly decide whether to relax the LAUNCH-PLAN.md line 293 wording for skin type specifically**, while preserving the M7 ban on third-party SDKs, server transmission, and HealthKit.

**No decision is overturned by this memo without Yashas's approval.** Two are revised pending approval; one (D-007) is honored with a clarification of scope.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
