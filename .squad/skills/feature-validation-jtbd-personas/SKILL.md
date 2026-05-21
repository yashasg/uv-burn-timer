---
name: "feature-validation-jtbd-personas"
description: "A six-section template for evaluating a PM-proposed feature against an existing persona inventory before any design or engineering work begins. Forces the User Researcher to convert vague proposals into a verdict (approve / approve-with-conditions / reject) backed by JTBD-match, JTBD-mismatch, competitor friction, cognitive-risk, and edge-case-persona analysis. Resists feature-cargo-culting where 'a competitor has it' becomes the unstated justification."
domain: "user-research, product-scope, jtbd, feature-validation, persona-research, cognitive-load-analysis"
confidence: "medium"
source: "earned — UV Burn Timer 10-day UVI forecast validation (Suchi, 2026-05-20, `.squad/decisions/inbox/suchi-uvi-10day-forecast-validation.md`). Generalized from a single application; structure is portable but n=1 in confidence."
---

## Context

Use when:
- A PM, designer, or stakeholder proposes a feature that references a competitor's pattern ("the iOS Weather app has a 10-day forecast — let's do that").
- The team already has a documented persona inventory with verbatim quotes and JTBD framing — *this skill does not work without that prior input*.
- The decision the team needs is not "how do we build it?" but **"should we build it, and if so under what conditions?"**

This skill resists three common failure modes:
- **Cargo-culting** — copying a competitor's surface without copying the JTBD that made it work for them.
- **Feature-list-driven scoping** — adding a feature because the spec said to, without re-checking against personas.
- **Single-persona validation** — approving the feature because it serves the primary persona, without surfacing the safety-load-bearing or edge-case personas it might silently harm.

Pair tightly with:
- The team's existing persona-screen-matrix work (the inventory this skill validates against).
- The team's existing decision-archive (so prior research that overlaps with the proposal can be cited, not re-discovered).
- A scope owner (Lead/Architect/PM) who will *act* on the verdict — this is not a research-for-the-archive exercise.

## Patterns

### The six sections (in order)

The template is non-negotiable in **order**, because the order forces the researcher to find evidence *for* the feature before they find evidence against it. Reverse-order writeups consistently anchor toward rejection.

1. **JTBD match** — for each persona in the inventory, what specific job would this feature be hired for? Quote the persona verbatim where possible. Use three sub-buckets:
   - **High-match:** feature directly closes a JTBD that the current product leaves open.
   - **Medium-match:** feature is nice-to-have but not load-bearing for the persona.
   - **Low-match:** feature adds no value over what the persona already gets.
   - **Dangerous-match** *(this is the surprising bucket)*: feature *looks* like a fit but actually misleads the persona. This bucket is the most important output of the section — it's where the next two sections (mismatch, cognitive risk) come from.

2. **JTBD mismatch** — what jobs is this feature *not* the right tool for, and why? Use a table format: column 1 = the job the user might bring, column 2 = why the feature under-serves it. Look for **structural** mismatches (the feature collapses a dimension the user actually needs — time-of-day, photosensitizer status, days-since-procedure, confidence) rather than surface ones.

3. **Competitor friction analysis** — what do existing apps in the space do for this feature, and what do their reviews complain about? Mark every competitor receipt with confidence level. `[provisional]` if not pulled from live App Store / Play Store reviews. **This is the section where "we're not copying the competitor, we're avoiding their failure modes" gets said in writing.**

4. **Cognitive risk** — what's the user's mental-model trap? Rank by **safety severity**, not by interaction-design severity. For a health-adjacent or safety-adjacent app, the question to answer is: *"What's the App-Store-review one-star scenario this feature creates that the current product doesn't have?"* Common trap patterns to look for:
   - Forecast-as-commitment (users treat probabilistic future data as a contract).
   - Single-integer-collapses-a-curve (one number erases the dimension the user actually plans against).
   - Personalization-silence (the feature drops back to a flat number where the rest of the product is personalized — undoes the trust gradient).
   - Tier-label-without-conditioning (verbal labels like "low risk" apply to averages, not to load-bearing edge-case personas).

