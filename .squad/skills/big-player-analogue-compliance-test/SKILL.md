# Skill: Big-Player Analogue Compliance Test ("If Apple doesn't have to, why should we?")

**Author:** Plunder (Legal & Compliance Reviewer)
**First captured:** 2026-05-20T17:43:54-07:00 — UV Burn Timer 10-day forecast disclaimer call
**When to use:** Any time a team member argues against a legal/compliance requirement by citing what a much larger product (Apple, Google, Amazon, an incumbent in the same vertical) does or does not do. The argument shape is *"big player X doesn't carry this obligation; we are smaller; therefore we shouldn't either."*

This is one of the most common — and most plausible-sounding — fallacies in health-adjacent / safety-adjacent / regulated-domain product work. It almost always feels reasonable at first hearing. It is almost always regulatorily wrong, but in a specific, diagnosable way. This skill is the diagnostic.

---

## Why the argument feels right (the seductive part)

1. **Regulatory enforcement is risk-proportional.** Regulators *do* prioritize larger targets. So the empirical observation "Apple gets away with X" can be true.
2. **Big players have armies of lawyers.** If their lawyers signed off on the silence, the silence must be defensible.
3. **Following an incumbent's pattern is the conservative-feeling choice.** Doing what the market leader does looks like prudence, not recklessness.
4. **The user-facing benefit (less clutter, cleaner UI) is real.** The team member proposing the argument is usually right that their product would be better-feeling without the disclosed item.

The seduction is what makes this argument worth a structured diagnostic — not a reflexive "no."

---

## The three questions that decide it

Ask each, in order. The argument survives only if all three answer "yes."

### Q1. Is the big player's product **the same product** in the regulatory sense?

The regulatory frame keys on **intended use** and **what the product actually does to the user's data**, not on category, name, or how it looks. Two products can share a category and a UI pattern and sit in different regulatory classes.

Diagnostic prompts:

- What is the **intended-use claim** of the big player's product? What is ours?
- Does the big player's product **personalize on the user's body / physiology / condition**? Do we?
- Does the big player produce a **raw scalar** (information display) or a **computed output** (algorithmic recommendation)?
- Is the big player's product **inside or outside** the regulatory definition of "medical device software" / "general wellness device" / equivalent?

Worked example — UVI display:
- Apple Weather displays UVI as one atmospheric scalar among hundreds. No personalization layer. Intended use: general meteorology. **Outside** MDR/MDCG MDSW scope; outside FDA SaMD scope.
- UV Burn Timer takes UVI × Fitzpatrick × SPF → personalized burn window. Intended use: tell the user how long until their skin reddens. Personalization layer is the product's entire differentiator. **Inside** the FDA "General Wellness" §III.B intended-use frame and the MDCG 2019-11 §3.3 "calculation on individual data" frame.

If Q1 = "no, different regulatory product" → the argument fails immediately. Stop and tell the team why. Do not proceed to Q2.

### Q2. Is the big player's **user population** the same as ours in the foreseeable-misuse dimension?

Even when two products *are* in the same regulatory class, the foreseeable cohort can differ. Foreseeable-misuse doctrine (FDA 2019 General Wellness §III.B.2; FTC §5 deceptive-omission line; emerging health-app duty-of-care case law) attaches based on **who the product is foreseeably used by**, not just what the product does.

Diagnostic prompts:

- Does the big player **know about** (via their own research, public data, App Store reviews, support tickets) a high-risk cohort within their user base?
- Does **our** research identify a high-risk cohort? (For us: D-2026-05-19-007's photosensitization list, surfaced by Suchi's r/Accutane / r/lupus research.)
- Is the high-risk cohort *more* likely to be in our user base because our product **selects for them** (e.g., a UV-burn-timer self-selects sun-sensitive users)?

If our cohort is documented and the big player's is not — or if the same cohort exists for both but ours is concentrated by self-selection — the foreseeable-misuse obligation is **independent** of the big player's posture. Tell the team explicitly: *"This obligation attaches to us regardless of what [big player] does."*

### Q3. Is the **specific surface** under discussion one where a reasonable user would read our output as a personalized recommendation?

Even within the same product, surfaces can sit on different sides of a line. A general "about this app" page sits differently from a per-day per-user numeric output.

Diagnostic prompts:

- On *this surface*, does the output appear inside the product's personalization context? (For us: yes — the forecast surface lives inside a UV-burn-timer app whose entire UI signals "your skin.")
- Could a reasonable user read the output as actionable for their own body? (For us: yes — a "low UVI Thursday" forecast cell is read by the user as "Thursday is okay for me.")
- Is the surface the **first** surface in a user journey, or a deep-funnel surface that's only reached after several prior screens that already carry disclosure? (Forecast surface can be jumped to directly from the home tab — it's a top-level surface, not a deep-funnel one.)

If all three answer "yes," the surface needs its own disclosure. The fact that another surface in the product already has one does **not** propagate (unless your architecture forces every user through that other surface every time, which is rare).

---

## What to do when the argument fails (the constructive half)

Compliance reviewers blocking with "no" are useless. The job is to find the **minimum compliant surface** that satisfies the rule while honoring as much of the user-facing-benefit half of the argument as possible.

