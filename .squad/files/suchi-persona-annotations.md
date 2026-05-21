# Persona Overlay Annotations — UV Burn Timer Flow

**Author:** Suchi (User Researcher)
**Date:** 2026-05-19T01:15:44-07:00
**Audience:** Linka (drawing canvas authority — read this mid-task, translate annotations into Excalidraw shapes)
**Scope:** A 4th-lane overlay on Linka's canonical onboarding + main-screen flow. Personas keyed; branch points called out; one-line per persona per screen unless the persona breaks the screen hard enough to need more.

> **Method note.** I'm overlaying real people on the canonical flow. Every quote here is sourced from prior thread work in `.squad/decisions/archive/suchi-monetization-personas.md`; quotes marked **[INFERRED]** extend persona pattern, not citation. Linka, if any annotation conflicts with a screen you've drawn differently — the canvas wins. Tell me.

---

## Personas (canon, from prior session)

| Code | Name | Fitz | Source | One-line scar |
|------|------|------|--------|---------------|
| **P1** | **Greta** — gram-counter, r/Ultralight | II/III | u/hareofthepuppy | "Will this app justify NOT carrying a backup sun shirt?" Tolerance for friction-before-value: zero. |
| **P2** | **Maya** — open-water swimmer, r/OpenWaterSwimming | III | u/Sungirl1112 | *"Despite using 50 SPF on my body and 70 SPF on my face… I'm still getting burned."* Water reflects ~10% UV; she doesn't know that. |
| **P3** | **Devon** — PCT thru-hiker, r/PacificCrestTrail | I | u/thedharmalife | *"I am super light-skinned (like *super* — I got a sunburn on a somewhat sunny day in February in NYC once)."* Self-diagnoses Fitz I correctly. Highest WTP. |
| **P4** | **Asha** — Accutane patient, r/Accutane | IV | u/Affectionate_Nose_79 | *"Like the UV is maybe 3 and it looks like Ive rolled a few. What can I do to stop this?"* Fitzpatrick under-predicts her burn. Load-bearing for the entire safety architecture. |
| **P5** | **Tomás** — trail runner, r/trailrunning | IV/V | u/Amazing-Reporter1845 | *"I tan, I don't burn."* Reapplication-cadence JTBD. Risks under-picking Fitz (claims V when really IV). |

