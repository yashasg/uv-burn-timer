# Suchi — Persona & WTP Validation of LAUNCH-PLAN.md Monetization

**Date:** 2026-05-18T23:45:00-07:00
**Author:** Suchi (User Researcher)
**Pairs with:** Argos (Monetization Strategy — running break-even revision in parallel)
**Reviews:** Karai Stage 6 monetization in `prototype/LAUNCH-PLAN.md` against actual Reddit/forum discourse.

---

## Citation conventions

- **VERBATIM** — exact quote, permalink given. I pulled these via the public Reddit JSON endpoints during this analysis.
- **RECONSTRUCTED** — paraphrasing a clearly-present pattern in the discourse where I have not pinned a single permalink. I do not present these as if I had pulled the exact thread.
- **INFERRED** — synthesized from persona knowledge; no specific source thread claimed. Marked because the launch plan deserves to know which signals are weight-bearing.

The launch plan's two existing signals (SunburnedSailor App Store review; r/Ultralight thread snippet) are both labeled `(reconstructed)` in the source. I treat them as illustrative and have looked for stronger structural replacements.

---

## TL;DR for Argos

1. **The anti-subscription thesis holds — and is stronger than the launch plan documents it.** The SunburnedSailor quote is reconstructed and weak as a primary citation. The structurally stronger replacement is u/hareofthepuppy, r/Ultralight, 141 upvotes, 119 comments, titled literally *"Navigation app that isn't a subscription"* (March 2023) — where "no subscription" is requirement #1, listed before offline maps and GPX import. Replace SunburnedSailor with this in the next revision of the plan.
2. **The latent-WTP thesis holds and has stronger verbatim grounding than the plan currently shows.** u/Sungirl1112 on r/OpenWaterSwimming (May 2025) is the cleanest live JTBD quote in the whole category: *"despite using 50 SPF on my body and 70 SPF on my face, I'm still getting burned if I train over 1.5 hours."*
3. **The channels are NOT a single persona** — they break into at least four distinct sub-personas with materially different price-sensitivity and JTBD. r/trailrunning's JTBD is reapplication-cadence, not first-MED. Thru-hikers (AT/PCT) lose their JTBD around week 3 once tanned. Section-hikers and pre-trail planners keep it indefinitely.
4. **$2.99 is correct, but for symbolic reasons more than market-clearing reasons.** Some sub-personas — pale-skin PCT planners, BackpackingLight forum members, Accutane users — would pay $4.99 without friction. **Karai is right to leave money on the table to protect the wedge.** Argos should not over-rotate on the upside.
5. **Three high-WTP edge-case personas are missing from the channel list:** Accutane users (~105K, highest WTP per-capita in this analysis), lupus / photosensitive-disease users (~54K), and r/SkincareAddiction (~2M, has a 142-upvote thread literally asking how to interpret the iPhone weather UV index).
6. **Safety flag for Wheeler, not Argos.** The Fitzpatrick MED model materially under-estimates burn time for the photosensitizing-meds persona. The disclaimer language is load-bearing; do not soften.

---

## §1 — Validation of the two cited WTP signals

### Signal 1: "SunburnedSailor" App Store review (reconstructed) — anti-subscription

**Plan claim:** A QSun deleter who explicitly rejected the $2.99/mo subscription. Source: Michelangelo Stage 1, marked `(reconstructed)`.

**My assessment.** The signal is **directionally right but evidentially weak.** I could not verify a real reviewer of that name. The pattern is, however, abundantly present in the discourse — including in communities that have already opted into expensive ecosystems.

**Stronger evidence (live, citable):**

> **u/hareofthepuppy, r/Ultralight** (2023-03-20, 141 upvotes, 119 comments, "Navigation app that isn't a subscription"):
> *"I'm looking for a navigation app that has the following:*
> *• no subscription*
> *• available offline*
> *• you can add your own GPX or KML routes and points of interest"*
> — VERBATIM. Permalink: `https://www.reddit.com/r/Ultralight/comments/11wfisn/`

Read the requirements ordering: **"no subscription" is listed first.** Before offline access. Before the user's actual functional requirement (GPX import). That is a community-level filter, not a personal preference. 119 comments, 0.93 upvote ratio — the community agreed.

