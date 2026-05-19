# Design Brief for Linka — Persona Lens on the Prototype
**Author:** Suchi (User Researcher)
**Date:** 2026-05-19T00:10:00-07:00
**Audience:** Linka (UI/UX, primary) · Plunder (compliance, on disclaimer placement) · Gaia (scope, FYI)
**Status:** Draft handoff — Linka is working in parallel; she does not need to wait on me.

> A note on method: I am building on the persona work already cited in `.squad/decisions/archive/suchi-monetization-personas.md` and my history.md. Verbatim quotes carry a username and a permalink lineage from the prior pass. Anything marked **[INFERRED]** is a design-relevant extension I'm drawing from persona pattern, not from a specific quote. I'd rather over-mark than under-mark.

---

## 0. Top 5 personas — short reference card

These are the lenses I apply throughout this brief. They are not averages of users. They are specific people I've quoted before.

| Code | Name (composite) | Source | One-line JTBD |
|------|------------------|--------|----------------|
| **P1** | **Gram-counter Greta** | u/hareofthepuppy, r/Ultralight | "Hire the app to validate that I don't need to pack a backup sun shirt for the desert section." |
| **P2** | **Sungirl Maya** | u/Sungirl1112, r/OpenWaterSwimming | "Hire the app to tell me whether I'll finish today's 1.5-hour swim before I burn." |
| **P3** | **PCT Pale Devon** | u/thedharmalife, r/PacificCrestTrail | "Hire the app to plan how much sunscreen weight I carry through the desert + Sierra transition." |
| **P4** | **Accutane Asha** | u/Affectionate_Nose_79, r/Accutane | "Hire the app to tell me when **I** burn — because UV 3 burns me and the weather app's '3 = low' is gaslighting me." |
| **P5** | **Trail-run Tomás** | u/Amazing-Reporter1845, r/trailrunning | "Hire the app to tell me whether I need to stop and re-grease at mile 8, or push to 12." |

Two additional personas surface in §7 (edge-case personas the prototype implicitly assumes away): **Parent-of-pale-child Priya** and **Vitiligo / albinism Vee**. These are not in the launch persona set but they will arrive at the App Store regardless and the design needs a graceful answer.

---

## 1. Persona × Screen matrix

For each surface in the prototype, what each persona needs to see / do / avoid. Read the rows; the columns are not for everyone.

### 1.1 First-launch disclaimer modal (`#disclaimer-dialog`)

Today this fires on every new browser session and is a single "Got it" button. Persona by persona:

| Persona | Needs to see | Needs to do | Needs to avoid |
|---------|--------------|-------------|----------------|
| **P1 Greta** | A short, no-fluff "this is an estimate, not a measurement" line. She's read this paragraph on twelve gear apps before. | One tap dismiss. Move on. | Anything that smells like a marketing wall, a sign-up, or a "the calculator is locked until you read this" gate. Her tolerance for friction-before-value is **zero**. |
| **P2 Maya** | The "skin response varies" line, because she has lived experience that SPF 50 is not protecting her past 1.5h and she needs the app to acknowledge that. | One tap dismiss. | Modal language that implies the model is exact. She will quietly distrust the app if the disclaimer is over-confident. |
| **P3 Devon** | The "model estimate only" framing — Devon is doing weight math and **needs** to know the estimate has slop in it. | One tap dismiss; possibly screenshot the modal for trail-prep notes. **[INFERRED]** | A disclaimer so soft it implies the model is unreliable. Devon needs to trust it enough to base a gear decision on it. |
| **P4 Asha** | This is the **load-bearing screen for her**. She needs the phrase "skin response varies" and ideally a line that names photosensitizing medications/conditions. Verbatim from her cohort: *"Like the UV is maybe 3 and it looks like Ive rolled a few. What can I do to stop this?"* (u/Affectionate_Nose_79). The Fitzpatrick model **under-predicts** her burn risk; the disclaimer is the only thing that prevents the verdict card from gaslighting her into staying outside too long. | Read carefully, then dismiss. | A disclaimer she can't find later. If she dismisses and forgets and the verdict says "Long — 90 minutes," she may forget that the model doesn't account for her Accutane. **The disclaimer needs to be reachable again from the verdict card.** |
| **P5 Tomás** | Almost nothing. He's at the trailhead with one earbud in. He'll tap "Got it" without reading and that is acceptable IF the footer disclaimer is doing real work. | One tap dismiss. | A modal that requires reading time longer than ~4 seconds. He won't read it; he'll dismiss it; and then he'll burn at mile 8 without knowing why. |

**Design directive to Linka:**
- Keep the first-cold-launch modal as a hard gate. It's working for P4.
- Add a one-line **"I take a photosensitizing medication or have a sun-sensitive condition — see About"** *inline* in the modal body, where "see About" deep-links to the About expansion (§1.6) that lists the cohort. We **cannot** ask the user to toggle this — per the zero-data architecture (Donatello M7) we don't collect special-category data. The disclaimer therefore has to be **visible and findable** rather than persona-toggled.
- Subhead/title prominence: bigger. The current "⚠️ Important Notice" is generic. Try **"How accurate is this for you?"** — it converts the modal from a legal CYA into a useful self-classification prompt, which Asha will actually read.

---

### 1.2 Fitzpatrick skin type selector

The radio I–VI grid with descriptions ("Always burns, never tans" through "Never burns, deeply pigmented").

