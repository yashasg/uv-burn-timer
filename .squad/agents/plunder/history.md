# Plunder — History (Summarized)

**Summarized on 2026-05-22T15:05:00Z** — archived entries before 2026-05-22 Loop-28 closure to history-archive.md.

### 2026-05-21T00:55:49Z — Round 2 verdict: Apple analogue is not valid; L3 chevron pattern required

- **Apple Weather is not a valid analogue.** They display atmospheric scalar (UVIndex from NOAA / meteorological model). We personalize: UVI × Fitzpatrick × SPF → BurnTime (health-adjacent output). Personalization triggers regulatory scope (MDCG 2019-11 §3.3, FDA foreseeable-misuse, FTC § 5 deceptive-omission, MDR Annex VIII Rule 11, UK MHRA 2022).
- **Photosensitized cohort is foreseeable:** D-2026-05-19-007 enumerates them (isotretinoin, tetracyclines, fluoroquinolones, thiazides, sulfonamides, amiodarone, voriconazole, NSAIDs, phenothiazines, methotrexate, St John's Wort; conditions: lupus, porphyrias, XP, post-procedure). Silence on the forecast surface while they use the picker is non-compliant.
- **Minimum compliant surface:** Reuse existing L3 chevron ("Is this estimate for me?") at foot of forecast card, navigating to About anchor where photosensitizer enumeration already lives. Zero new copy required — reuses locked D-2026-05-19-011 string. This pattern satisfies both D-2026-05-19-013 and D-2026-05-19-007 by their plain terms on the forecast surface.
- **Reusable diagnostic created:** `.squad/agents/plunder/skills/big-player-analogue-compliance-test/SKILL.md` — for future "if big-player-X doesn't have to, why should we?" challenges. Checklist: (1) same output type? (2) same user cohort? (3) same risk profile? If any mismatch, analogue fails.
- **Handoffs:** Card footnote copy finalized (Iris); picker sheet body hedge ("Estimated; UV forecasts can be off by ±1–2 UVI beyond a few days"); day-8–10 picker refusal message; photosensitization re-disclosure on picker sheet (carry from D-2026-05-19-013 wording).
- **Orchestration log:** `.squad/orchestration-log/2026-05-21T00:55:49Z-plunder.md`

Model assignment updated 2026-05-22T03:55: claude-opus-4.7-1m-internal (1M-context internal variant — for full-corpus photobiology consensus reviews).

---

## 2026-05-22 — Loop-27 review

**Scope:** Goal-4 (Expert approved) legal/compliance slice — Loop-27 HIG-only changeset (Iris playbook AV-1…AV-10, focus on AV-9).

**Verdict: ✅ PASS**

**AV-9 (`.sheet` → `.fullScreenCover` for AboutView inside DisclaimerCover, AppViews.swift line 1305):**

- **Disclaimer-acknowledgment flow unchanged.** L1 `DisclaimerCover` still wraps the entire surface with `.interactiveDismissDisabled(true)` (line 1315, post-change). The L1 body copy and the "I understand" CTA are not touched (AV-8 scaled only the `minHeight` via `@ScaledMetric`; no copy delta). The user still has exactly one path off the L1 gate: tap "I understand". No swipe-to-dismiss, no implicit acknowledgment, no new exit affordance.
- **About sheet is a peek, not an ack.** The About surface launched from L1 is a read-only L3/L4 reach-back (photosensitizer enumeration, "Is this estimate for me?" anchor, citations). Done button returns the user to the *still-undismissed* L1 disclaimer. The container change does not let the user skip, replace, or implicitly satisfy the L1 acknowledgment — it only changes the visual chrome of the secondary read.
- **Comprehension direction is neutral-to-positive.** `.fullScreenCover` gives the L3 reach-back content **more** screen real estate than a `.sheet` (which on iPhone is detent-limited and on iPad would float card-sized). For the photosensitized cohort (Asha-P4, D-2026-05-19-007), more space for the photosensitizer enumeration is a comprehension gain, not a loss. No regulatory regression under FDA SaMD 2019 §V.B, MDCG 2019-11 §3.3 ("unambiguously communicated"), MDR Annex VIII Rule 11, or MHRA SaMD 2023 §3.4.
- **HIG rationale (Iris) is consistent with compliance posture.** Sheets are for focused single tasks; the About surface is a scrollable document with its own nav title + Done button — `.fullScreenCover` is the HIG-correct container. Modal-presentation correctness reduces user-confusion-as-deceptive-omission risk (FTC §5), which is a marginal compliance positive.
- **No new copy, no new claim, no banned-phrase risk.** No `ProductCopy` strings touched. `auditCopySurfaces` posture unaffected.

**WI-plunder-m1 (Privacy Policy hosting) — still pending external action.**

- Status: draft stub at `.squad/files/privacy-policy.md` remains the source of truth; no hosted URL pinned yet. Owner: yashasg (external to iOS code scope). This is the silent Goal-4 blocker for App Store submission, especially EEA/UK (per Gaia loop-26 plan G-5).
- **Carrying forward to Loop-28** as the same item — no Loop-27 work moved it. Recommend Loop-28 either (a) close it by pinning a hosted URL + updating `ProductCopy.aboutPrivacy` substring pin, or (b) explicitly defer with a dated parking note so it does not silently drift.

**New legal/compliance gaps surfaced by Loop-27: none.** HIG-only changes (scaled metrics, container modality, touch-target frames) do not touch claim copy, citation surfaces, disclaimer wording, source attributions, or any of the L1–L4 disclosure surfaces. No new inbox entry written.

**Open attorney gates carried forward unchanged:** E10–E17 (skin-type persistence + disclaimer-relocation floor) remain pre-submit gates. WI-plunder-m1 (hosted Privacy Policy URL) remains the lone external-action blocker on Goal-4.

**Pairings:** Iris (AV-9 author) — concurrence on container choice. Linka (disclaimer placement) — no surface relocation occurred; no action. Wheeler — no science/citation copy changed.

---

## 2026-05-22: Loop-28 closure — No new compliance gaps; carry-forward on Privacy Policy URL

**Plunder execution:** 4 Kwame WIs reviewed for copy/claim/citation regressions. None found. HIG-only changes (scaled metrics, container modality, Dynamic Type frames) do not touch L1–L4 disclosure surfaces, disclaimer wording, safety-action copy, or attribution. SwiftLint strict: 0 violations post-merge. WI-plunder-m1 (hosted Privacy Policy URL) remains the silent Goal-4 blocker and carries forward unchanged. Carry-forward hardware-gated sign-offs (WI-loop-28-B: iris-contrast-qa-checklist.md, iris-launch-readiness-checklist.md remain blank).