5. **Edge-case personas** — for each underserved cohort the team has flagged (or *should* have flagged), does the feature help more, less, or differently? Use a four-column table: persona, daily-view-baseline, forecast-or-new-feature net effect, notes. Surface the cohorts the original PM proposal almost certainly did not consider — that's the value-add of this section.

6. **Verdict + conditions** — be explicit. One of three:
   - **Approve** — feature lands cleanly, no must-have conditions.
   - **Approve with conditions** — feature lands but only if must-haves are met. List **must-haves** (safety/JTBD-critical, non-negotiable) and **must-nots** (failure modes confirmed against existing canon) as separate, numbered lists. Defer items that are out of scope but flagged by the analysis to a **Deferred** sub-section.
   - **Reject** — feature does not earn its space. Cite the personas it would harm and the canon it would violate.

### What separates a useful application of this skill from a useless one

A useful application of this skill **changes the proposed feature's shape** — adds conditions, splits it into sub-features, defers parts of it, or kills part of it. If the verdict is "approve" with no conditions and no surprises, either the feature was very small or the researcher didn't push hard enough on the dangerous-match / mismatch / cognitive-risk sections. Push harder.

A useful application also **re-stratifies the persona inventory** for the new surface. Personas that were primary on the daily verdict may drop to low-match on the forecast surface, and edge-case personas may *rise* to primary. The skill should explicitly call out **"persona priority is surface-conditional, not absolute."** That insight is portable; it generalizes to every future feature validation.

### Quote discipline

- Every JTBD-match claim is anchored to a verbatim quote from the persona inventory, with the username cited (or `[provisional]` if reconstructed from a paraphrase pattern).
- Every competitor friction claim is marked `[provisional]` unless the researcher has pulled live reviews in this pass.
- Every cohort claim that lacks a documented thread is marked `[provisional]`.
- The verdict cites prior team decisions by ID (e.g., D-YYYY-MM-DD-NNN) so the verdict-with-conditions is testable against existing canon.

### Anti-patterns this skill is designed to surface

1. **"The competitor has it"** as an unstated justification. The competitor-friction section forces the researcher to articulate what the competitor's review pattern *complains about*, not what they offer.
2. **Single-persona validation.** Section 1 forces sub-buckets across the entire persona inventory; section 5 forces a separate pass for edge cases.
3. **Cognitive load handwaving.** Section 4 forces the researcher to rank by safety severity, not interaction polish.
4. **Mid-scope feature without sub-feature split.** The verdict's must-haves + deferred sub-sections give the team a path to "ship the safe half now, defer the risky half" rather than "approve the whole thing or kill it."

## When NOT to use this skill

- If the proposed feature is sub-screen polish (button copy, icon choice, animation timing) — overweight for the decision.
- If the team has no persona inventory — the skill has nothing to validate against. Build the personas first.
- If the team has already shipped the feature — this is pre-flight validation, not post-mortem. For post-mortem, use a different pattern (voice-of-customer feed on the shipped surface).

## Outputs

- A decision file in `.squad/decisions/inbox/{author}-{feature-slug}.md` containing all six sections plus a TL;DR header and open-questions footer.
- A history-file update for the author logging the new persona-stratification insight (since surface-conditional priority is portable).
- Optional: a deferred-sub-feature line item handed off to the scope owner.

## Evidence this skill works

n=1 (UV Burn Timer 10-day forecast validation). The application produced:
- A verdict that **split the feature** (time card vs. 10-day card) where the PM proposal had bundled them.
- A **new** insight (Devon's planning-mode dead-end maps onto the new feature in the near-term slice; WI-9 still required for the far-term slice — features are complementary, not redundant).
- A re-stratification of the persona inventory (Vee/Priya rise to primary; Greta drops to low-match on this surface).
- A clean handoff to four downstream owners (Linka, Wheeler, Plunder, Donatello) with specific, testable questions for each.

Confidence: **medium** — the structure is portable but has only been applied once. Update this section after the second and third applications.