| Persona | Needs to see | Needs to do | Needs to avoid |
|---------|--------------|-------------|----------------|
| **P1 Greta** | Greta is Fitz II or III and self-classifies in 2 seconds. She needs the description to map cleanly to a memory ("burns easily, tans minimally — yes, that's me"). | Tap once. | Color swatches that try to pretend they show skin tone. Fitzpatrick is not ethnicity (see §3) and showing skin-color swatches will trigger her "this is bad science" detector. |
| **P2 Maya** | Maya, from u/Sungirl1112's framing, lives in SE Asia. She is likely Fitz III–IV. She needs the descriptions to **not** code Fitz IV as "olive Mediterranean" — that is a Eurocentric mapping that doesn't fit her self-image. | Tap once and trust the selection. | Imagery or copy that implies the high-Fitz types are "less at risk." Maya is **explicitly** at risk (her verbatim: *"despite using 50 SPF... I'm still getting burned"*). |
| **P3 Devon** | Devon is Fitz I and **knows it**. Verbatim: *"I am super light-skinned (like *super* — I got a sunburn on a somewhat sunny day in February in NYC once)."* (u/thedharmalife). He needs Fitz I to be visibly the top option, not buried. | Tap once. | The selector defaulting to Fitz III. The current prototype defaults to III (line 304: `checked`). For Devon, that default is a quiet error that will skew his first read of the estimate by ~50% for his first interaction. **[Design directive: do not pre-select a Fitzpatrick type on first launch.]** Force a deliberate tap. |
| **P4 Asha** | Asha may be any Fitz type. Her sun sensitivity comes from medication, not pigmentation. She needs the selector to acknowledge that **skin type alone doesn't predict burn risk**. | Pick her actual Fitzpatrick. Then immediately mentally subtract one or two types because she knows the math doesn't fit her. | A model that implies Fitz IV = safer than Fitz II in her case. It is not, for her. The caveat *"For accurate classification, consult a dermatologist"* exists (line 324) — but it's too small and the wrong message. The right adjacent message is "**This model assumes healthy skin and no photosensitizing medications.**" |
| **P5 Tomás** | One-handed, motion-blur, sweat on the screen. He needs the tap targets to be **large** and the labels to be readable at arm's length while jogging. | Tap once. Hard targets, no precision required. | Tap targets smaller than ~56pt. The current `.fitz-option` is ~44pt-ish but has a small radio button that's the actual touch target on iOS if the label tap doesn't work — Linka, please verify the full row is the tap target on the iOS port, not just the radio. |

**Design directives to Linka:**
1. **No default Fitz selection.** Make the user choose. Devon should not get pre-anchored to III.
2. **Caveat needs more weight.** The single italic line under the grid is doing safety work for two personas at once (Asha + V/VI users — see §7). It needs to be persistent, not just italic-grey.
3. **Do not show pigmentation swatches.** Fitzpatrick is a *burn-and-tan response* scale, not a skin-color scale. If Linka considers swatches, it'll save the user a half-second and offend the science. I'd push back hard.
4. **Each row's description should lead with the burn behavior**, not the skin color. The current copy does this for I and II ("Always burns, never tans"; "Burns easily, tans minimally") and switches to color for V and VI ("Brown/dark skin"; "Dark brown/black skin"). Bring V and VI into the same construction: "**Rarely burns, tans deeply.** Brown skin." This is a small copy edit with disproportionate trust effect for Fitz V–VI users — see §7.

---

### 1.3 SPF selector

None / 15 / 30 / 50 / 70+ chip row.

| Persona | Needs to see | Needs to do | Needs to avoid |
|---------|--------------|-------------|----------------|
| **P1 Greta** | The SPF her actual tube says. She owns one tube. | Tap her SPF, never look at this control again. | An "SPF 100" option that doesn't exist on her tube. The current ceiling (70+) is correct — don't extend it. |
| **P2 Maya** | Maya already knows the calculation isn't keeping up — *"despite using 50 SPF on my body and 70 SPF on my face."* (verbatim). She needs the option to reflect what she's using **on the burn-prone surface** (face is 70, body is 50, which one does she input?). | Tap once. Reluctantly accept the simplification. | A UI that pretends SPF 50 + SPF 70 = some combined value. The current single-SPF model is right for v1 simplicity but Linka should know that for Maya, the **face vs. body** SPF mismatch is a real model limitation. **[INFERRED design directive: a future "more options" expansion could let advanced users input "burn-prone surface SPF"; not v1.]** |
| **P3 Devon** | The "None" option. He's testing the "if I skip sunscreen entirely, how many minutes do I have on the trail?" calculation as part of weight optimization. | Tap "None" without judgment from the UI. | A UI that nudges him toward "any SPF is better than none." Devon is doing legitimate gear math and the app's job is to give him the number, not to moralize. The current chip row is neutral — keep it neutral. |
| **P4 Asha** | The "None" option AND every SPF. Her cohort buys SPF 70+ specifically because Accutane. She may also be wearing layered protection (mineral SPF 50 + zinc paste + hat + long sleeves) and the SPF chip can only capture one number. | Pick the SPF on her tube. | An interpretation in the verdict card that frames SPF as the safety lever. For Asha the **clothing/shade lever** is dominant. The verdict copy should not say things like "more SPF = safer." It currently does not. Hold this line. |
| **P5 Tomás** | The same chip he tapped last time. He's in motion. | Ideally **zero taps** if his last setting persisted. (Prototype encodes this in URL hash, which is web-only; on iOS this becomes `@State`, which is **memory-only** per Casey's spec — meaning Tomás *will* have to tap again on every cold launch. Note: this is a privacy/safety tradeoff intentionally made by Donatello M7 + Raphael Art.9; not a bug.) | Tap precision. Sweaty fingers + chips smaller than ~50pt = misfires. |

**Design directives to Linka:**
- Keep the chip row neutral. No "recommended" badge on SPF 50.
- Verify chip touch targets work for Tomás (sweat) AND Maya (wet hands). I'd aim for ~52–56pt and 8pt minimum spacing.
- A small UX win: when the user taps "None," the result tier badge will be "Short" most of the time. **Do not** color the chip itself red — that's moralizing. Color belongs on the verdict.

---

### 1.4 Location / "Use my location" card + privacy notice

Today: one button, one paragraph of privacy copy, browser permission prompt, then status + coord readback.