The pattern that works almost every time:

1. **Identify which existing in-product affordance already carries this disclosure burden elsewhere.** (For us: the L3 "Is this estimate for me?" chevron, locked in D-2026-05-19-011.)
2. **Re-use it on the new surface verbatim.** No new copy. No new affordance type. The same component, ported.
3. **Push the verbose enumeration / long-form copy off-surface** to the destination of that affordance (About page, in-app help, expandable disclosure). The on-surface affordance is small; the off-surface destination carries the weight.
4. **Quantify the visual delta** for the team: *"The minimum compliant surface is one chevron line. Strictly smaller visual surface than the original proposal. Strictly larger than zero. Apple's restraint visual cadence is preserved; the safety-boundary obligation is preserved. Both honored."*

The phrasing matters. "Both honored" is the resolution; not "compromise" — compliance is a product strength, not a tax.

---

## When the argument **does** survive all three questions

It happens. Document it and don't block. If all three Qs are "yes" — same regulatory product, same cohort exposure, same surface logic — then the big player's pattern is a valid analogue. Cite the specific reasons it survives all three (not "Apple does it") and ship.

Examples of survival in this project's history:
- **WeatherKit attribution lockup format (D-2026-05-19-003/004):** Apple's attribution requirements were the canonical answer for our attribution surface because we *are* using Apple's data and Apple *is* the regulator on that question. Q1/Q2/Q3 all "yes." Adopted verbatim.

Examples of failure (this skill's namesake case):
- **10-day UVI forecast disclaimer (this case, 2026-05-20):** Q1 fails — Apple Weather doesn't personalize on the body; we do. Different regulatory product. Argument did not survive Q1.

---

## Voice / how to deliver the verdict

The team member making the argument is rarely wrong about everything. They are usually right about the visual-noise concern and wrong about the regulatory equivalence. Deliver both halves:

1. **Lead with what they got right.** "The Apple-Weather comparison is the right instinct on visual noise."
2. **Name the specific reason it fails.** "...and the wrong instinct on regulation, because Apple's UVI display is an atmospheric scalar in a general-weather product — they're not personalizing it to anyone's skin."
3. **Give them the minimum compliant surface that honors the visual-noise concern.** "What we can borrow is Apple's clean visual rhythm. One chevron — already locked, already approved — ported to the forecast card. No new copy."
4. **Both halves honored.** This is the closing line. "Apple's restraint; our differentiator's safety boundary. Both honored."

Do not say "legal says no." Say which section of which rule applies, why our product sits inside it, and what specific affordance closes the loop.

---

## Citations / regulatory anchors (general; specifics vary by case)

- **FDA, *General Wellness: Policy for Low Risk Devices*** (Sept 2019) — §III.A (low-risk threshold), §III.B (intended-use limitation), §III.B.2 (foreseeable-use doctrine).
- **FDA, *Policy for Device Software Functions and Mobile Medical Applications*** (Sept 2022 rev.) — §IV.A (apps not regulated as devices but with foreseeable health use).
- **IMDRF SaMD WG/N12FINAL:2014** — risk categorization matrix (significance of information × state of healthcare situation).
- **EU Regulation 2017/745 (MDR)** — Annex VIII, Rule 11 (decision-support software classification).
- **MDCG 2019-11** (Guidance on qualification and classification of software under MDR) — §3.3 (calculation on individual data → MDSW), §4.3 (lifestyle / well-being software exclusion).
- **UK MHRA *Software and AI as a Medical Device Change Programme*** (2022 update) — §2 (Qualification, adopts MDCG 2019-11 logic).
- **Apple *App Store Review Guidelines*** — §1.4.1 (Medical apps), §1.4.3 (drug-dosage / clinical-judgment apps).
- **FTC Act §5** — deceptive-omission doctrine; commonly applied to health-app cohort-silence cases.

---

## Anti-pattern (what not to do)

- ❌ Reflexively block the argument with "we're not Apple."
- ❌ Cite an entire regulation by name without naming the section.
- ❌ Demand the maximum compliant surface when a minimum one will do.
- ❌ Treat the user's visual-noise concern as a frivolous request.
- ❌ Pattern-match on category (both "weather apps") instead of intended use.

## Pro-pattern (what works)

- ✅ Walk Q1 → Q2 → Q3 in writing, with the specific rule cited at each step.
- ✅ Lead with what the team member got right (visual-noise concern is honorable).
- ✅ Reuse an existing in-product affordance verbatim; push verbose copy to its destination.
- ✅ Quantify the visual delta in concrete terms ("one line, secondary color, chevron, no new copy").
- ✅ Close with "both honored" — the visual-noise concern and the safety boundary, simultaneously.

---

## Confidence

**Medium-high.** The pattern has surfaced twice in this project (WeatherKit attribution — survived; forecast disclaimer — failed) and is structurally identical to fallacies that recur across health-adjacent / safety-adjacent product work. The Q1/Q2/Q3 frame and the "minimum compliant surface + verbose copy at destination" resolution will generalize. Specific rule citations will vary by domain.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
