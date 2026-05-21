# Skill: SaMD Minimum-Surface Checklist for Wellness Apps

**Author:** Plunder (Legal & Compliance)
**First captured:** 2026-05-21 — UV Burn Timer iOS, disclaimer-relocation review (`.squad/designs/plunder-disclaimer-relocation-floor.md`)
**Pairs with:** `persona-keyed-disclaimer-visibility/SKILL.md` (where disclaimers go), `big-player-analogue-compliance-test/SKILL.md` (why "the big app doesn't do this" arguments fail), `health-adjacent-citation-licensing-decision-tree/SKILL.md` (which sources you can cite).
**When to use:** Any time a designer or PM proposes relocating, compressing, or merging health-adjacent disclaimer copy off a result surface to "reduce visual noise." Use BEFORE the design ships, not after.

---

## The problem this skill solves

Disclaimer copy in a health-adjacent app is rarely a monolithic block. A single 3- or 4-sentence "disclaimer" often does multiple regulatory jobs at once, and **each clause carries a different minimum-surface obligation**. The recurring failure mode in main-screen redesigns is treating the whole block as one thing — either keeping it all (the screen feels paranoid) or moving it all (some clause silently drops below its regulatory floor and the app changes classification from general-wellness → SaMD).

The fix is a per-clause decomposition: name what each sentence is doing, name the rule that anchors it, name the minimum surface it must occupy. Then the relocation question becomes "which clauses can move and where?" rather than "do we keep this banner or not?"

---

## The four canonical disclaimer jobs

Most health-adjacent disclaimer blocks fold into these four. Tag each clause in the block with one of these labels before discussing relocation.

| Job | What the clause does | Regulatory anchor (US) | Regulatory anchor (EU/UK) | Minimum surface |
|---|---|---|---|---|
| **J1. Intended-use / SaMD-classification anchor** | "Informational only. Not medical advice." / "Estimate only, not a diagnosis." / "Not for clinical decisions." | FDA 2019 *General Wellness Policy* §V.B.2 (claims-in-context); FDA 2024 *Clinical Decision Support Software* §III | MDCG 2019-11 §3.3 + §4.3 ("unambiguously communicated"); UK MHRA SaMD 2023 §3.4 | Persistent on every result surface OR in the label of a visible affordance reachable in 0 taps. Cannot be ≥ 2 taps from the result surface. |
| **J2. Safety-mitigation action** | "Cover up if skin reddens." / "Stop if you feel chest pain." / "Reapply sunscreen every 2 hours." | FDA 2019 §III.B.2 (foreseeable-misuse mitigation); App Store §1.4 (Physical Harm); FTC §5 (deceptive omission) | MDR Annex I §10 (safety information); applicable national consumer-protection equivalents | Reachable in ≤ 1 tap from result surface, behind a visible affordance, no network call. |
| **J3. Targeted-cohort disclosure trigger** | "Meds or photosensitive conditions? Learn more." / "Pregnant? Consult your clinician." / "Pre-existing heart condition? See About." | FDA 2019 §III.B.2 foreseeable-misuse (cohort-specific); FTC §5 deceptive omission (material to a foreseeable subgroup) | MDCG 2019-11 §3.3 (intended-use scope); cohort-specific MDR Annex I requirements when applicable | At least ONE visible affordance on result surface that opens to the cohort enumeration in ≤ 1 tap. |
| **J4. Variance / individual-applicability hedge** | "Skin response varies." / "Results differ by individual." / "Model estimate; your body may differ." | Reinforces J1; FTC §5 (avoids implicit certainty / efficacy claim) | Reinforces J1 (MDCG 2019-11 §3.3) | Co-locate with J1; same floor. |

---

## The checklist — run this before approving any relocation

For every clause in the disclaimer block under review, answer all six:

- [ ] **1. Which job does this clause do? (J1 / J2 / J3 / J4)** If more than one, the clause is a load-bearing multi-tool; **split it before relocating**, not after.
- [ ] **2. What is the result surface for this app?** (The screen that displays the safety-critical value: a number, a recommendation, a verdict.) Relocation distance is measured from this surface, in taps and in network calls.
- [ ] **3. If relocated, where does it land?** Name the destination surface. "Settings → About → Citations" is ≥ 3 taps and is below floor for J2 and J3.
- [ ] **4. Does the relocation cross a network call?** If the destination sheet requires a network call to open (CMS-loaded, dynamic), it is **below floor** for J2 because the safety guidance is unreachable offline. Always-bundled is the floor.
- [ ] **5. Is there a visible affordance on the result surface pointing to the relocation?** If not, J1 / J2 / J3 dropped below floor — the user has no way to know the safety content exists. Affordance visibility = first paint, no scrolling required.
- [ ] **6. Does the affordance label carry J1 (the intended-use claim)?** If the affordance is the ONLY remaining main-screen carrier of J1, its label must contain "Informational only" / "Not medical advice" / equivalent. A generic "Learn more" label is below floor for J1.