| Persona | Needs to see | Needs to do | Needs to avoid |
|---------|--------------|-------------|----------------|
| **P1 Greta** | The privacy notice. Verbatim from her cohort, "no tracking" is a precondition. She **will** read this paragraph. | Tap once. Accept the iOS prompt. | Anything that asks for "Always" location instead of "When in Use." iOS-side this is a Casey/Kwame configuration item — Linka, just confirm the prompt copy. |
| **P2 Maya** | Maya is at the **beach**, sand and salt on her phone, wet hands. The button needs to be huge and her wet fingerprint needs to register. | One tap. | A button that requires precise placement. The current `width: 100%` `.btn-primary` is good — keep it. |
| **P3 Devon** | Devon is **doing this at home in February** for his July hike planning. He needs to be able to **enter a destination coordinate manually** without going to the desert first. The prototype's debug `?uv=N` is exactly this affordance under a different name. **Design directive:** ship a "Plan for a different location" affordance in v1.1 or v2. For v1, accept that Devon will fake the GPS or use the iOS Simulator. **[INFERRED]** | Tap, then deny location, then need an escape. Currently denying location with no override = dead-end (line 551 just shows the error). | A dead-end on permission deny. Even if "manual coords" is out of scope for v1, **show a helpful message** ("Location is the only way to get current UV. Try again when ready.") rather than just an error string. |
| **P4 Asha** | The privacy notice — for the same reason Greta needs it: she does not want a sun-tracking app building a profile of her photosensitivity. She is, in her own framing, a privacy-conscious medical patient. **[INFERRED]** | Tap once. | Persistent location, background tracking, push notifications. None of these exist in v1 per the launch plan guardrails — keep it that way. |
| **P5 Tomás** | The button needs to work **while running**. The current "Requesting location… → Fetching UV data… → UV index now: 7.2" sequence is ~2–5 seconds. That's fine if he stops; it's an eternity if he doesn't. | Tap once at a stoplight or a water stop. | A button that doesn't visibly respond to the tap. Currently `btn.disabled = true` is the only signal — add a spinner or pulse. |

**Design directives to Linka:**
- The privacy paragraph is doing a lot of work for two anti-subscription / anti-tracking personas (Greta, Asha). Keep it inline and visible — do **not** collapse it into a "Learn more" link.
- On location-deny, show a **graceful empty state**, not an error string. Suggested copy: *"UV Burn Timer can't show your current estimate without your location. Tap again when you're ready, or try later."* Avoid "without your location we cannot..." (sounds coercive). Avoid "this app needs..." (sounds entitled).
- Add a visible loading state for the 2–5 second fetch. Tomás cannot stand still that long without feedback.

---

### 1.5 Result / verdict card

The headline screen. Badge (Long/Moderate/Short), main line ("Estimated time to 1 MED of skin reddening: ~22 minutes (Fitzpatrick III, SPF 30, UV index 8.0)."), subline ("Model estimate. Recalculate as UV changes.").

| Persona | Needs to see | Needs to do | Needs to avoid |
|---------|--------------|-------------|----------------|
| **P1 Greta** | The minutes number, big. The Fitzpatrick + SPF + UV index recap (so she can sanity-check it later). The tier badge is useful but secondary. | Glance once. Maybe screenshot for her gear notes. **[INFERRED]** | A verdict that hides the number behind a vague "high risk" pill. Greta wants the integer, not the adjective. The current "~22 minutes" framing is good. Keep the integer; the tier badge is a fast-glance adjunct, not a replacement. |
| **P2 Maya** | The minutes number, compared to **her swim duration**. The mental math she's doing is "90 minutes to MED minus my planned 105-minute swim = I'm short by 15 minutes." | Glance, then decide whether to shorten the swim or reapply mid-swim (impossible — she's swimming). | A verdict that doesn't update when UV climbs through the morning. The prototype calculates **at fetch time** and the sub-line says "Recalculate as UV changes." For Maya, that subline is doing a lot of work — she **will** open the app twice (pre-swim and post-warmup) and expects the new fetch to be honored. **[Design directive: make "Refresh UV" obvious. Today re-tapping "Use my location" does it; Linka, consider an explicit "Refresh" affordance on the verdict card.]** |
| **P3 Devon** | The minutes at his **planned hiking UV** (which is not his current at-home UV in February). He needs a "what-if" — but per the prototype it's location-driven. He'll use the URL hash or the debug `?uv=` query string at home, which only works because he's technical. The non-technical version of Devon won't have a path. **[Design directive — soft, not v1: an explicit "Try a different UV index" affordance helps Devon AND helps the App Store reviewer understand the app.]** | Test multiple Fitz × SPF × UV combinations to plan his gear. | A verdict that pretends to be live forecast advice when he's not at the location. (It is not — but Devon is sophisticated enough to know that.) |
| **P4 Asha** | The verdict number AND, **adjacent to it**, a clear reachable affordance to recheck "is this estimate appropriate for me?" Today the only re-access point for the disclaimer copy is the About modal in the footer. From the verdict card, Asha needs **one tap** to re-read the photosensitization caveat. | See the number, then immediately mentally **divide it** by some factor she's learned from her body. (Verbatim from her cohort: *"I was literally only in the sun for about 5 minutes while watering the garden and my stupid scalp got burnt."*) | A verdict so confident it overrides her body's signal. Verdict copy must remain **"Estimated"** and **"Model estimate"** — both currently present. Hold this line. |
| **P5 Tomás** | The minutes, in **giant numerals**, readable at 12 mph through polarized sunglasses at noon-direct-sun. | Glance and decide whether to top up sunscreen. | A verdict that requires reading. Tomás reads two things: **the number** and **the color**. Everything else is wasted screen real estate. |

**Design directives to Linka:**
1. **The minutes number deserves Dynamic Type largest-allowed treatment.** Current `font-size: 1.05rem` for `.result-main` is too small for an iOS verdict screen. On iOS, the minutes integer alone should probably be ~48–64pt depending on Dynamic Type setting.
2. **Tier badge color is the second readable signal.** Make sure the color contrast holds at WCAG AAA for Tomás's outdoor sun-glare scenario. Current `tier-mod` is `background: #fff3cd; color: #664d03;` — that's fine indoors; outdoors at noon it's hard to read. Push contrast.
3. **A reachable "About this estimate" affordance on the verdict card itself.** Plunder and I both need this for Asha. Footer-only About is not enough. (See §6 below for the persona-keyed visibility pattern.)
4. **Refresh affordance.** Maya pulls down to refresh; Tomás taps once. Both expect a re-fetch path more obvious than "tap the location button again."
5. **Reapplication reminder is NOT a v1 timer.** The launch plan correctly defers this. But verdict copy *"Reapply sunscreen every 2 hours regardless of timer"* in the footer is doing real work for Tomás. Don't lose it.

---

### 1.6 About & Citations modal

Today: Fitzpatrick 1988, Diffey 1991, CIE S 007/E-1998, Open-Meteo CC BY 4.0. (Note: per D-2026-05-19-004, iOS will swap Open-Meteo attribution for WeatherKit attribution. Plunder owns the new copy.)