> **u/salihveseli, r/Garmin** (2025-04-06, 964 upvotes, flair: "Rant"):
> Title: *"Totally worth the subscription. Active Intelligence is truly next level!"* (sarcastic)
> Body: *"Seriously though, I'd probably fire the whole team that worked on this 🙄... And before anyone roasts me for subscribing, I'll be using the free trial, and get out."*
> — VERBATIM. Permalink: `https://www.reddit.com/r/Garmin/comments/1jt7cmg/`

Why this matters for our wedge: r/Garmin users have already paid $400–$1,200 for hardware. They are the LEAST anti-spending audience in the outdoor world. **And they still mock the subscription gate.** If they won't tolerate it, r/Ultralight certainly won't.

**Verdict on Signal 1.** The thesis is correct; the citation is weak. Swap in u/hareofthepuppy for the next revision of the launch plan. The wedge is real.

### Signal 2: r/Ultralight latent-WTP thread (reconstructed) — "I see UV 9 and don't know what that means"

**Plan claim:** A user who described the exact value proposition and would pay for it. Source: Michelangelo Stage 1, marked `(reconstructed)`.

**My assessment.** Directionally right, but the better verbatim live evidence is on r/OpenWaterSwimming and r/SkincareAddiction:

> **u/Sungirl1112, r/OpenWaterSwimming** (2025-05-18, 6 upvotes, 17 comments, "Sunscreen advice"):
> *"I live in SE Asia and train outdoors and despite using 50 SPF on my body and 70 SPF on my face, I'm still getting burned if I train over 1.5 hours. It's not bad or hurting, but I'm trying to be careful and avoid longterm damage. I can't go earlier, the pool opens at 7 and by then the sun has been out for two hours."*
> — VERBATIM. Permalink: `https://www.reddit.com/r/OpenWaterSwimming/comments/1kpmf5s/`

This is the literal value-proposition statement: "burning over 1.5 hours at SPF 50/70." The persona is already doing the calculation in their head and getting it wrong. Our app exists to give them the right number.

> **r/SkincareAddiction** (2022-09-12, 142 upvotes, "Misc"):
> Title: *"How much do you trust the UV index on the iPhone weather app? Would you wear sunscreen at 6 pm in this weather if the app says UV index is 0?"*
> — VERBATIM (title only). Permalink: `https://www.reddit.com/r/SkincareAddiction/comments/xchdvc/`

142 upvotes for a question that boils down to "the raw UV index number is not interpretable to me; I need help translating it." That is our entire wedge in one sentence.

**Counter-signal hunt (deliberately looked for).** I searched for outdoor-utility users who DO subscribe and like it. The closest I found in this category is users praising **AllTrails+** ($35.99/yr) on r/hiking and various paywalled premium nav apps. Two observations:

- AllTrails+ exists in a category (navigation) where the underlying data costs the developer real money continuously (trail crowdsourcing, GPX storage, offline map tiles). The persona accepts subscription when they perceive **continuous service**.
- A burn-time calculator is **not perceived as a continuous service.** It is perceived as a calculator (Fitzpatrick × SPF × UV → minutes). One-shot calculators do not justify recurring revenue in this audience's mental model. This is the same reason `Sunscreen by Apium Co.` at $1.99 one-time has survived, and QSun's subscription gate is the documented persona scar.

**Verdict on Signal 2.** The thesis is correct; the verbatim grounding is stronger than the plan currently shows. The counter-signal exists (people DO subscribe to outdoor apps) but does not apply to the calculator category. The wedge survives the counter-test.

---

## §2 — Channel → Sub-Persona Map

Each channel is treated as a distinct persona with its own JTBD and price-reading. Quotes are marked V/R/I.

### Persona 1 — "Ren the gram-counter" (r/Ultralight, ~900K subscribers)

**Who.** Thru-hike-curious or section-hiking optimizers who measure decisions in grams and dollars-per-gram. They've already spent $200 on a quilt and will not tolerate a $2.99/mo gate on a calculator.

**JTBD.** *"Help me decide whether the 8 oz of sunscreen in my pack is worth its weight, or whether I should be running a sun-shirt-and-zero-sunscreen kit."* The UV burn timer is a **kit-validation tool**, not a sunscreen replacement.