If any check fails: do not approve the relocation. Either restore the clause to the original surface or strengthen the affordance.

---

## Worked example — UV Burn Timer disclaimer-relocation (2026-05-21)

**Input block:** *"Cover up if skin reddens. Reapply sunscreen at least every 2 hours regardless of timer. Informational only. Not medical advice. Skin response varies."*

**Per-clause tagging:**

| # | Clause | Job | Min surface |
|---|---|---|---|
| A | "Cover up if skin reddens." | J2 | ≤ 1 tap from result surface |
| B | "Reapply sunscreen at least every 2 hours regardless of timer." | J2 | ≤ 1 tap from result surface |
| C | "Informational only. Not medical advice." | J1 | Persistent on result surface OR in affordance label |
| D | "Skin response varies." | J4 | Co-locate with C |

**Relocation proposal:** move A + B off the main screen into a sheet, keep "Informational only. Not medical advice." as the link label.

**Checklist run:**
1. Jobs identified: A/B = J2, C = J1, D = J4. ✅
2. Result surface = `heroTimerCardView` on the main scroll. ✅
3. Destination = info sheet behind a labeled affordance, 1 tap. ✅
4. Network call? No — bundled string constants. ✅
5. Affordance on result surface? Yes — existing `disclaimerLinkLabel` link in `PersistentFooter`. ✅
6. Affordance label carries J1? Yes — label literally is *"Informational only. Not medical advice."* ✅

**Verdict:** ✅ Relocation approved. The block can split as proposed.

**Counter-example (would have failed):** Same proposal, but the affordance is a generic "Tap for safety tips" label. Check 6 fails — J1 no longer has a main-screen carrier. The classification anchor has dropped to ≥ 2 taps. Reject.

---

## Common failure patterns this skill catches

- **F1. The "Learn more" trap.** A generic affordance label moves J2 / J3 destination one tap away but loses J1 because the label is silent on intended use. Fix: relabel with J1 inline.
- **F2. The "About is good enough" trap.** Designer says "we'll add it to the About screen." About is typically 2–3 taps deep. Fine for J4 prose, fine for L4 long-form citations, **below floor for J1 and J2** on a result surface.
- **F3. The "Apple doesn't" trap.** "Apple Weather doesn't have all this — why should we?" Apple displays atmospheric scalar; we display a body-keyed personalized output. Different regulatory scope. (See `big-player-analogue-compliance-test/SKILL.md`.)
- **F4. The double-trigger trap.** Two main-screen affordances point to the same destination (e.g., yellow banner + verdict-card chevron). Often added defensively, then both are kept because "we might need one of them." Floor is ONE; remove the redundant one.
- **F5. The "compress the disclaimer" trap.** Designer asks to shorten the block to ≤ 6 words. Almost always loses J1 or J2 in the compression. Compress the AFFORDANCE label, not the destination sheet body.
- **F6. The dynamic-fetch trap.** Destination sheet fetches its body from a CMS so legal can edit without app review. **Below floor for J2** — safety content must be reachable offline. Keep safety strings as bundled constants; CMS-load only optional/marketing copy.

---

## Anti-pattern: do NOT use this skill for

- Marketing copy or App Store description text (different rules: ASA / FTC ad-substantiation, not SaMD).
- Onboarding / first-launch L1 cover content (covered by `persona-keyed-disclaimer-visibility` skill; L1 is its own regulatory object).
- Pure citation-attribution copy (covered by `health-adjacent-citation-licensing-decision-tree` skill).
- Privacy / data-handling copy (different regulatory regime — GDPR / CCPA / Apple App Tracking Transparency; route to Gaia / a privacy specialist).

---

## How this skill is enforced in our team

- Plunder runs this checklist on every PR or design proposal that touches disclaimer copy on a result surface.
- Iris (designer) reads the §3 "constraints" block of the relocation memo; the constraints are the operationalization of this checklist.
- Wheeler reviews J2 wording for scientific accuracy; Plunder reviews J1 / J3 / J4 for regulatory fit.
- Output artifact: a "regulatory floor memo" at `.squad/designs/plunder-<topic>-floor.md`. Example: `.squad/designs/plunder-disclaimer-relocation-floor.md` (2026-05-21).

---

## Confidence and provenance

- **Confidence:** medium-high. Applied successfully once (UV Burn Timer, 2026-05-21 — disclaimer relocation). The decomposition lens is general-purpose; the specific floor thresholds are FDA / MDR / Apple snapshots and will need a re-check on each new annual cycle.
- **Watch list:**
  - FDA 2024 *Clinical Decision Support Software* final guidance — re-check whether result-surface affordance language tightens.
  - EU MDR Rule 11 amendments — MDCG WG continues to issue interpretive guidance; verify §3.3 wording on each annual review.
  - Apple App Store Review Guideline cycle — §1.4 / §5.1.1 wording changes every WWDC; re-baseline annually.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