| Persona | Needs to see | Needs to do | Needs to avoid |
|---------|--------------|-------------|----------------|
| **P1 Greta / "Methodologist" cohort (BPL forum)** | The citations. They will read them. Verbatim from the launch plan, this is the gate for the BPL persona. | Open once. Possibly verify the citations elsewhere. | Citations that look like marketing ("based on the latest dermatological science"). The current concrete citation list is right. Keep the years. |
| **P2 Maya** | Light interest. The model's limits (SPF-protection ceiling, water effects on sunscreen) are her area of unmet need. **[Design directive: a "Limits of this estimate" section in About is high-leverage for Maya. Wheeler can advise on wording.]** | Open if she's curious. | A claim that the model accounts for water exposure (it doesn't — sunscreen behavior in salt water is a known model gap and outside Fitzpatrick × SPF × UV). |
| **P3 Devon** | Same as Greta — methodology. | Open once, then move on. | Citations softened by marketing language. |
| **P4 Asha** | The photosensitization caveat. **This is the most important About content for her cohort and is currently missing.** Add a sub-section titled *"When this estimate may not apply"* with: photosensitizing medications (cite category: isotretinoin / tetracyclines / hydroxychloroquine — but per Plunder's "no medication names" instinct, **describe by category, not brand**), recent dermatologic procedures, photosensitive skin conditions (lupus, vitiligo, albinism), pregnancy melasma, infants. **Wheeler must approve final wording — flagged in D-2026-05-19-007.** | Read carefully. Use it as input to her own judgment. | Wording that implies the app diagnoses or treats anything. We don't. |
| **P5 Tomás** | Never opens this. | N/A | N/A |

**Design directives to Linka:**
- **Add a "When this estimate may not apply" sub-section.** This is Wheeler's call on wording, but it lives in your IA. (Cross-ref: D-2026-05-19-007.)
- **Anchor-linkable About sections.** When the disclaimer modal says "see About," the deep-link should land Asha directly on the "When this estimate may not apply" anchor. Not the top of About.
- Keep the citation list concrete (Fitzpatrick 1988, Diffey 1991, CIE S 007/E-1998). The methodologist personas want years and IDs.

---

### 1.7 Footer disclaimer (always-on)

Currently: *"Model estimate only. Not medical advice. Reapply sunscreen every 2 hours regardless of timer."* Plus the Open-Meteo attribution and an About link.

| Persona | Notes |
|---------|-------|
| **P1 Greta** | Reads it once on first run, never again. Fine. |
| **P2 Maya** | The "reapply every 2 hours" line matches her lived experience. Keep it. |
| **P3 Devon** | Same as Greta. Reads once. |
| **P4 Asha** | **The most important always-on copy for her.** "Not medical advice" is the safety phrase. Do not soften, do not collapse into an icon-only footer. |
| **P5 Tomás** | "Reapply sunscreen every 2 hours regardless of timer" is the **headline** behavior for him. His JTBD is reapplication cadence. Keep it visible. |

**Design directives to Linka:**
- Footer stays. Don't collapse to an icon. Don't put it behind a "ⓘ" tap.
- On the verdict screen specifically, the footer should be **immediately under** the verdict card, not at the bottom of the scroll. On a tall iPhone screen with one verdict card, this is already fine; on iPad or on a future "show history" screen this may break.

---

### 1.8 Error / edge states

The prototype's error paths today:
- Location denied → `Location error: ${err.message}` (raw)
- Fetch fails → `Could not fetch UV data: ${err.message}`
- UV = 0 → `UV index is 0 — no erythemal irradiance detected at this time.`
- No selection (skin type or SPF) → no result card shown
- Very high estimate (e.g., Fitz VI + SPF 70 + UV 1) → "Long" tier, large number

| Edge state | What each persona needs |
|------------|--------------------------|
| **Location denied** | All personas need a humane retry path. P3 Devon needs a "I want to plan for a different place" affordance — even if it's an "iOS only: not in v1" note for now. **The current raw error string is a bug.** |
| **No UV data (API down)** | Show **the last known UV** with a timestamp; do not pretend the calc is current. The prototype reads `lastCoords` (line 603) but does **not** cache `lastUV`. Linka, please advocate to Kwame for a `lastUV` cache with explicit "from 14 minutes ago" labelling. |
| **UV = 0 (night / pre-dawn)** | The current "no erythemal irradiance detected" is dry but correct. Tomás the **dawn alpine starter** (a P3/P5 hybrid) opens the app at 5:30 AM with UV 0 and wants the app to say *"UV will rise above 1 at 06:48 — set a check-in then."* This is a v1 nice-to-have, not a requirement. **[INFERRED]** |
| **Very high estimate** | Fitz V or VI under low UV will produce estimates like "Long — ~480 minutes." For Fitz VI users, the verdict needs to **not** read as "you're invincible." Wheeler caveat applies — but at the UX level, the **tier badge cap at "Long" is correct**; do not show numerals like "480 minutes" because that invites users to interpret it as a literal stayable time. **[Design directive: cap displayed minutes at, e.g., "240+ minutes" with a "Long" tier — the integer beyond ~4h is meaningless for any real-world session.]** |
| **Very low estimate** | Fitz I + UV 11 + no SPF = ~3 minutes. The "Short" tier is correct but the verdict should be **borderline alarming** — visually arrest the user. Color contrast should be the strongest at this end. |

**Design directives to Linka:**
- Replace raw error strings with humane copy.
- Cap "Long" tier display at a sane upper bound (e.g., 240 min, or "4+ hours"). Don't display "480 minutes" — it's mathematically right and behaviorally wrong.
- Cache `lastUV` (with timestamp) so the verdict screen is never empty after a one-time fetch. Privacy implication: `UserDefaults` is OK for UV index value (not health data); confirm with Plunder.

---

## 2. JTBD per major flow

What is the user **hiring** the app to do? And what would cause them to **fire** it?

### 2.1 First-time setup

**Hired to:** "Set me up so I never have to set up again. Remember my skin type so I don't re-input it."

Tension: We **cannot** remember the skin type persistently — it's special-category-adjacent and Donatello M7 forbids `@AppStorage`/`UserDefaults` storage. So the user **will** re-input on every cold launch on iOS (the web prototype's URL-hash trick doesn't have an iOS equivalent we'll use). This is a known friction tax.

**Fired if:** the setup flow is longer than ~3 taps. We are currently at 2 taps (Fitz + SPF) + 1 location grant = 3. We're right at the line.

**Design directive to Linka:** the iOS-side cold-launch re-entry IS the privacy tax. Make it feel **fast**, not annoying. Possible: the first card on cold launch is the Fitz picker, pre-positioned at the user's last (in-memory? — gone after kill) selection. **Don't pre-select Fitz III** on a fresh memory.

---

### 2.2 Daily check ("am I going to burn?")

**Hired to:** Convert the abstract "UV index 8" into "I have 22 minutes." This is the verbatim core promise (u/Sungirl1112 lives this).

**Fired if:**
- The number is wildly inconsistent with the user's body memory (Asha lives here: the model says 60 min, her body says 15 min, the app is gaslighting her). → Disclaimer placement and About prominence rescue this.
- The location/fetch takes more than ~5 seconds (Tomás).
- The verdict is hedged into uselessness ("we cannot estimate"). The current copy is **not** hedged into uselessness — keep it that way.

**Design directive to Linka:** the daily check IS the app. Optimize for it ruthlessly. Greta + Tomás's combined preference: **less than 5 seconds from app-open to verdict on a warm launch.**

---

### 2.3 In-the-moment reapplication reminder

**Hired to:** *(by P5 Tomás specifically)* Confirm "yes, you should re-grease now" or "no, you've got 40 more minutes."

**Fired if:** the app tries to **own** reapplication via timers/notifications. The launch plan correctly defers this (no push notifications in v1, line 274). **Keep this guardrail.** Tomás's JTBD is **served by re-opening the app** (a behavior he's already comfortable with), not by the app pinging him.