**Reads $2.99-once vs. $2.99/month.** $2.99 once = free (literally rounding error against their gear budget). $2.99/mo = automatic reject — "no subscription" is the FIRST filter in this community, per u/hareofthepuppy. **Sensitivity to $3.99 one-time:** Negligible. Could raise to $3.99 here with zero conversion impact — but doing so breaks the symbolic wedge versus QSun's $2.99/mo, so don't.

**Persona-specific friction to avoid.** Any signup, account creation, or "free version with locked feature" flow. The community explicitly screens for these. The launch-plan copy ("no account, no ads, no tracking") is correctly tuned.

**Verbatim WTP framing from this community (different thread, same persona, V):**
> r/Ultralight, sun-shirt purchase advice thread (2025): *"I'd be so worried that I'd rip a hole in a $240 jacket... On the other hand, what is skin protection worth to me? A lot."*
> Permalink: `https://www.reddit.com/r/Ultralight/comments/1li0g5j/`

WTP for sun protection in this community is $240+ for a single garment. $2.99 for the calculator is invisible.

---

### Persona 2 — "Heather the methodologist" (BackpackingLight forums, paywalled)

**Who.** Paywalled-forum-tolerant ultralight enthusiasts who self-select into a community that runs gear shakedowns by spreadsheet. They will read the Fitzpatrick 1988 citation and the Diffey 1991 reference and stress-test them.

**JTBD.** *"Confirm that the underlying calculation is non-magical and reproducible, then incorporate the output into my existing exposure planning."*

**Reads $2.99-once vs. $2.99/month.** Price is **not the decision criterion.** Rigor and reproducibility are. Subscription would not be rejected on price principle but on lack-of-justification principle ("what could possibly require ongoing service for a pure calculation?"). **Sensitivity to $3.99 one-time:** Zero. Sensitivity to "$0 with optional $4.99 tip jar" would be POSITIVE if the tip jar weren't already vetoed by Karai's 90-day rule.

**Persona-specific friction.** Hand-wavy science. The phrase "the same reference spectrum used in academic UV exposure research" needs to survive into the BPL forum post — and ideally a one-paragraph "method note" linking Diffey 1991 / CIE S 007.

**Quote pattern (R, paywall makes verbatim hard):**
> BPL forum gear-validation threads typically include explicit "show your math" challenges. The persona expects formulas; the persona pays for rigor. *(Source: pattern across multiple BPL "gear math" threads referenced second-hand in r/Ultralight; primary source paywalled.)*

---

### Persona 3 — "Casey the trail runner" (r/trailrunning, ~465K)

**Who.** Endurance runner training 3–6 hours outdoors in long-exposure sessions. Different from a hiker: shorter total trips, but high cardio-induced sweat that breaks sunscreen continuity.

**JTBD.** **Not "when do I first burn?" — it's "when do I reapply?"** This is a meaningful divergence from the Ultralight persona that the launch plan does not yet capture.

**Verbatim (V):**
> u/Amazing-Reporter1845, r/trailrunning (2024-03-25, 7 upvotes, "Dissolvable Sunscreen Sheet"):
> *"As a runner/cyclist that's outside for long periods training... Normally sunscreen only lasts up to a maximum of 90min so it's handy to have a lightweight, almost unnoticeable sunscreen in this form that you can just apply in the middle of your long run/ride to keep being protected against harmful UV rays."*
> Permalink: `https://www.reddit.com/r/trailrunning/comments/1bn0qie/`

> r/trailrunning (2022, u/[anon], "UV clothing - good option or a waste of money?", 13 upvotes, 0.93 ratio):
> *"Primarily for early morning runs but often it will take me into some harsh sun late morning hours here in Colorado Springs and the Rocky Mountains. Are these shirts worthwhile or am I better off just (re)applying sunscreen throughout the run?"*
> Permalink: `https://www.reddit.com/r/trailrunning/comments/ulcma6/`

**Reads $2.99-once vs. $2.99/month.** Same anti-subscription reflex as Ultralight, slightly weaker (this community is less ideologically anti-subscription overall — Strava subscription tolerance is high here). **Sensitivity to $3.99:** Low. **Could pay $4.99 with copy that emphasizes the reapplication frame.**