**Suggested lane colors (Linka — your call, but these read distinctly in print + colorblind sim):**
- Greta → **green** (#2E7D32) — neutral, low-noise
- Maya → **blue** (#1565C0) — water
- Devon → **red** (#C62828) — burns easily
- Asha → **purple** (#6A1B9A) — medical/photosensitizer, distinct from "danger red"
- Tomás → **orange** (#EF6C00) — motion, high-energy

---

## Per-Screen Persona Annotations

> The screens below mirror Linka's iOS spec §2.1–§2.8 + §8.4. Where the user's directive said "photosensitization attestation," I'm being honest: **there is no attestation surface by design** (zero-data architecture, Donatello M7). The "attestation moment" is the L1 inline deep-link → About → return loop. See Screen 4.

### Screen 1: Cold launch → L1 `DisclaimerCover` (full-screen modal)

> Title: "How accurate is this for you?" • Body has inline *see About* deep-link to `notForMe` anchor • "For children, consult a pediatrician" on its own line • Single "I understand" button.

- **Greta** *(green)*: Skims title in ~2 seconds. The "How accurate is this for you?" phrasing makes her pause briefly (it's not the marketing wall she expected). Taps "I understand" within 4 seconds. Will not tap the inline *see About* link. **Annotation: dashed arrow straight from L1 to Screen 2 (skin picker).**
- **Maya** *(blue)*: Reads the "skin response varies" line because she has SPF-50-still-burned lived experience. Mentally nods. Does not tap the inline link. ~6-second dwell. Straight path to Screen 2.
- **Devon** *(red)* — **STICKY (~10–15 sec dwell)**: As a Fitz I, he *needs* the "model estimate only" framing because he's doing gear-weight math. Reads the whole paragraph. **Will not tap the inline link** (he's not photosensitive in the medication sense). May screenshot the modal for trail-prep notes **[INFERRED]**. Straight path to Screen 2.
- **Asha** *(purple)* — **STICKY + BRANCH**: This is **the load-bearing moment for the entire app's safety architecture.** She sees "If you take a photosensitizing medication or have a sun-sensitive condition — see About." **She taps the *see About* link** → presents `AboutView` as a `.sheet` over the still-present `DisclaimerCover` (`highlightEstimateApplicability: true` scrolls to the applicability section; `DisclaimerSeeAboutLink` button; WI-13 shipped `90ecf26`) → reads the photosensitizer cohort list → dismisses About → returns to L1 still-present → taps "I understand." **This is her attestation flow architected as visibility, not as a toggle.** Total dwell: ~30–60 seconds. **Annotation: branch arrow from L1 → About (`notForMe`) → back to L1 → Screen 2.**
- **Tomás** *(orange)* — **RISK**: One earbud in, at trailhead. Will dismiss the modal in ~2 seconds without reading. **The L2 footer disclaimer must therefore do real work for him on every subsequent screen.** Behavior-led copy ("Reapply sunscreen every 2 hours regardless of timer") is what catches him at mile 8. Straight path to Screen 2.

**Diagram note for Linka:** L1 is a hard gate on fresh install and on every disclaimer-version (Pattern B, ratified 2026-05-21T07:00Z; see `.squad/decisions.md` ~L685 + WI-ff Group GD guards). Asha's branch is the only non-trivial path off this screen — call it out visually. *Suchi WI-suchi-g (Loop-11) reconcile: this annotation previously said "every cold launch"; that was Pattern A (pre-WI-ff). Pattern B keys re-attestation on `disclaimerPolicyVersion` bumps so Greta does not see L1 every cold launch but Asha still re-attests every policy bump — see paragraph below for the persona-impact analysis.*

---

### Screen 2: `NowView` empty state (after L1 dismiss)

> Hero shows sun symbol + prompt "Tap **Use my location** to compute your estimate" • Inputs `DisclosureGroup` expanded by default on first run with "Pick a skin type" prompt at the top • SPF defaults to 30 • Tier badge hidden • L3 link hidden (no estimate to qualify yet).

- **Greta**: Sees the empty state, immediately recognizes the "one screen, one calculation" pattern she wanted. Taps "Skin type" first (top of disclosure). Zero friction.
- **Maya**: Same. May glance at the SPF row ("it says 30 — but my face is 70") and tap to change it before location. **Mental-model risk: she only gets to enter one SPF; the verdict will assume her body, not her face. Linka, no annotation needed on this screen, but flag for the verdict screen.**
- **Devon**: Already knows he's Fitz I. Taps skin type first. Will tap "None" for SPF (gear math — testing without-sunscreen scenario).
- **Asha**: Same as Greta — but **she has just dismissed the L1 attestation cycle.** The empty state's neutrality is a feature for her: nothing here is overconfident. Picks skin type next.
- **Tomás**: Already running mentally. Taps "Use my location" first **without picking skin type.** **Branch:** the spec requires that location-tap with no skin-type selected shows an alert "Pick a skin type first" OR the verdict card shows an empty state directing him back to SkinTypeView. **Annotation: dashed back-arrow from Location → SkinTypeView for Tomás's lane.**

---

### Screen 3: `SkinTypeView` (Fitzpatrick picker, no default)

> Form-style list, six rows, ≥56pt row height • Section header: "Pick the row that best matches **what your skin does**, not what color it is." • No default selection • No skin-tone swatches • Footer caveat about photosensitizing medications.

- **Greta**: Picks **Type II or III**. Self-classifies in ~3 seconds based on the behavior description ("burns easily, tans minimally" or "burns moderately, tans gradually"). Correct.
- **Maya**: Picks **Type III**. Lives in SE Asia. The section header *("not what color it is")* matters for her — protects her from the Eurocentric "Type IV = olive Mediterranean" mis-mapping. **Annotation: callout — "Section header is load-bearing for Maya."**
- **Devon**: Picks **Type I**. *"I got a sunburn on a somewhat sunny day in February in NYC."* He'd correct any default away from I within seconds — which is exactly why we don't pre-anchor him on III. **Annotation: bright red star on Type I row — Devon is the persona who validates the no-default rule.**
- **Asha**: Picks **Type IV** (her actual phototype). **But she knows the verdict will be wrong for her body because of Accutane.** The footer caveat *"This model assumes healthy skin and no photosensitizing medications"* is what she reads next. **Annotation: purple sticky on the footer caveat — "Asha re-reads this here, even though she already saw L1."**
- **Tomás** — **RISK: under-picks**: He's actually **Type IV** (Mediterranean/Latin/South Asian/etc., variable across the IV/V band), but his self-narrative is *"I tan, I don't burn."* **He may pick Type V (or even VI) by mistake** — minimizing his perceived risk. The verdict will be ~20–30% too generous for him. **This is the highest under-picking risk in the persona set.** Behavior-first row copy ("Rarely burns, tans deeply. Brown skin." for V) partially mitigates — he reads "rarely burns" and self-selects on the strongly-true clause without checking the rest. **Annotation: orange warning arrow from Tomás's lane → Type V row, labeled "self-narrative mis-pick risk."**

**Branch diagnostic:** Devon validates *no default* (without it, he'd be anchored to III and under-estimate by ~50%). Tomás validates *behavior-first copy* (without it, the IV/V description leads with color, which doesn't break his self-narrative). Both are real safety wins.

---

### Screen 4: "Photosensitization attestation" (NOT a screen — it's the L1 deep-link loop)

> ⚠️ **Naming honesty:** The user directive references "photosensitization attestation," but **we deliberately do not have an attestation surface.** Asking the user to attest would require collecting special-category medical data — forbidden by Donatello M7 + Raphael Art.9 + zero-data architecture. Instead, the pattern is **visibility, not attestation**: the L1 inline "see About" deep-link reveals the cohort list; the user reads or doesn't; nothing is stored.

The "attestation moment" therefore happens **inside** the L1 cover (Screen 1) and **also** from the L3 link on the verdict card (Screen 5+). It is not a standalone screen.

- **Greta**: Never enters this loop. Path: L1 → Screen 2.
- **Maya**: Never enters from L1. **Might** tap L3 from the verdict card if her first-burn experience makes her wonder ("am I in some cohort I don't know about?") — low probability.
- **Devon**: Never enters this loop. Type I burns are explainable by Fitzpatrick alone; he doesn't need the photosensitizer cohort list.
- **Asha** — **THE ENTIRE LOOP**: L1 → tap "see About" → `AboutView` presents as a `.sheet` (`highlightEstimateApplicability: true`; scrolls to `notForMe` anchor) → reads "retinoids, certain antibiotics, certain anti-malarials, lupus, vitiligo, albinism, post-procedure skin, pregnancy" → recognizes "retinoids" as her Accutane → dismisses About → returns to L1 → taps "I understand." **She now trusts the app's honesty enough to use its number with the right mental adjustment.** **Annotation: purple swirl/round-trip arrow from L1 → About → L1, labeled "Asha's visibility loop (this is the safety architecture working).**"
- **Tomás**: Never enters. He dismissed L1 in 2 seconds.

**Diagram note for Linka:** Don't draw a Screen 4 box. Instead, draw a **side-quest cluster** off L1 (and later off the verdict card) showing the About → return loop as a labeled callout for Asha's lane. This honors the visibility-not-attestation architecture.

---

### Screen 5: Location permission + first verdict landing

> Tap "Use my location" → iOS system permission prompt → granted → "Fetching UV…" (2–5 seconds) → verdict renders: hero number (e.g., "47") + "min" + tier badge + context line ("Fitzpatrick III · SPF 30 · UV index 8.0") + **L3 link "Is this estimate for me?"** + WeatherKit attribution lockup + L2 footer.

#### Location prompt sub-screen

- **Greta**: Reads the privacy paragraph that precedes the prompt (verbatim pattern from her cohort: "no tracking" is precondition). Grants. **"When in Use" only**, never "Always."
- **Maya**: At the beach, wet hands. Taps the big button. Grants. Doesn't read privacy copy.
- **Devon** — **BRANCH: may deny**: He's at home in February planning a July hike. **He has no current useful location to grant.** Per Linka's spec the location-denied state shows a humane `ContentUnavailableView` with "Open Settings." Devon's actual workaround is iOS Simulator or fake-GPS — not a v1 affordance. **Annotation: red dashed arrow from Location → "Denied" empty-state box, labeled "Devon's planning use-case dead-ends here in v1."**
- **Asha**: Reads privacy paragraph (medical-privacy posture). Grants reluctantly. **[INFERRED — her cohort skews privacy-conscious.]**
- **Tomás**: Grants without reading. One tap, mid-stride. Needs the button to visibly respond — Linka's spec adds an inline spinner during fetch so Tomás sees the tap registered (`location.fill` symbol swap).

#### Verdict landing

- **Greta**: Glances at the integer (e.g., "47 min"). Cross-references the context line ("Fitzpatrick III · SPF 30 · UV 8.0") — that's her gear-math sanity check. **Ignores L3 link.** Probably screenshots. Tier badge is secondary signal.
- **Maya**: Compares to her planned 90-minute swim. Her verdict is e.g., 70 min for Fitz III + SPF 50 + UV 6 — she's short by 20 minutes. Decides to shorten the swim. **Risk:** the verdict does not account for water reflection (+10%) or sunscreen washing off. Linka's spec defers both to About §3 ("Why this number changes with weather"). **Annotation: small blue asterisk on the verdict number for Maya — "blindspot: water reflection & wash-off not modeled."**
- **Devon**: Multi-scenarios it (Fitz I × SPF 30 × UV 9 = "Short"; Fitz I × SPF 50 × UV 9 = still short). Validates the long-unprotected `4+ hr` cap doesn't kick in for him (it won't — he's Fitz I). **Doesn't tap L3.**
- **Asha** — **STICKY + TAP L3**: Her verdict (Fitz IV + SPF 50 + UV 6) reads e.g., "120 min." Her lived experience says she'd burn in ~20 min on the same conditions. **She taps L3 "Is this estimate for me?"** → About at `notForMe` → re-reads the photosensitizer cohort. Returns. **Now she mentally divides the 120 by 4–6** based on her body's history. **Annotation: purple arrow from verdict → L3 → About → return → verdict. This is the most-tapped path for Asha and the single most important L3 interaction in the entire app.**
- **Tomás**: Reads two things: **the integer + the tier color.** Everything else is wasted. If the integer is < 20 and the badge is red — he reapplies. Otherwise: keeps running. **He does not see the L3 link** (saccade doesn't reach the footnote). **Annotation: orange annotation on hero number + tier badge only; everything else is grey for Tomás.**

---

### Main screen — repeating use (post-first-launch)

> Same `NowView` with pull-to-refresh • `lastUV` cache shown on cold-launch with "Updated N min ago" • Window-elapsed state when `elapsed >= originalEstimate` • L2 footer always-on.

- **Greta** — **JTBD: reapplication cadence**: Once she's seen the verdict, her question shifts: "How long until I reapply?" The app doesn't (and shouldn't, per launch plan) ship a reapplication timer in v1, but the L2 footer's *"Reapply sunscreen every 2 hours regardless of timer"* is the v1 answer. **Annotation: green sticky on L2 footer for Greta — "This is her primary reading on repeating use."**
- **Maya** — **JTBD: pre-swim & mid-swim re-check**: She'll cold-launch the app **twice** (pre-swim and post-warmup) and expects the new fetch to update the verdict. Pull-to-refresh is critical for her. **Annotation: blue arrow on the pull-to-refresh gesture — "Maya's primary affordance on repeating use."**
- **Devon** — **JTBD: scenario planning**: He's testing variations. The lack of a "try a different UV" affordance in v1 means he uses the iOS Simulator or accepts that the verdict reflects only his current location. **Annotation: red dotted "planning mode missing in v1" callout — soft, deferred to v1.1.**
- **Asha** — **RE-ATTESTATION MOMENT**: She doesn't re-take Accutane every day, but when her medication changes (start of new prescription, end of treatment), her body's photosensitivity changes. **Under Pattern B (ratified 2026-05-21T07:00Z, see WI-ff Group GD), the L1 cover fires on fresh install and on every `disclaimerPolicyVersion` bump — Asha sees the photosensitizer line whenever the disclaimer materially changes, NOT every cold launch.** This trades a small loss of "ambient re-attestation pressure" (Pattern A reading) for a large win on Greta's friction tolerance: she stops seeing L1 every cold launch. Asha's re-attestation is now event-keyed: when she starts a new prescription she would normally re-read About anyway; when Plunder bumps the policy version (regulatory or copy change) the cover re-fires unconditionally. **Annotation: purple sticky on L1 cover — "Asha's re-attestation moment is here, on fresh install + on every disclaimer-version bump (Pattern B / WI-ff Group GD)."**
- **Tomás** — **window-elapsed state**: He set the app down at the trailhead and is now at mile 8. The window-elapsed state (hero swaps to `exclamationmark.shield.fill`, copy "Estimated window elapsed. Cover up, reapply sunscreen, or move to shade.") + warning haptic is **the safety moment** for him. **Annotation: orange double-arrow on the window-elapsed state — "Tomás's most important screen. The whole app's existence is justified by this state firing correctly for him."**

---

## Branch-Point Specials

The 5 places in the flow where persona divergence creates a design tension the diagram should visually annotate.

### Branch 1 — L1 inline "see About" deep-link
- **Branch:** Inside the `DisclaimerCover` (Screen 1).
- **Divergence:** Asha taps the inline link; Greta/Devon/Tomás skip it entirely; Maya reads but doesn't tap.
- **Diagram annotation suggestion:** Draw L1 as one box with **two outgoing arrows**: (a) solid arrow → Screen 2 (4 personas), (b) **purple dashed loop arrow** → AboutView (`notForMe` anchor) → return to L1 (Asha only). Label the loop "Asha's visibility loop — the 'attestation' architecture."

### Branch 2 — No-default Fitzpatrick rule
- **Branch:** Top of `SkinTypeView` (Screen 3).
- **Divergence:** Without no-default, Devon (Fitz I) would be pre-anchored to III and under-estimate his burn risk by ~50% on first launch. Greta would also be slightly mis-anchored.
- **Diagram annotation suggestion:** Put a **red star + "No default" callout** at the top of Screen 3's box. Label: "This rule exists for Devon — without it, his first verdict is unsafe."

### Branch 3 — Tomás's under-picking risk
- **Branch:** Type V row in `SkinTypeView` (Screen 3).
- **Divergence:** Tomás's self-narrative ("I tan, I don't burn") nudges him toward V or VI when he's actually IV. Behavior-first row copy mitigates but doesn't eliminate.
- **Diagram annotation suggestion:** **Orange caution flag** on the Type V row inside Screen 3's expanded view. Label: "Tomás self-narrative risk — behavior-first copy is the partial mitigation. No further mitigation in v1 without a quiz (out of scope)."

### Branch 4 — L3 verdict-card link
- **Branch:** Verdict-card screen (Screen 5+).
- **Divergence:** Asha taps L3 nearly every cold-launch session; Maya may tap once exploring; Greta/Devon/Tomás never tap.
- **Diagram annotation suggestion:** Draw the L3 link as a small affordance off the verdict card, with **a purple-bold arrow** showing the deep-link to AboutView § `notForMe` (Asha's primary path) and a thin blue arrow showing Maya's occasional tap. Greta/Devon/Tomás lanes show no arrow to L3.

### Branch 5 — Window-elapsed state
- **Branch:** `NowView` repeating use, when `elapsed >= originalEstimate`.
- **Divergence:** Tomás depends on this state firing visibly + haptically while he's running; Maya may already be in the water (can't see the screen — she's relied on pre-swim verdict); Greta + Devon read the elapsed state at a rest stop without urgency; Asha probably set the app down hours ago because she's indoors after a 20-minute exposure.
- **Diagram annotation suggestion:** **Bold orange callout** on the window-elapsed state box: "This state is Tomás's safety moment. Verify haptic + visual contrast in direct sun." Add a **blue dashed line** showing Maya's "I can't see this — pre-swim verdict had to be right."

---

## Visual hints for Linka

### Color-coding
- See persona lane palette above. Test against Coblis / Sim Daltonism — green/red distinguish poorly under deuteranopia, so **lean on shape + label**, not color alone, where Greta and Devon's paths must be told apart.

### Dashed vs. solid arrows
- **Solid arrows** — the persona actually takes this path on a typical session.
- **Dashed arrows** — the persona *can* take this path but probably won't (Maya tapping L3 once exploring; Devon screenshotting L1).
- **Dotted arrows** — deferred / v1.1 / out-of-scope paths (Devon's "try a different location" affordance, Live Activity surfaces).

### Sticky-disclaimer indicators
- **L1 hard gate** — annotate "Fresh install + every `disclaimerPolicyVersion` bump (Pattern B / WI-ff Group GD)" badge on Screen 1's box. This is Asha's re-attestation re-fire mechanism. *Pre-Loop-10 reading: "Every cold launch" (Pattern A). Reconciled Loop-11 by WI-suchi-g.*
- **L2 always-on footer** — annotate as a thin line across the bottom of every NowView-family box. This is Tomás's only persistent safety surface (he dismissed L1).
- **L3 verdict-card link** — annotate as a small info-icon affordance on the verdict-card box with the purple deep-link arrow.
- ⚠️ **No L4** — the Linka spec uses an "L1–L4" framing for layered disclaimer in some sections, but for the **diagram** we only need to draw L1, L2, L3 (the user-facing surfaces). L4 is the About anchor itself, which we already draw as the deep-link target.

### Suggested swimlane structure
- Top lane: **System / canonical flow** (what every user sees).
- Lane 2: **Cognitive load / dwell time** (annotate each screen with persona-keyed dwell estimates).
- Lane 3: **Disclaimer surface state** (L1 fired? L2 present? L3 visible?).
- Lane 4: **Persona-keyed annotations** — the 5 colored swimlanes for Greta/Maya/Devon/Asha/Tomás with the per-screen annotations above.

If lane 4 is too dense, **collapse Greta + Devon into one "low-friction" merge** on most screens (they diverge meaningfully only on Screen 3 and Screen 5+ planning) and **collapse Maya + Asha into one "sticky readers" merge** where they read the same disclaimer language. **Tomás always stands alone** — his path is the most divergent and the most safety-critical.

---

## Quotes inventory (cite these inline on the diagram if space allows)

1. **Greta on subscription-gating** (u/hareofthepuppy, r/Ultralight, 141 upvotes):
   > "First filter: no subscription."
   *Use on:* L1 cover annotation, validating "no marketing wall."

2. **Maya on SPF inadequacy** (u/Sungirl1112, r/OpenWaterSwimming):
   > "Despite using 50 SPF on my body and 70 SPF on my face… I'm still getting burned."
   *Use on:* Verdict-card annotation, validating "model has slop she already knows about."

3. **Devon on Fitz I self-identification** (u/thedharmalife, r/PacificCrestTrail):
   > "I am super light-skinned (like *super* — I got a sunburn on a somewhat sunny day in February in NYC once)."
   *Use on:* Type I row in SkinTypeView, validating "no default" rule.

4. **Asha on Fitzpatrick under-prediction** (u/Affectionate_Nose_79, r/Accutane):
   > "Like the UV is maybe 3 and it looks like Ive rolled a few. What can I do to stop this?"
   *Use on:* L1 inline "see About" annotation and L3 verdict-card link annotation. **The single most important quote in this entire spec.**

5. **Asha (related)**:
   > "I was literally only in the sun for about 5 minutes while watering the garden and my stupid scalp got burnt."
   *Use on:* Verdict-card annotation, validating "she mentally divides our number."

6. **Tomás on tanning self-narrative** (u/Amazing-Reporter1845, r/trailrunning, **[INFERRED quote pattern]**):
   > "I tan, I don't burn."
   *Use on:* Type V row in SkinTypeView, validating "behavior-first copy" rule and flagging the under-picking risk.

---

## Notes for Linka

- **Density:** This spec is dense. Don't try to put every annotation on the canvas. **Prioritize the 5 Branch-Point Specials.** They're the moments the diagram earns its keep.
- **If you only draw 3 persona-keyed callouts:** make them (1) Asha's L1 inline-deep-link loop, (2) Devon's no-default-Fitz red star, (3) Tomás's window-elapsed-state safety moment. Those three are the diagram's safety thesis.
- **If you have space:** add Maya's pull-to-refresh annotation and Greta's "L2 footer is the reapplication-cadence answer" sticky.
- **What to leave OFF the diagram:** the photosensitizer "attestation screen" the user directive mentioned — there is no such screen by design. Draw the visibility loop instead and label it. **Don't reify an architecture we deliberately don't have.**
- **HIG conflict resolution:** if any annotation I've suggested would force you to draw a non-HIG affordance (e.g., a custom modal Asha "lives in"), the HIG wins and I'd like to know.

If something here lands wrong on the canvas, ping me and we'll iterate.

— Suchi

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*

*Last reconciled with code: `2d05a25` — 2026-05-20 (WI-29/WI-31; reflects WI-13 inline see-About `.sheet` presentation)*