**Design directive to Linka:** No reapplication timer UI in v1. The footer line *"Reapply sunscreen every 2 hours regardless of timer"* is doing the right thing — it informs without owning. Hold the line.

---

### 2.4 Kid / dependent monitoring

**Hired to:** *(by Parent-of-pale-child Priya, who is **not** a launch persona but will arrive at the App Store)* Tell Priya whether her 4-year-old can stay at the splash pad for another 20 minutes.

**Fired if:** the app tries to take Priya seriously as a pediatric tool. Per Plunder/launch-plan, **no children-targeted features**, **no pediatric guidance**. We will say in the disclaimer "For children, consult a pediatrician" (already present in the first-launch modal, line 262) — and that is the maximum we go.

**Design directive to Linka (and a flag for Plunder):** Priya **will** still try to use the app for her kid, putting Fitz I and ignoring the pediatric caveat. The UI cannot prevent this. What the UI **can** do is make sure the "For children, consult a pediatrician" line is **not buried in a wall of legalese**. Pull it to its own short line in the disclaimer modal. Currently it's the last clause of a 90-word paragraph (line 262). One-sentence isolation is much easier to read.

---

### 2.5 Edge-condition: post-laser, Accutane, photosensitizer, lupus, vitiligo, albinism

**Hired to:** *(by Asha and her cohort)* Tell them honestly that the model **may not apply to them.**

**Fired if:** the model presents a confident number that contradicts their lived experience without any caveat reachable from that screen. This is **the** safety-critical fire condition for the whole app. (D-2026-05-19-007 captures it.)

**Design directives to Linka:**
1. The verdict card must have a one-tap reach to the "When this estimate may not apply" About section.
2. The first-cold-launch modal must surface the photosensitization category in the **first line** of body text, not buried in clause 7.
3. **Wheeler-flagged item:** consider whether the verdict card itself should carry a one-line *"If you take photosensitizing medications, this estimate may overstate your safe time."* This is a Wheeler decision, not mine; my role is to surface that the persona need is real and persistent.

---

## 3. Mental-model traps — where the user's model diverges from the math

Linka, design copy and flow have to **gently correct** these without preaching. The user must come away thinking "of course" — not "you condescended to me."

| # | User's (wrong) mental model | What the math actually says | Where this hurts in the prototype | Design move for Linka |
|---|------------------------------|------------------------------|-----------------------------------|------------------------|
| **MMT-1** | "SPF 30 + SPF 30 sleeves = SPF 60." | SPF is **not additive**. The higher-rated layer dominates and reapplication math is complex. | Maya's face/body mismatch (§1.3). | Don't show an explicit SPF math UI in v1. The chip row is single-value by design. If a user asks "what if I add a sun hat" — defer to About copy ("Hat and shade extend protection in ways this calculator does not model"). |
| **MMT-2** | "UV index 3 means I won't burn." | UV index 3 burns **Accutane Asha** at 5 minutes. UV index 3 also burns Fitzpatrick I users on long exposure. The UV index ≠ a safety threshold. | The Tier badge (Long/Mod/Short) reinforces a categorical-feeling threshold. | Tier badge is **per-user**, not per-UV. The current implementation honors this (Fitz I + UV 3 + no SPF → "Short"). Keep it that way. Never label the **UV index itself** as "low/moderate/high" in the verdict copy. |
| **MMT-3** | "Skin type = ethnicity." | Skin type is a **burn-and-tan behavioral classification**, validated against the user's history. Many users with darker skin tones are still Fitz III–IV in burn behavior. | The Fitzpatrick descriptions still lean on skin color in rows V and VI (§1.2). | Re-order each description: behavior first, color second. Add a tiny "Not sure? Pick the row that best matches **what your skin does**, not what color it is" hint above the grid. |
| **MMT-4** | "Cloudy = safe." | Cloud cover may reduce UV by ~10–25% but UV burns through clouds. Snow reflects ~80%. Water reflects ~10%. Altitude adds ~4% per 300m. | The verdict uses live UV from the API, which already includes cloud cover. The user doesn't necessarily know that. | Don't try to explain it in the UI. **Do** consider, in About, a short "Why this number changes with weather" line so the methodology-curious know we're not ignoring clouds. |
| **MMT-5** | "Tanning protects me from future burns." | A "base tan" provides ~SPF 2–4 equivalent at most. The model does not encode prior exposure. | The Fitzpatrick choice is **trait, not state**. The user who says "I tanned last week so I'm OK" is mis-modeling. | Don't try to fix this with copy in v1. It's outside the JTBD. Just make sure the disclaimer's "skin response varies" carries it. |
| **MMT-6** | "More SPF = linearly more time." | SPF 30 → 30× MED; SPF 50 → 50× MED. The math is linear in the model but **diminishing returns** in reality because no one applies the recommended 2 mg/cm². | The calculator multiplies linearly by SPF (line 390). This is the standard MED-extension formula. The disclaimer covers the gap. | Don't try to model under-application in v1. **Do** make sure the chip row doesn't visually escalate (e.g., color-coded chips suggesting "70 is best"). Currently it doesn't. Keep it neutral. |
| **MMT-7** | "Sunscreen on a swim lasts as long as the bottle says." | Most sunscreen washes off in 40–80 minutes of water exposure. Maya's lived experience. | Not modeled. | About copy: "This estimate assumes sunscreen is on the skin. Water, sweat, and toweling reduce its effective time." |