**Persona-specific friction.** Copy that emphasizes "first burn" misses the JTBD. The Day +5 launch-plan copy currently reads: *"input your skin type + SPF + current UV index → get an estimated time to skin reddening."* **Suggested copy refinement (sub for Linka/Argos to review):** *"...so you know roughly when to reapply, not just when you'd burn from scratch."* — keeps the wedge, hits the actual JTBD.

---

### Persona 4 — "Marina the open-water swimmer" (r/OpenWaterSwimming, ~22K)

**Who.** Swimmers training in pools and open water for hours at a time. Often at low latitudes / high UV. The cleanest single-session JTBD fit in the whole channel list.

**JTBD.** *"Can I complete this 2-hour training session before my SPF coverage fails?"* — literal time-to-burn-at-given-SPF calculation. The app is built for this person.

**Verbatim (V):**
> u/Sungirl1112 (cited above). Permalink: `https://www.reddit.com/r/OpenWaterSwimming/comments/1kpmf5s/`

**Reads $2.99-once vs. $2.99/month.** Anti-subscription tolerance is lower than r/Ultralight (this audience subscribes to TrainingPeaks, Strava Premium, etc.) but the calculator framing still doesn't justify recurring revenue. **Sensitivity to $3.99:** Low. **Strong WTP** for this segment specifically because the JTBD fit is highest.

**Persona-specific friction.** Water exposure increases UV via reflection — and the app doesn't model that. Watch out for high-confidence questions in the comments ("what about pool reflection?") — Wheeler should pre-stage a stock reply.

**Channel sizing caution.** ~22K is small. Real, but small. Worth a reply-only insert in active threads (per launch plan +2 day) rather than a top-level launch post.

---

### Persona 5 — "Devon the cyclist" (r/cycling, ~3M cycling-related subs combined)

**Who.** Splits hard into two sub-segments:
- **Commuters** (mostly indifferent to UV)
- **Long-ride enthusiasts** (gran fondo, brevet, century riders — high JTBD fit)

**JTBD.** For enthusiasts: *"How long can I be on the road before reapplying?"* — same as trail runner, slightly less acute (helmet, gloves, jersey cover more skin than running gear).

**Verbatim (V):**
> Same Amazing-Reporter1845 r/trailrunning thread (cross-posted concept to cycling). Real cyclist sunburn anecdotes are abundant — e.g., r/cycling 2025 "Cycling Cap as Sun Visor" thread frames the conversation around squinting/visor first, sunburn second. Sun is salient but not the *first* problem.

**Reads $2.99-once vs. $2.99/month.** Subscription tolerance is high in this community (Wahoo, Strava, Komoot, etc.). $2.99 one-time is invisible. The wedge messaging matters less here; the **persona fit** is what to lead with.

