# Plunder — History

## Summary (as of 2026-05-22T02:58:03-07:00)

**Role:** Legal & compliance reviewer; ensures health-adjacent features meet regulatory boundaries (FDA, EU MDR, UK MHRA, GDPR, FTC, App Store).

**Major work streams completed:**
1. **Skin-type persistence reversal (2026-05-21 06:35Z):** Traced `@State`-only rule to defensive overkill, not regulatory floor. Approved UserDefaults persistence under FDA 2019 §V.B, EU MDR, GDPR Art.9. Minimum re-attestation cadence: first install + material change + user request (not per cold launch). Recommended Pattern B (UserDefaults + one-tap confirm chip on cold launch). C6/C7 memos revised; 5 open attorney gates (E13–E17) pending before App Store submission.

2. **Disclaimer-relocation regulatory floor (2026-05-21 04:18Z):** Established floor below which app crosses from general-wellness → SaMD/Class IIa. Per-clause regulatory-load decomposition: reapplication-action (movable), safety-action (movable), intended-use/SaMD-classification anchor (must stay on result surface or visible affordance label), variance hedge (co-locates with anchor). Minimum-surface logic: at least one main-screen L3 affordance for photosensitive cohort. Created skill: `samd-minimum-surface-checklist-wellness-apps/SKILL.md`. 3 open attorney gates (E10–E12) pending; no build-blockers.

3. **UVI forecast disclaimer compliance (2026-05-21 00:55Z):** Apple analogue rejected as invalid (Apple = atmospheric data only; we = personalized health data). Foreseeable-misuse doctrine attaches despite Wheeler's out-day suppression. Minimum compliant surface: reuse existing L3 chevron ("Is this estimate for me?") at forecast-card foot, navigating to About anchor where photosensitizer enumeration lives. Zero new copy. Created skill: `big-player-analogue-compliance-test/SKILL.md`.

**Skills created:** 3 reusable diagnostic patterns (big-player-analogue-compliance-test, samd-minimum-surface-checklist-wellness-apps, constraint-provenance-audit).

**Current blockers:** 5 attorney confirm-before-submit gates (E13–E17) for App Store readiness. No code build-blockers. Wheeler's brief shippable after gates close. Convergence on legally-defensible science + citation posture achieved across Wheeler, Suchi, Linka, and Plunder.

---

## Detailed History

### 2026-05-22T02:58:03-07:00 — Model rename + orchestration batch

Coordinator directive: `claude-opus-4.7-xhigh` → `claude-opus-4.7`. Fallback is now codified. Plunder model preference unchanged (claude-opus-4.7 for complex compliance + legal reasoning).

---

### Prior Session Entries (Compressed)

**2026-05-21 Session Summary:**
- Loop 1 (06:35Z): Skin-type persistence floor re-examination. LAUNCH-PLAN §9 rule reversed from regulatory requirement to product preference. Approved UserDefaults persistence + Pattern B recommendation (chip on cold launch). 5 attorney gates opened.
- Loop 2 (04:18Z): Disclaimer-relocation floor established. Per-clause regulatory-load decomposition. Minimum surface: at least one main-screen L3 affordance. 3 attorney gates opened.
- Loop 3 (00:55Z): UVI forecast compliance verdict. Apple analogue invalid. L3 chevron required on forecast surface. Big-player-analogue-compliance-test skill extracted. 1 attorney gate opened.
- Loop 0 (prior): Photosensitivity declared safety boundary. L1/L2/L3/L4 three-surface visibility pattern locked.



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