**Cross-team note to Wheeler:** I am proposing About copy in MMT-2, MMT-3, MMT-4, MMT-7. Each of those is a claim about UV behavior or sunscreen behavior, and you should sanity-check the wording before Linka renders it.

---

## 4. Accessibility-relevant user contexts

Where will users be when they open this? Each context drives Dynamic Type, contrast, target size, haptic, reduce-motion choices.

| # | Context | Primary persona | Design implication for Linka |
|---|---------|------------------|------------------------------|
| **AC-1** | **Direct sun / noon glare** | Tomás, Devon, Maya | Highest contrast tier color (push WCAG AAA, not AA). Largest legal Dynamic Type for the minutes integer. **Avoid pale backgrounds** for the verdict — `#fff3cd` (current `tier-mod`) at noon is washed out. Consider darker badge fills with light text. |
| **AC-2** | **Wet hands (post-water, post-swim)** | Maya | Touch targets ≥ 52pt. iOS-native large hit-zones on the Fitz picker rows. Avoid any swipe gesture — wet swipes misfire. |
| **AC-3** | **Gloves (snow / ski / alpine)** | Devon's winter cohort, **[INFERRED]** ski-tourer | Touch targets ≥ 60pt for gloved use. Avoid any small icon-only buttons. The current About link is a small text underline — acceptable for a low-frequency action, not acceptable for the location button (which is already large). |
| **AC-4** | **Sweat on screen / running motion** | Tomás | Same as wet hands. Plus **reduce-motion** sensitivity: any "spinner that pulses while UV is fetching" should respect `prefers-reduced-motion`. |
| **AC-5** | **One-handed (carrying a kid, holding a tube of sunscreen, on a leash)** | Priya (parent), Tomás | Critical interactions should be reachable in the iPhone-thumb zone (bottom 1/3 of screen). Currently the location button is mid-screen and the Fitz/SPF cards are above it. On the iOS port, **invert the order**: location button at the bottom (sticky-friendly), Fitz/SPF above. Or use a sticky footer button. |
| **AC-6** | **Motion / running** | Tomás | Verdict must be readable in a glance (≤ 1 second). The minutes integer dominates. Tier color second. Everything else is sub-text. |
| **AC-7** | **Low light (dawn alpine start)** | Devon, alpine cohort | Dark mode must work. The current prototype is light-only (`--bg: #f8f9fa`). iOS port needs full dark-mode tokens. |
| **AC-8** | **Polarized sunglasses** | All outdoor personas | Polarization can interact badly with OLED displays and cause rainbow patterns. Test on iPhone 14/15 OLED through polarized lenses **before launch**. (This is an iOS-specific test Kwame should do; Linka, please flag it in the design spec.) |
| **AC-9** | **VoiceOver / screen reader** | **[INFERRED]** low-vision users | Tier badge color is meaningless to a screen reader. The verdict line *includes* the Fitzpatrick + SPF + UV recap, which is good for VoiceOver. Make sure the badge has an `accessibilityLabel` like "Tier: moderate." |
| **AC-10** | **Dynamic Type at largest setting** | All personas (esp. older users) | The minutes integer should scale with Dynamic Type. The disclaimer text in the footer should also scale — at the largest setting, the footer may overflow. Plan for it. |

**Design directive synthesis for Linka:** Optimize for **AC-1 + AC-2 + AC-6 simultaneously** (direct sun, wet hands, motion). That's the worst-case ergonomic context and most of the personas hit at least two of those.

---

## 5. Competitor friction points — directives for Linka

I'm pulling from prior persona research where I have it (QSun and dminder are documented in the launch plan; EltaMD UV and Sunshine are less covered in my prior pass). Where I don't have a verbatim citation, I mark **[INFERRED from category pattern]**.