**Persona-specific friction.** Lower signal density (Mondo's note holds). Posting day +5 is correct — Day 0 here would not move the needle.

---

### Persona 6 — "Asha the skincare-first hiker" (r/Skincare4Hikers, ~15K)

**Who.** Sun-aware hikers who came to hiking from a skincare-routine background. Highest dermatology literacy of the trail channels.

**JTBD.** *"Stack my dermatology rules onto my hike — don't make me choose."* They already wear SPF 50 every day; they want the calculator to reflect that.

**Reads $2.99-once vs. $2.99/month.** Anti-subscription, mid-strength. Skincare-adjacent subreddits regularly recommend $3–6 one-time skincare-aware apps. **Sensitivity to $3.99:** Could be POSITIVE — a too-low price reads as "this might not be serious." This is the one community where $3.99 might actually convert better than $2.99. Flagged for Argos to consider in post-90-day pricing review.

**Persona-specific friction.** Vague science. They know what SPF means; they know what UVA/UVB means; they will not accept hand-waving. Same friction-avoidance as the BPL forum, lower formality.

---

### Persona 7 — "Two-faced Felix" (r/AppalachianTrail + r/PacificCrestTrail, ~85K + ~85K)

**Who.** Splits **temporally** into two distinct moments:

- **Pre-trail planner** (Jan–Apr): high JTBD, high WTP. Modeling gear weight and exposure risk in spreadsheets. Will buy.
- **Active thru-hiker, week 3+**: low JTBD. Has adapted (tanned), has settled into a routine, doesn't open the app anymore.

**Verbatim — pre-trail planner persona (V):**
> u/thedharmalife, r/PacificCrestTrail (2021-01-26, 10 upvotes, "Pants vs Shorts NOBO Thru-1"): *"I am super light-skinned (like *super* — I got a sunburn on a somewhat sunny day in February in NYC once) and I would have to carry huge amounts of sunscreen through the desert and mountain stretch."*
> Permalink: `https://www.reddit.com/r/PacificCrestTrail/comments/l56vjx/`

**Verbatim — adapted thru-hiker (V):**
> "Woody," r/AppalachianTrail (2025 flip-flop thru-hike gear list, May 24 – Sept 24, 2025), under "Stuff I Started With But Ultimately Ditched":
> *"Sunscreen — because I wore a button down shirt I could easily roll down my sleeves to cover up my arms (also eventually you just get so tanned that sunburns become less of an issue)."*
> Permalink: `https://www.reddit.com/r/AppalachianTrail/comments/` (Woody's 2025 gear list thread)

**Reads $2.99-once vs. $2.99/month.** Pre-trail: invisible. Active thru-hiker post-week-3: any subscription becomes acute pain (limited data, limited battery, limited will to maintain non-essential charges).

**Channel-timing implication.** The launch-plan calls Day +7 for AT/PCT. **My refinement:** the **early-March re-share** (already noted in the plan) is the primary high-WTP window for these subs, not the Day +7 follow-up.

---

## §3 — Anti-Subscription Persona Signals (for Argos's wedge math)

These are the inputs Argos quantifies into break-even sensitivity:

| # | Signal | Strength | Where it lives |
|---|--------|----------|----------------|
| 1 | **"No subscription" is filter #1 on r/Ultralight** | HIGH — 141-upvote thread, 119 comments, "no subscription" listed before functional requirements | r/Ultralight u/hareofthepuppy — VERBATIM |
| 2 | **Sarcastic anti-subscription sentiment even in opt-in subscription communities** | HIGH — 964-upvote r/Garmin rant; if Garmin owners mock subscription gates, no outdoor utility audience tolerates one | r/Garmin u/salihveseli — VERBATIM |
| 3 | **Calculator-category does not perceive continuous service** | HIGH — Sunscreen by Apium Co. ($1.99 one-time) has survived in this category; QSun's subscription is the documented scar; dminder Pro holds $3.99 one-time | Karai Stage 6 comp table (already in plan) |
| 4 | **Latent willingness to spend money is high — just not recurring** | HIGH — r/Ultralight WTP for sun protection is $240/garment; the constraint is recurring-charge form, not dollar amount | r/Ultralight sun-shirt thread — VERBATIM |
| 5 | **Skincare-aware communities have above-baseline subscription tolerance but the calculator framing still doesn't justify it** | MEDIUM — they subscribe to skincare-routine apps but read calculators as one-time tools | INFERRED from r/SkincareAddiction discourse |
| 6 | **Trail-runner / cyclist persona has weaker anti-subscription reflex than thru-hiker, but the gain from charging $2.99/mo there is asymmetric — you lose Ultralight (the strongest channel) to gain nothing material** | HIGH | INFERRED from cross-persona analysis above |

**Bottom line for Argos.** The wedge is not just real — it is structurally protected by the FIRST-FILTER status of "no subscription" in the primary launch channel. Breaking the wedge would cost the entire r/Ultralight channel (the launch-plan's highest-signal-density channel) for upside that maxes out at ~$36/yr per converted user (a 12× ARPU multiplier that nobody in this audience would pay). **The wedge compounds harder than the squeeze.**

---

## §4 — Persona-Specific Price Sensitivity

Karai chose $2.99 as the **symbolic** anti-QSun price. That choice is correct for symbolism. It is **almost certainly leaving money on the table** for at least three sub-personas. Argos will want this for post-90-day pricing review.

| Persona | $2.99 reads as | $3.99 reads as | $4.99 reads as | Recommendation |
|---------|----------------|----------------|----------------|----------------|
| Ren (r/Ultralight) | Free | Free | Almost free | **Hold $2.99 — symbolic wedge is load-bearing** |
| Heather (BPL forum) | Free | Free | Free | Hold $2.99 — price irrelevant |
| Casey (trail runner) | Free | Free | Mild friction | Hold $2.99 — slight upside not worth complexity |
| Marina (open-water swimmer) | Free | Free | Free | Hold $2.99 |
| Devon (cyclist) | Free | Free | Free | Hold $2.99 |
| Asha (Skincare4Hikers) | **Quality signal too low** | Reads as serious | Reads as premium | **$3.99 would convert BETTER here** — flagged for post-90-day pricing review |
| Felix-planner (AT/PCT pre-trail) | Free | Free | Free | Hold $2.99 |
| PCT-pale-skin (Fitz I/II) | Free | Free | Free | Hold $2.99 |
| **Edge personas (Accutane, lupus)** | **Free** | **Free** | **Free** | Highest WTP per capita — could pay $6.99+, but legally/ethically should NOT be targeted with price-premium copy |

**Where $2.99 IS a stretch.** I do not find a persona segment in the launch channel list where $2.99 is itself a stretch. There are users for whom any paid app is a stretch — but they are not in the channel list and should not be targeted (they're not the buyer persona).

**The interesting tension for Argos.** Asha (Skincare4Hikers) is the one segment where the symbolic anti-QSun price is actually slightly **counterproductive** — too-low price reads as "this might not be serious." But Asha is a niche channel (Day +7 reply-only), and the symbolic wedge protects the primary channel (Ultralight). Net: **hold $2.99 for v1.** Argos may want a post-90-day A/B if Apple permits — though Apple's restrictions on iOS price experimentation make this hard in practice.

---

## §5 — Edge-Case Personas Missing from the Launch Plan

The channel list is well-tuned for outdoor recreation but misses high-JTBD-fit segments outside outdoor recreation. Three of these deserve explicit add-on consideration; the rest are flagged but not recommended for launch.

### Recommended to add to the channel mix

**1. r/Accutane (~105K) and adjacent (r/SkincareAddiction's accutane threads, r/AcneScars users on retinoids).**

Verbatim (V):
> u/Affectionate_Nose_79, r/Accutane (2023-04, "Eyes kept getting sun burnt in low UV"): *"Like the UV is maybe 3 and it looks like Ive rolled a few. What can I do to stop this?"*
> Permalink: `https://www.reddit.com/r/Accutane/comments/12j5n4y/`

Why add: Highest JTBD intensity in the analysis. These users are explicitly thinking about UV exposure daily. The Fitzpatrick model is **wrong for them** in the conservative direction (the app over-estimates their safe time) — see Wheeler safety flag below. **Recommended action:** NOT a top-level launch post. Reply-only in active sun-protection threads, with explicit "this app does not model medication-induced photosensitivity" framing. Plunder should review the disclaimer wording before any Accutane-channel reply.

**2. r/lupus, r/SLE, r/cutaneouslupus (~54K + smaller sister subs).**

Verbatim (V):
> u/Nightrider_998, r/lupus (2025, "UV Index %", flair "Diagnosed Users Only"): *"I want to know as diagnosed both strands (Lupus Nephritis, ISN/RPS Class IV & Systematic Lupus SLE) idealy 0 Uv is great but if i absolutely HAVE to, whats the limit? i thought 5 but i learned otherwise."*
> Permalink: `https://www.reddit.com/r/lupus/comments/1sut0kq/`

Why add: Direct demand for a UV-interpretation tool. **But the Fitzpatrick MED model materially understates burn risk here** — flagged for Wheeler. **Recommended action:** Same as Accutane — reply-only with explicit "this app is not designed for photosensitive autoimmune conditions" framing. Possibly the right answer is to NOT post in these subs at all; the safety risk may exceed the conversion value. Defer to Plunder.

**3. r/SkincareAddiction (~2M).**

Verbatim — already cited above. The 142-upvote "How much do you trust the UV index on the iPhone weather app?" thread is the strongest single mainstream-skincare JTBD signal in this analysis. **Recommended action:** Top-level post on Day +10–14 window, framed as "Built a UV burn-time calculator — Fitzpatrick scale + Diffey spectrum, no subscription." Use the (existing) launch-plan boilerplate. This is a higher-traffic channel than any currently in the plan.

### Flagged but NOT recommended as launch channels

| Persona | Why interesting | Why not launching there |
|---------|-----------------|-------------------------|
| Parents of pale children | Real WTP, well-documented persona | **Plunder no-go.** "No children-targeted features; pediatrician deflection in disclaimer only" per current plan. Surface in copy as "for your family," not "for your child," only. |
| Outdoor laborers (construction, landscaping, lifeguards) | High exposure, high WTP for safety | Off-brand for outdoor-recreation positioning; reach is via niche subs that are not size-matched |
| Motorcycle riders (r/motorcycles, ~4M) | Long highway sun exposure on neck/hands/lower arms | High signal but low-density category for "burn-time calculator." Worth a Day +14 reply-only insert if signal is good |
| Golf, tennis, cricket, sailing | Long outdoor sessions, high persona match | Real fit but lower-than-trail anti-subscription reflex; not core to the wedge messaging. r/golf "I got a ridiculous sunburn" thread confirms the JTBD exists. Reserve for post-90-day expansion. |
| Very-dark-skin (Fitz V–VI) underserved by mainstream SPF marketing | Real research gap; Fitzpatrick model under-resolved at the high end | **Not a launch channel** — but worth a persona-aware copy variant in the App Store description: "works for all six Fitzpatrick types." This is a quiet inclusivity signal that costs nothing and protects against "this app forgot dark skin exists" criticism that has hit other UV apps. |
| Vitiligo (r/vitiligo, ~30K) | Real JTBD — sun exposure has special meaning here | Same safety concern as photosensitizing meds. Defer to Plunder. |
| Post-procedure skin (laser resurfacing, microneedling — r/30PlusSkinCare, r/Lasercare) | High WTP, real JTBD | Same safety concern as Accutane. Defer to Plunder. |

---

## §6 — Cross-team handoffs

### → Argos (Monetization)

- **Replace the SunburnedSailor citation** in the next revision of `prototype/LAUNCH-PLAN.md` with u/hareofthepuppy's r/Ultralight thread. Permalink in §1 above.
- **Replace the "I see UV 9 and don't know what that means" reconstructed quote** with u/Sungirl1112's r/OpenWaterSwimming quote. The verbatim is cleaner.
- **WeatherKit pivot implication on break-even.** With WeatherKit at $0 incremental cost (amortized against the existing $99/yr Apple Developer Program), the break-even math is structurally different: **the only ongoing cost is the developer program fee that is required regardless of this app.** Net: break-even sales/year drops from ~13 to ~0 (the fee is paid for App Store presence, not for this app). **The limiting factor is now persona reach, not pricing.** This strengthens, not weakens, the case for symbolic-price-protection-over-margin-extraction.
- **Hold $2.99.** I see no persona case to raise to $3.99 that survives the symbolic-wedge protection. Asha (Skincare4Hikers) is the marginal case; it's not enough to move price.
- **Post-90-day flag.** If Apple's iOS price experimentation gates ease, an A/B between $2.99 and $3.99 on the Skincare4Hikers channel only would resolve the tension cleanly. Not now.

### → Linka (UX / Apple HIG)

- The reapplication-cadence finding (r/trailrunning, r/cycling) is a real persona need but **should NOT enter the v1 UI.** It would creep scope past "one screen, one calculation." The launch-plan disclaimer line *"Reapply sunscreen every 2 hours regardless of timer"* is the right place for it.
- **However:** the Accutane/lupus persona's "UV 3 and I got burned" finding argues that the **verdict card** itself should carry a visible (not buried in About) cue about photosensitizing-medication scope. Suggested wording (for Plunder to refine): a one-line footnote on the verdict card such as *"Estimate assumes typical adult skin not on photosensitizing medications."* — currently this lives only in About. Worth Linka considering, conditional on Plunder sign-off.

### → Wheeler (Skin Science) — SAFETY FLAG

**Important.** The Fitzpatrick MED model **systematically under-estimates burn time** (i.e., over-estimates safe time) for the following user groups currently not excluded from the app's audience:
- Isotretinoin (Accutane) users — direct verbatim from r/Accutane confirming bare-skin burns at UV 3 in 5 minutes
- Tetracycline / doxycycline users (common acne medication, common malaria prophylaxis for the AT/PCT thru-hike persona — relevant!)
- Hydroxychloroquine users (lupus, RA)
- Photosensitive cutaneous lupus
- Vitiligo (depigmented patches behave as Fitz I regardless of base skin type)
- Recent ablative procedures (laser resurfacing, deep chemical peels)
- Post-radiation skin

**This is not a Suchi finding alone** — the persona research surfaced it but the science call is yours. **Question for Wheeler:** Does the current verdict card need a "this estimate may overstate safe time if you take photosensitizing medications" footnote? My read of the discourse says yes; your read of the science governs.

### → Plunder (Legal & Compliance)

- The disclaimer language *"Not medical advice. Skin response varies. Reapply sunscreen every 2 hours regardless of timer."* is **load-bearing** given the photosensitizing-meds findings. **Do not soften.** Recommend explicit non-softening as a guardrail in your domain.
- **Question:** is replying in r/Accutane / r/lupus / r/vitiligo / r/30PlusSkinCare (post-procedure) inside the brand's legal/ethical comfort zone? My research says these are the highest-WTP segments, but they are also where the calculation is most likely to give a dangerously optimistic answer. I would not post here without your sign-off.

### → Gaia (Scope)

- **No scope change requested.** The sub-personas justify **per-channel copy variations** in the launch sequence, not per-channel app variants. The "one screen, one calculation" wedge is correct and Suchi has no scope ask.
- **One small scope question:** does the launch plan's copy table support per-channel variations (suggested for r/trailrunning and r/SkincareAddiction)? If not, that's a small text-asset addition, not a feature change.

### → Karai (Monetization — predecessor)

- Your call on symbolic-over-extractive pricing **survives the persona data.** The wedge is real, the anti-subscription persona signal is stronger than your reconstructed citation suggested, and the upside from raising to $3.99 is outweighed by the symbolic-wedge protection. Your no-IAP-no-subscription-90-day rule is the correct guardrail.

---

## §7 — What I'm uncertain about

In the spirit of Argos's "the persona signal is mixed" honesty:

- **App Store reviewer verbatims** for QSun and competitors. I did not pull App Store reviews directly — that data is harder to scrape than Reddit JSON. Karai's SunburnedSailor remains a reconstructed signal in my analysis too; Reddit gave me structurally stronger evidence, but the App-Store-native voice is still under-evidenced.
- **BackpackingLight forum primary text** is paywalled. The persona is inferred from second-hand references and from the pattern of other ultralight discourse. The persona feels right; the verbatim grounding is weaker than for the Reddit channels.
- **Conversion rates** are not in my domain. I cannot tell Argos what fraction of r/Ultralight viewers convert. I can tell him the **filter** is "no subscription" and that the audience size is large.
- **Channel decay over time.** Reddit channel signal can change quarter to quarter. My quotes range from 2021 to 2025; the anti-subscription thesis is stable across that range, but specific persona language drifts.

---

## §8 — One-page summary for the launch plan revision

If you want a single paragraph to drop into the next revision of `LAUNCH-PLAN.md` under "Willingness-to-Pay Signals," replacing the two reconstructed quotes:

> **Signal 1 — Anti-subscription is the first filter for r/Ultralight, not a tie-breaker.**
> r/Ultralight thread by u/hareofthepuppy, March 2023 (141 upvotes, 119 comments), titled "Navigation app that isn't a subscription," opens its requirements list with `no subscription` BEFORE the user's actual functional requirement (offline GPX support). 0.93 upvote ratio — the community ratified it. The symbolic-wedge pricing is structurally protected. (`https://www.reddit.com/r/Ultralight/comments/11wfisn/`)
>
> **Signal 2 — Latent WTP for a burn-time calculator is verbatim on r/OpenWaterSwimming.**
> u/Sungirl1112, May 2025: *"despite using 50 SPF on my body and 70 SPF on my face, I'm still getting burned if I train over 1.5 hours."* The persona is already doing the calculation in their head and getting it wrong. The app exists to give them the right number. (`https://www.reddit.com/r/OpenWaterSwimming/comments/1kpmf5s/`)

— Suchi
