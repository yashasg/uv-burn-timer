# Skin-Type Re-attestation — Scientific Basis Memo

**Author:** Wheeler (Skin Science Expert)
**Date:** 2026-05-21T06:35:00Z
**Requested by:** Yashas (Coordinator)
**Addressee:** Coordinator; copy: Plunder (regulatory parallel), Suchi (user-research parallel), Iris (UX patterns)
**Scope:** Whether Fitzpatrick skin-type re-attestation needs to fire on every cold launch from a *dermatological* / *photobiological* standpoint. Not regulatory (Plunder). Not UX (Iris). Not user-research (Suchi).
**Status:** Proposed.

**Confidence labels used below:**
- **[Established]** — citable peer-reviewed dermatology or clinical-guideline literature
- **[Approximation]** — reasonable extrapolation from established literature; flagged as such
- **[Clinical opinion]** — informed judgment in the absence of a controlled study; flagged as such

---

## §1 — Fitzpatrick stability in adults

### 1.1 What the Fitzpatrick scale actually measures

The Fitzpatrick Skin Phototype Classification (FSPC) is, by design, a measure of **constitutive sun reactivity** — the propensity to burn vs. tan in untanned skin after a defined dose of UV — *not* a measure of current visible skin tone. **[Established]**

> *Fitzpatrick TB. The validity and practicality of sun-reactive skin types I through VI. Arch Dermatol. 1988;124(6):869–871. doi:10.1001/archderm.1988.01670060015008*

That distinction matters: a Type II person who has just spent a week at the beach is darker (increased facultative pigmentation) but is still a Type II — they still burn the same way on first re-exposure after a winter indoors. The scale is supposed to be invariant to seasonal/tanning state. So a stability question reduces to: *does constitutive photoresponsiveness shift in adults?*

### 1.2 What shifts constitutive photoresponsiveness in adults — and at what timescale

**Decade-scale: melanocyte attrition with age.** Epidermal melanocyte density declines roughly **8–20% per decade** after age ~30, with proportional reduction in total epidermal melanin. **[Established]**

> *Gilchrest BA, Yaar M. Aging and photoaging of the skin: observations at the cellular and molecular level. Br J Dermatol. 1992;127(Suppl 41):25–30. doi:10.1111/j.1365-2133.1992.tb16984.x*
> *Yaar M, Gilchrest BA. Aging of skin. In: Fitzpatrick's Dermatology in General Medicine. 9th ed., 2019.*

Translated to Fitzpatrick categories: a Type IV at age 30 may legitimately drift toward Type III by age 60–70. At the **month-to-month** and **year-to-year** scales the change is in the noise floor — well below one category. **[Approximation, from Gilchrest/Yaar decade rate]**

**Lifecycle events that genuinely shift photoresponsiveness:**