| App | Documented friction | Real-user complaint or pattern | Design directive for our app |
|-----|---------------------|---------------------------------|------------------------------|
| **QSun** | Subscription gate on the burn-time calculation. | "*the free version shows you the UV index... and then locks the burn time calculation — the only feature I actually want — behind a $2.99/month subscription. Deleted.*" (Stage 1 SunburnedSailor — reconstructed; pattern is real per r/Ultralight discourse.) | **Never gate the verdict.** Don't tease, don't blur, don't soft-paywall. We are the anti-QSun. |
| **QSun** **[INFERRED]** | Onboarding asks for too much (skin assessment quiz, age, etc.) before delivering value. | Onboarding-bloat is the dominant pattern in subscription-monetized health-adjacent apps. | **One-screen onboarding.** Fitz + SPF + Location. No quiz. No "create an account." No marketing tour. The current prototype already honors this — hold the line. |
| **dminder** | Conflates "Vitamin D time" with "Burn time" — the same app does both, and which one is showing can be unclear. **[INFERRED from category positioning; dminder's primary JTBD is Vitamin D, not burn]** | Users in the dminder cohort sometimes want a burn timer and find themselves reading Vitamin D copy. | **Single-purpose.** UV Burn Timer is **only** the burn timer. Do not creep into Vitamin D synthesis time (which is a different physiological calculation and a different JTBD). Resist the "we could add..." impulse. |
| **EltaMD UV** **[INFERRED]** | Brand-tied app — feels like sunscreen advertising. | Users who don't buy EltaMD sunscreen feel the app isn't for them. | **Brand-neutral.** Don't recommend specific sunscreens by brand. The SPF chip row is correctly brand-agnostic. |
| **Sunshine / Sun-tracker generic apps** **[INFERRED]** | Push notifications for "UV is high" — annoying when the user is indoors. | The launch plan correctly forbids push notifications in v1. | **No push.** Period. (Already a launch-plan guardrail.) |
| **Apple Weather** | UV index shown as an integer 0–11+ with categorical descriptor ("Moderate"), but no **personalized** translation. r/SkincareAddiction (142 upvotes): *"How much do you trust the UV index on the iPhone weather app?"* is the persona-evidence quote. | The latent need is **interpretability** — what does UV 7 mean for ME? | **The personalization is the wedge.** Make sure the verdict copy ALWAYS includes the Fitzpatrick + SPF + UV recap so the user feels the calculation is theirs. The current verdict line does this. Keep it. |
| **Generic outdoor apps with subscription gates** | Anti-subscription deletion ("Deleted." pattern across categories — r/Garmin sarcasm, r/Ultralight filter-order). | All evidence captured in my history.md learning #7. | **Don't gate anything.** Not the calculation, not the citations, not the About content, not a refresh. **No IAP for 90 days post-launch.** (Already a guardrail.) |

**Cross-link:** if Linka wants the deeper competitor UX teardowns (screen captures, flow diagrams), that's a separate piece of work I haven't done — flag if you want me to. For v1 design I think the directives above are sufficient.

---

## 6. Persona-keyed disclaimer visibility — proposed pattern

Cross-ref: D-2026-05-19-005, D-2026-05-19-007.

The tension: P4 Asha **needs** the "Not medical advice / photosensitization caveat" to be highly visible and reachable. P1 Greta does **not** need it on every screen — for her it's noise after the first read.

**We cannot ask the user which group they're in.** Asking would mean collecting medical/condition data, which violates Donatello M7 + Raphael Art.9 + the launch plan's "no health-condition targeting" guardrail.

So the disclaimer cannot be *persona-keyed by toggle*. It has to be **visibility-calibrated to the most-at-risk persona** AND **architected so the lower-risk persona can stop noticing it.**

### Proposed three-layer pattern

| Layer | Behavior | Calibration |
|-------|----------|-------------|
| **L1 — Hard gate** | First-launch modal, dismiss-once-per-session. Currently implemented. **No "don't show again."** Donatello M1 verbatim. | Asha sees it every time she cold-launches the app — exactly right. Greta sees it on every cold-launch — slightly annoying but tolerable. |
| **L2 — Always-on footer** | Persistent footer with *"Model estimate only. Not medical advice. Reapply sunscreen every 2 hours regardless of timer."* Currently implemented. | Reads as ambient legal copy after a few uses (good for Greta). Stays present for Asha as a constant reminder. |
| **L3 — Contextual deeper-reveal on the verdict card** | **NEW.** A small "**Is this estimate for me?**" inline link directly on the verdict card. One tap → opens About at the *"When this estimate may not apply"* anchor. | Greta ignores it. Asha taps it. Win-win. |

### Why I think L3 is the missing piece

Today, after dismissing L1, the only path back to the photosensitization caveat is:
1. Scroll to the bottom of the screen
2. Find the "About & Citations" button in the footer
3. Tap it
4. Read the (currently very short) About modal
5. Notice that **the photosensitization caveat isn't actually there yet** — it lives only in L1's modal copy

This is too many steps for Asha and the content isn't even there yet. The L3 link, with a deep-link to a new About anchor, solves both problems.

### Phrasing options for L3

I'd run all three by Plunder for claim-language risk:
- **A:** *"Is this estimate for me?"* (open-ended, invites self-check, my favorite)
- **B:** *"When this estimate may not apply"* (more clinical, slightly heavier)
- **C:** *"Conditions and medications that affect this estimate"* (most explicit, possibly too medical-sounding — Plunder probably says no)

My recommendation: **A**, with the deep-linked About section titled exactly B. The link copy is invitational; the destination copy is descriptive.

### Persona prominence summary

| Persona | L1 prominence | L2 prominence | L3 prominence |
|---------|---------------|---------------|----------------|
| **P1 Greta** | Full, once | Ambient | Ignored |
| **P2 Maya** | Full, once | Reads occasionally | May tap once |
| **P3 Devon** | Full, once | Ambient | Ignored |
| **P4 Asha** | **Critical, every cold-launch** | **Critical, always-on** | **Critical, the missing piece** |
| **P5 Tomás** | Skim and dismiss | The "reapply every 2h" half is critical | Probably ignored |

**Directive to Linka:** add L3 (verdict-card "Is this estimate for me?" link). Keep L1 and L2 as they are.

**Flag to Plunder:** L3 introduces new copy and a new IA anchor in About. Both need your review for claim-language safety. Wheeler also owns the **content** of the About sub-section (per D-2026-05-19-007). The pattern is mine; the words are theirs.

---

## 7. Edge-case personas the prototype implicitly assumes away

Walking the prototype with my persona lens. Who does it assume *out*?

### 7.1 Children, monitored by a parent

**Persona:** *Priya, mother of pale-skinned 4-year-old at the splash pad.*

**What the prototype assumes:** The user is the person whose skin is being modeled.

**Where it breaks:** Priya enters **her own** skin type, gets **her own** verdict, and applies it to her child. The math doesn't fit (a 4-year-old's MED is different from an adult's; SPF behavior on a wriggling 4-year-old is different). Worse, Priya may notice the disclaimer says *"For children, consult a pediatrician"* (line 262, currently buried) and feel the app is unhelpful.

**What launch-plan policy says:** We do not build for children. No HealthKit. No pediatric guidance. The disclaimer's one-line deflection is the maximum we go. (Plunder owns this; non-negotiable.)

**Design directives to Linka:**
- Pull the "For children, consult a pediatrician" line out of the dense 90-word disclaimer paragraph into its own visible line.
- **Do not** add a "this is for an adult" toggle. That's a per-user surface and we don't have those.
- Accept that some Priyas will use the app for their child anyway. The disclaimer is the seatbelt; the seatbelt is not bulletproof.

### 7.2 Albinism users (OCA-1, OCA-2)

**Persona:** *"Albinism Aaron," not currently a launch persona; lives implicitly under "Fitzpatrick I" but is a different physiological case.*

**What the prototype assumes:** Fitzpatrick I is the floor of skin sensitivity.

**Where it breaks:** People with oculocutaneous albinism have essentially zero melanin and a MED below Fitzpatrick I's standard ~200 J/m². The Fitz I option in the picker doesn't go far enough.

**Design directives to Linka:**
- We are **not** going to add a "Fitzpatrick 0" or "albinism" option (that's a medical-category step we can't take, and the Fitzpatrick scale itself doesn't extend below I).
- We **should** acknowledge in the About / "When this estimate may not apply" section that "people with albinism may burn faster than Fitzpatrick I estimates." This is a Wheeler-owned wording call.

### 7.3 Vitiligo users (mixed Fitzpatrick on the same body)

**Persona:** *"Vitiligo Vee."*

**What the prototype assumes:** One Fitzpatrick type per user.

**Where it breaks:** A user with vitiligo has patches of unpigmented (effectively Fitz I) skin within otherwise pigmented (e.g., Fitz IV) skin. The single-Fitz selector forces them to choose, and either answer is wrong for half their body.

**Design directives to Linka:**
- Do **not** build a "vitiligo mode." Out of scope for v1, special-category-data risk, and we don't have the science to model patch-area MED.
- **Do** add Vitiligo to the About "When this estimate may not apply" list. The user gets honest disclosure; we don't try to solve their case.

### 7.4 Dark-skin users (Fitzpatrick V–VI) under-served by SPF marketing

**Persona:** *"Fitz V/VI Veronique."* Real research signal — see my history learning re: "Very-dark-skin (Fitzpatrick V–VI) underserved by SPF marketing."

**What the prototype assumes:** The app's verdict copy and Fitzpatrick descriptions speak equally to all six types.

**Where it breaks:** The descriptions for V and VI lean on color-words ("Brown/dark skin", "Dark brown/black skin") in a way I and II don't (which lead with behavior). This is a quiet exclusion signal — a Fitz V user reading the picker may feel the app is "for white people" even though the math works fine for them.

**Design directives to Linka:**
- Rewrite the V/VI descriptions to lead with **behavior**, not color (see §1.2 design directive #4).
- Consider, in About, a one-line affirmation: *"Calculation works for all six Fitzpatrick types. Note that even at high MED, sun exposure causes photoaging and other long-term effects regardless of skin tone."* Wheeler owns the wording on the "still has long-term effects" half — be careful not to drift into medical claims.
- Do **not** show a skin-color swatch. The Fitzpatrick scale is **behavioral**, not racial — and visualizing it with color swatches reinforces a misconception (MMT-3).

### 7.5 Post-laser / post-cosmetic-procedure skin

**Persona:** *"Post-Procedure Pauline."* A user with recently lasered or peeled skin has photosensitized skin similar to Asha's medication-induced case.

**What the prototype assumes:** Skin behavior is stable per Fitzpatrick type.

**Where it breaks:** Skin behavior for ~2–4 weeks post-procedure is dramatically more sensitive.

**Design directives to Linka:**
- Add to the About "When this estimate may not apply" list, alongside photosensitizing medications.
- No UI toggle, no input.

### 7.6 Infants

The launch plan explicitly punts. The disclaimer says "For children, consult a pediatrician." Infants are a sharper version of the same case. The single-line deflection is sufficient and we are not going further. **No design change required.**

### 7.7 Outdoor laborers (construction, landscapers, lifeguards)

**Persona:** *"Lifeguard Luís."* Real population, not in our launch channels. Their JTBD is **shift-long exposure** with limited reapplication opportunities.

**Design directive to Linka:** No design change in v1. Their pattern is similar enough to Tomás's that they're served by the same UI. They'll find us in r/lifeguard or via App Store search if at all — that's Mondo's worry, not yours.

---

## 8. Cross-team flags surfaced by this brief

- **→ Linka (primary handoff):** Everything in §§1–7. The biggest design lifts I'm asking for:
  1. No default Fitz selection (§1.2).
  2. Add the L3 "Is this estimate for me?" verdict-card link (§6).
  3. Add the "When this estimate may not apply" anchor to About (§1.6, §6).
  4. Rewrite Fitz V/VI descriptions to lead with behavior (§1.2 / §7.4).
  5. Cap displayed minutes for "Long" tier at a sane upper bound (§1.8).
  6. Humane error states on location-deny and API-fail (§1.8).
- **→ Wheeler (safety content):** Owns wording for the new About sub-section "When this estimate may not apply" — D-2026-05-19-007 already captures this. Also: review the verbatim wording proposed in MMT-2 through MMT-7 (§3) before Linka renders any of it.
- **→ Plunder (compliance):** L3 link copy and About sub-section claim language need your review. Also: pulling the "For children, consult a pediatrician" line out of the disclaimer paragraph as its own line — confirm that the disclaimer-as-a-whole still satisfies M1 with that structural change.
- **→ Gaia (scope):** Nothing in this brief expands v1 scope. The biggest "new" element is the L3 link, which is a small text affordance + a deep-link anchor. The capped-minutes display and humane error states are bug fixes, not features. If Linka comes back saying any of this requires meaningful new code, I'd want to revisit with you.
- **→ Kwame (iOS dev):** Two specific iOS-side asks surfacing here — (a) a `lastUV` cache in `UserDefaults` (with timestamp) so the verdict screen survives an offline cold launch (§1.8), and (b) confirming the **whole Fitz row** is the tap target, not just the radio button (§1.2). Linka, please carry these to Kwame's spec.
- **→ Argos (monetization):** No conflict. Nothing in here threatens the $2.99 one-time wedge or the 90-day no-IAP rule.

---

## 9. What I'm explicitly NOT producing here

So Linka and I don't duplicate:
- **Visual design tokens** (colors, type ramps, exact spacing) — Linka's call. I gave directional guidance only.
- **Interaction prototypes / wireframes** — Linka's call. I gave persona-level requirements.
- **Apple HIG conformance details** — Linka's specialty, not mine.
- **iOS-specific component choices** (`Form` vs. `List` vs. custom cards) — Linka's call.
- **Animation specs** — Linka's call (with my §4 AC-4 reduce-motion note as input).

If anything in my brief contradicts a HIG pattern Linka knows, **the HIG wins** and I'd like to know about it so I can update my mental model.

---

## 10. Open questions for Linka (no need to wait — just answer in your next handoff)

1. Does the iOS port re-input Fitz on every cold launch? (My read of Casey's spec: yes, per Donatello M7 / Raphael Art.9. Confirm.) If yes, the no-default-selection rule (§1.2) becomes especially important.
2. How does the iOS port handle the cap on "Long" tier display (§1.8)? Is it a copy decision (yours) or a calculation decision (mine + Wheeler's)?
3. Where would you put the L3 "Is this estimate for me?" link on the verdict card visually — top right of the card, below the tier badge, or inline with the sub-line?
4. Any of the §4 accessibility contexts feel under-specified? Tell me which and I'll dig further.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