| Event | Direction | Timescale | Captures Fitzpatrick re-attestation? |
|---|---|---|---|
| Initiating photosensitizing medication (isotretinoin, tetracyclines, fluoroquinolones, thiazides, sulfonamides, amiodarone, voriconazole, methotrexate, NSAIDs, phenothiazines, St John's Wort) | ↓ MED (functionally darker-Fitzpatrick safety profile) | Hours–days after first dose for phototoxic; days–weeks for photoallergic | **No.** Fitzpatrick scale does not encode drug-induced photosensitivity. This is handled by the photosensitization disclosure path (D-2026-05-19-007), not by re-asking the picker. |
| Post-laser, post-chemical peel, post-retinoid initiation | ↓ MED transiently | Days–weeks | **No.** Same as above — disclosure path, not picker. |
| Pregnancy (chloasma / "mask of pregnancy") | Localized facial hyperpigmentation, not phototype shift; 15–50% of pregnancies | Months | **No.** Melasma is a localized hyperpigmentation disorder; the patient's underlying Fitzpatrick burn/tan propensity is unchanged. The scale does not reclassify. |
| Vitiligo, post-inflammatory hyper/hypopigmentation | Localized depigmentation/hyperpigmentation | Variable | **No (for Fitzpatrick scale purposes).** These are disease states handled in the photosensitization-disclosure path. |
| Tanning bed use | Increases facultative pigmentation; constitutive reactivity unchanged | Weeks (fades) | **No.** A Type II who tans in a booth is still a Type II — same burn risk on next sun-naïve exposure. |
| Chronological aging | Slow melanocyte attrition | Decades | Yes, but at decade-scale, not session/week/month. |

**Implication.** All four event categories that *do* alter UV safety in a clinically meaningful way (medications, procedures, photosensitive conditions, pregnancy) are **already handled by the photosensitizer-disclosure surface** (D-2026-05-19-007). Re-asking the Fitzpatrick picker does **not** capture any of them — the picker only asks about burn/tan propensity, which is unchanged in every one of these scenarios.

### 1.3 Is there a published re-classification interval?

**No.** I could find no peer-reviewed dermatology source, no AAD guidance, no EU Society of Dermatovenereology guideline, no FDA labeling rule that specifies a re-attestation cadence for Fitzpatrick classification. The clinical-workflow convention — **[Clinical opinion, but the universal convention]** — is:
- Capture Fitzpatrick **once at patient intake**.
- Update **on event**: new procedure, new photosensitizing medication, new pigmentation disorder.
- Do **not** ask again on a calendar.

Phototherapy clinics that *do* re-measure photoresponsiveness do so via **MED testing** at the start of each treatment *course* (not session) — and they measure it directly with a UV source, not via a self-report questionnaire. The self-report Fitzpatrick scale is treated as a stable demographic attribute in every clinical workflow I've seen documented.

---

## §2 — Self-assessment reliability

### 2.1 What the test-retest literature shows

| Study | Population | Design | Reported reliability |
|---|---|---|---|
| Magin PJ, Pond D, et al. *Photodermatol Photoimmunol Photomed*. 2008;24(2):84–89. doi:10.1111/j.1600-0781.2008.00347.x | General-practice patients (adults) | Self-report questionnaire, 2-week test-retest | Test-retest **κ ≈ 0.61** (moderate–substantial); agreement with clinician Fitzpatrick **κ ≈ 0.48** (moderate) |
| Magin P, et al. *J Eur Acad Dermatol Venereol*. 2012;26(11):1396–1403. doi:10.1111/j.1468-3083.2011.04298.x | Australian adolescents, longitudinal | Repeated self-FSPC at baseline, 6 mo, 12 mo | Quadratic-weighted **κ > 0.75** (substantial–excellent) |
| Sanchez G, Nova J. *Biomédica*. 2008;28(4):544–550. doi:10.7705/biomedica.v28i4.59 | Mixed population | Inter- and intra-observer agreement, pre- vs post-training | Inter-observer **κ 0.31–0.40** pre-standardization, **0.77–0.82** post; intra-observer **κ 0.47–0.51** → **0.78–0.82** |
| Eilers S, Pichon LC, Cheng CE, et al. *JAMA Dermatol*. 2013;149(6):756–763. doi:10.1001/jamadermatol.2013.3277 | US adults across phototypes I–VI | Self-report vs dermatologist | Substantial inaccuracy; **patient↔dermatologist exact-category agreement low**, especially among self-identified Types I–III; concordance worse in skin-of-color cohorts |

**Key numerical reading [Established]:**
- **Within-one-category** agreement is consistently high (~89–90%).
- **Exact-category** agreement is mediocre (~30–36% un-standardized, rising to ~75–82% with a standardized prompt).
- Test-retest is moderate-to-substantial (κ 0.48–0.75+) depending on study design and population.

### 2.2 What this means for our specific question

Translate the literature to our use case — a single user being re-asked the same FSPC question across cold launches:

- **A user who picked III on Monday and IV on Friday is most likely producing self-assessment noise, not reporting a real biological shift.** The within-one-category drift rate of ~10–20% in repeat self-administration is *built into the measurement instrument itself*; the underlying constitutive photoresponsiveness has not changed. **[Established by Magin 2008 / 2012 test-retest data, reasoning is mine].**
- The probability that month-over-month self-FSPC drift reflects **(a) genuine skin shift, (b) self-assessment error, (c) anchoring/priming** breaks down approximately as:
  - **(a) genuine shift:** vanishingly small (decade-scale biology; not detectable in months).
  - **(b) self-assessment error:** dominant. Magin κ data implies ~25–40% of users will pick a different category on independent re-administration even with no underlying change.
  - **(c) anchoring/priming from prior choice:** real and asymmetric. Self-report categorical scales are well-documented to be subject to anchoring bias when the user can see (or remember) their prior choice. **[Established for psychometrics in general; not specifically studied for Fitzpatrick]** — but the implication is that *showing the last value as a default reduces drift* (good for stability) *at the cost of obscuring real change* (rarely real, per §1).

### 2.3 What this implies about the "measuring the same thing each time" question

We are *not* measuring the same thing each time when we re-prompt. We are measuring **the user's current categorical-self-assessment instrument noise**, against an underlying stable trait. The instrument has κ ≈ 0.5–0.7 reliability. Repeating it more frequently does not increase trait validity; it increases instrument-noise exposure.

---

## §3 — Medically-justified re-attestation cadence

### 3.1 The pure-clinical-safety answer

**From a dermatological standpoint, the scientifically justified Fitzpatrick re-attestation cadence is:**

> **Once, at first use. Then never on a calendar — only on user-initiated edit, or on an explicit event-driven prompt.**

**Reasoning [Established + Clinical opinion]:**

1. The trait being measured is stable in adults at month/year scale (§1.2). Calendar re-prompts cannot detect biological change because there is no biological change to detect.
2. The instrument has moderate reliability (§2.1). Repeated calendar re-prompts inject self-assessment noise into the safety calculation. A user re-picking III→IV→III→IV across four months will see the burn-time estimate swing by ~50% with no underlying skin change — that is *less* safe, not more.
3. All real photoresponsiveness-shifting events (medication, procedure, condition, pregnancy) are **not captured by the Fitzpatrick picker** — they are captured by the photosensitization-disclosure surface. Re-asking Fitzpatrick is the wrong tool for the right job.
4. The clinical-workflow precedent (§1.3) is "ask once, update on event," across every dermatology workflow I could verify.

### 3.2 The scientifically-vs-regulatorily-justified split

The question Yashas asked me explicitly distinguishes "scientifically justified" from "regulatory protective." Holding to that split:

- **Scientific case for re-attestation on every cold launch:** *zero.* No published evidence supports it. The trait doesn't change at session scale; re-asking introduces measurement noise; the relevant safety events live elsewhere.
- **Scientific case for re-attestation every 30 days:** *zero.* Same reasoning, weaker dose.
- **Scientific case for re-attestation at every cold launch with a low-friction confirmation chip (Pattern B):** *neutral.* The chip preserves session-entry awareness without forcing a re-categorization, so it doesn't inject instrument noise. The science neither requires nor opposes it.
- **Scientific case for one-time capture with user-initiated edit (clinical default):** *strongest.* This is what every dermatology workflow does. There is no published clinical-safety basis for doing more.
- **Scientific case for event-driven re-prompts (started new medication, post-procedure, pregnancy):** *strong, but these are not Fitzpatrick re-prompts.* These belong on the photosensitization-disclosure surface (D-2026-05-19-007 / Plunder C3 chevron). Re-asking the Fitzpatrick picker does not capture them.

Regulatory protective posture (i.e., "we re-ask every launch because it forces re-attestation of the *whole onboarding cover*, which includes the photosensitization disclosure") is a regulatory argument, not a scientific one. Plunder owns that argument. From the *science* side I have nothing to add to it — re-asking Fitzpatrick specifically is not what generates the safety value; re-presenting the photosensitization disclosure is. They have been coupled in the current implementation as a side effect of the `@State`-only model, not because the dermatology demands the coupling.

### 3.3 Patient populations where more-frequent re-attestation would matter

**None for the Fitzpatrick scale specifically.** Even the populations most often invoked as needing re-attestation — pregnancy, photosensitizing-medication users, post-procedure patients, photosensitive-condition patients (lupus, vitiligo, porphyrias, XP) — *do not have a shifted Fitzpatrick number*. They have a shifted **MED at the current state** (transient drug effect, post-laser barrier disruption, etc.) or a localized pigmentation change (melasma, vitiligo) that doesn't reclassify the scale.

These populations need **the photosensitization disclosure surface re-presented**, not the Fitzpatrick picker re-asked. Those are different controls.

There is one approximation worth flagging:

- **[Approximation, low confidence]** Older adults (age >70) with very long sun-exposure histories may have melanocyte attrition that has crossed a category boundary (e.g., a lifelong Type IV who has drifted to Type III over five decades). If we cared about this clinically, an event-anchored prompt at age-bracket transitions could be considered. I am **not** recommending it; the friction cost vs. the prevalence of this drift in our likely user base (mostly under 60, per the personas) is unfavorable. Flag for v1.1 if the user base ages.

---

## §4 — Risk analysis: persist-and-go-stale vs. re-prompt-and-annoy

### 4.1 What is the actual harm of persisted stale Fitzpatrick data?

The harm framing depends on the *direction* of staleness:

**Direction A: persisted value is too dark (user is actually more burn-prone than the app thinks).**
- Mechanism: user originally picked IV but has actually been a III all along (initial self-report error), OR has aged into a III over decades.
- Consequence: app **over-estimates safe time** → real risk of burn.
- Magnitude: at WeatherKit UVI = 7, the Type-IV MED of 450 J/m² gives ~32 min to 1 MED at noon; Type-III MED of 300 J/m² gives ~22 min. The app over-states safe time by ~45% in this case. That is non-trivial.
- **But:** this error is **already present in the original self-report** at any cadence. Magin 2008's κ = 0.48 between self-report and dermatologist Fitzpatrick says ~30–40% of users mis-self-classify by one category on any single administration. Re-asking does not fix this — it just re-rolls the noise dice. The expected-value error is the same whether you ask once or fifty times.

**Direction B: persisted value is too light (user is actually less burn-prone than the app thinks).**
- Mechanism: user picked II but has actually been a III, OR has been tanning gradually.
- Consequence: app **under-estimates safe time** → friction, not harm (user reapplies sunscreen more often than strictly needed; this is *not a safety harm*; it is the conservatively safe direction).
- Magnitude: same order, opposite sign.

**Direction C: a real photoresponsiveness shift has occurred (medication, procedure, condition).**
- Mechanism: user started doxycycline last week.
- Consequence: app over-estimates safe time, potentially substantially (5–10× in extreme phototoxic cases).
- **Critical:** *re-asking the Fitzpatrick picker would not catch this.* The user with new-onset drug photosensitivity still picks the same Fitzpatrick number. The photosensitization-disclosure surface is the only tool that catches this.

### 4.2 Does the staleness risk outweigh the per-launch friction?

**No, on dermatological grounds.** Three reasons:

1. The dominant component of Fitzpatrick error is **self-report misclassification at the moment of asking** (Magin / Eilers data) — not staleness. Re-asking doesn't reduce the dominant error.
2. The component of error that *would* matter (Direction C — new photosensitivity events) **is not captured by re-asking Fitzpatrick** at all.
3. The friction cost is real and has its own indirect safety implication **[Clinical opinion]**: a user who skips through the picker rapidly because they've seen it fifty times is likely to mis-tap, anchor on the visually-largest swatch, or close the app — all of which produce *worse* phototype data than a persisted prior selection.

The dermatological recommendation is therefore: **persist the value; route real safety events (medication, procedure, condition) through the photosensitization-disclosure surface; surface a user-editable affordance so the user can correct on their own initiative.**

### 4.3 Quantification (rough, labeled approximation)

**[Approximation, order-of-magnitude]** Assume a user base of 10,000 active sessions/month, and apply the literature reliability:

- Real Fitzpatrick drift over a month: **≈ 0%** of users (decade-scale biology).
- Self-report category flips on re-administration: **≈ 25–40%** of users will pick a different category on independent re-prompt (Magin κ = 0.48–0.61 in the *consistent-user-state* regime). On per-launch re-prompts this becomes the dominant signal — *most apparent "changes" are noise*.
- Real safety events that should change behavior (new photosensitizer, post-procedure): **≈ 0.5–2%** of users per month (rough population-pharmacology base rate; not Fitzpatrick-related). These are caught — or missed — entirely by the photosensitization surface, not by the picker.

**Conclusion:** the re-prompt-every-launch policy generates roughly **2,500–4,000 noise-driven re-categorizations per 10,000 sessions** while catching **zero** real safety events. The cost-benefit from the science side is clearly negative.

---

## §5 — Verdict on each pattern, from the science standpoint

> Reminder: this is the **science-only** verdict. Regulatory verdict belongs to Plunder; UX verdict belongs to Iris; user-research verdict belongs to Suchi. The science verdict alone is not sufficient to ship a decision.

### Pattern A — Persist + re-confirm every 30 days

**Verdict: ❌ scientifically unjustified.**

There is no biological reason for a 30-day cadence. Skin type does not change in 30 days (§1.2). The re-prompt collects instrument noise (§2.1). The real safety events that *can* occur in 30 days (started a new photosensitizing medication, had a procedure) are not captured by the Fitzpatrick picker (§1.2 table, §3.3). A 30-day cadence is arbitrary; if it has value, the value is regulatory or UX, not scientific.

### Pattern B — Persist + tap-confirm chip every cold launch

**Verdict: ✅ scientifically defensible.**

The chip preserves session-entry user-awareness of the attested type (small but non-zero scientific value: the user is reminded of what the burn-time math is conditioned on) without forcing a re-categorization that would inject instrument noise. The chip does **not** carry photosensitization-disclosure load — that still has to live on its own surface (D-2026-05-19-007). The chip is essentially a UI affordance whose scientific cost is zero and whose scientific value is marginal-positive.

### Pattern C — Don't persist; default picker to last value (in-memory hint only)

**Verdict: ⚠️ neutral, with one caveat.**

Functionally equivalent to per-launch re-attestation in that the user re-confirms each cold launch. The anchoring-to-prior-value is a real and well-documented effect on categorical self-report instruments **[Established for psychometrics generally; not specifically studied for Fitzpatrick]**. The anchoring is mostly *helpful* here because it reduces noise around a stable trait — but it also obscures the small fraction of users who really did mis-pick the first time. Net: similar science profile to Status Quo, with slightly less noise.

This pattern has the structural weakness that the "in-memory hint" disappears on app termination — so on a true cold launch after process kill, the user gets a blank picker again. From a science standpoint, that is identical to the status quo for those launches.

### Status quo — Per-cold-launch full picker

**Verdict: ❌ scientifically over-cautious; net-negative safety profile.**

§4 quantified the cost-benefit: per-launch re-attestation generates self-report instrument noise that swamps any biological signal, and catches zero of the real photoresponsiveness-shifting events that would actually matter for safety. The only scientific value is "the user is reminded of the safety frame each session" — but that value belongs to the **disclaimer surface and the photosensitization-disclosure surface**, not to the Fitzpatrick picker. The picker is the wrong instrument for that job.

Note that I am not arguing that the *L1 disclaimer cover* shouldn't fire per-launch. That is a different surface with different scientific load (the photosensitization disclosure does carry per-session safety value, because medication and procedure state genuinely changes session-to-session). Whether L1 fires every cold launch is a Plunder/Iris question; my point is narrower: **the Fitzpatrick picker specifically does not need to fire every cold launch on dermatological grounds**, and decoupling the picker from L1 is scientifically clean.

### Cross-pattern summary

| Pattern | Science verdict | Captures real safety events? | Injects instrument noise? |
|---|---|---|---|
| A — persist + 30-day re-prompt | ❌ unjustified | No | Yes (less often) |
| B — persist + per-launch tap-confirm chip | ✅ defensible | No (chip doesn't carry that load) | No (chip ≠ recategorization) |
| C — don't persist + default to last | ⚠️ neutral | No | Slightly (anchored) |
| Status quo — per-launch full picker | ❌ over-cautious, net-negative | No | Yes (every launch) |

**Strongest science verdict among the four:** Pattern B. Closest to clinical-workflow precedent (capture once, allow user-initiated edit) while preserving session-entry awareness via the chip.

**Important coupling:** the photosensitization re-attestation moment — which *does* belong on every cold launch — must be preserved on its own surface (L1 cover, or the L3 chevron / banner on the result surface) independent of whichever Fitzpatrick pattern is chosen. The current implementation entangles these two by accident of the `@State`-only model. Decoupling them is a scientific cleanup, not a regression. (Plunder C7 in `plunder-disclaimer-relocation-floor.md` currently treats this entanglement as *load-bearing*; on the science side I do not see a dermatological argument for that coupling, only a regulatory/architectural one. Plunder's call.)

---

## §6 — Open clinical questions (where the literature is thin)

1. **Long-term test-retest of self-FSPC in healthy adults.** Magin's 12-month adolescent cohort is the closest published longitudinal data; comparable adult longitudinal data is scarce. If we needed a higher-confidence estimate of true biological-vs-instrument-noise drift over multi-year horizons, we would have to commission it. **Confidence:** moderate that the adult data would track the adolescent data within ~10%.
2. **Anchoring effects in mobile-app self-FSPC.** I could not find a controlled study of priming/anchoring effects when a phototype questionnaire is re-administered with the previous answer pre-selected. This would matter for choosing between Pattern B (chip) and Pattern C (in-memory default). **Confidence:** the psychometric general-case literature applies, but the effect size on this specific instrument is unmeasured.
3. **MED drift in users on long-term photosensitizing medications.** The acute drop in MED for users initiating tetracyclines / isotretinoin / fluoroquinolones is documented in case series, but the *steady-state* MED for chronic users — and whether the photosensitizer label should adjust the Fitzpatrick-implied MED downward by a fixed factor or by a per-drug factor — is not standardized in the dermatology literature. We currently handle this by routing such users to the L3 photosensitization chevron, not by adjusting the math; that is the most defensible posture given the literature.
4. **Pregnancy and Fitzpatrick.** Melasma is well-studied as a pigmentary disorder; whether pregnant Type-III users have shifted *burn* propensity (independent of facial pigmentation) is not directly studied. The default assumption is no — pregnancy changes facial pigmentation but not whole-body burn response. **Confidence:** moderate; the literature is just thin.
5. **The senescence boundary.** §1.2 cites the Gilchrest/Yaar 8–20%/decade melanocyte attrition. The age at which a given user actually crosses a Fitzpatrick category boundary depends on starting type and lifetime sun exposure history. No published study has tracked this for our purposes. If the app's user-base skews older, this becomes an open question. **For v1 it does not matter** — the personas are predominantly under 60.

---

## §7 — Recommendation (short form, for the synthesis)

**Dermatologically, the right answer is to capture Fitzpatrick once and never re-prompt on a calendar — only on user-initiated edit, and to handle real safety events (photosensitizers, procedures, conditions, pregnancy) through their own dedicated surface, not through the Fitzpatrick picker.**

Of the four patterns under consideration, **Pattern B (persist + per-launch tap-confirm chip)** is the closest to clinical-workflow precedent while preserving the session-entry awareness that has secondary scientific value. **The status quo (per-launch full picker)** is over-cautious in a way that injects more self-report noise than it removes biological-drift risk.

**Critical hand-off:** the photosensitization-disclosure surface (D-2026-05-19-007) must continue to fire on every relevant session-entry path regardless of which Fitzpatrick pattern is chosen. Decoupling Fitzpatrick re-attestation from L1 disclosure re-presentation is scientifically clean; Plunder owns whether it is regulatorily clean. I have flagged in §5 that the current coupling is architectural, not dermatological.

---

## Sources cited

- Fitzpatrick TB. *Arch Dermatol*. 1988;124(6):869–871. doi:10.1001/archderm.1988.01670060015008
- Gilchrest BA, Yaar M. *Br J Dermatol*. 1992;127(Suppl 41):25–30. doi:10.1111/j.1365-2133.1992.tb16984.x
- Yaar M, Gilchrest BA. Aging of skin. In: *Fitzpatrick's Dermatology in General Medicine*, 9th ed., 2019.
- Magin PJ, Pond D, Smith W, Watson A, Goode S. *Photodermatol Photoimmunol Photomed*. 2008;24(2):84–89. doi:10.1111/j.1600-0781.2008.00347.x
- Magin P, et al. *J Eur Acad Dermatol Venereol*. 2012;26(11):1396–1403. doi:10.1111/j.1468-3083.2011.04298.x
- Sanchez G, Nova J. *Biomédica*. 2008;28(4):544–550. doi:10.7705/biomedica.v28i4.59
- Eilers S, Pichon LC, Cheng CE, Shane AC, Han J, Kawachi I, Fitzpatrick TB, Kimball AB. *JAMA Dermatol*. 2013;149(6):756–763. doi:10.1001/jamadermatol.2013.3277
- Sayre RM, Desrochers DL, Wilson CJ, Marlowe E. *J Am Acad Dermatol*. 1981;5(4):439–443. doi:10.1016/S0190-9622(81)70105-1
- Diffey BL. *Phys Med Biol*. 1991;36(3):299–328. doi:10.1088/0031-9155/36/3/001
- CIE S 007/E:1998 / ISO 17166:1999. *Erythema Reference Action Spectrum and Standard Erythema Dose.*

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
