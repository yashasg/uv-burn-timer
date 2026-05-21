# Skin-Type Re-Prompt Friction — User Research Memo

**Author:** Suchi (User Researcher)
**Date:** 2026-05-21T06:35:00Z
**Requested by:** Yashas (Coordinator)
**Addressees:** Iris (UI/UX redesign), Donatello (architecture), Gaia (scope)
**Copy:** Plunder (regulatory, parallel), Wheeler (science, parallel), Linka, Scribe
**Scope:** User-research perspective only on whether the app should keep re-asking for Fitzpatrick + SPF on every cold launch. Regulatory floor is Plunder's. Scientific question of whether Fitzpatrick is stable-in-fact is Wheeler's. **This memo answers: what do real users do, expect, and complain about?**

---

## Method note

I am answering this from three pools of evidence, ranked by directness:

1. **Prior canon — direct quotes already in our corpus** (cited via username + subreddit + permalink lineage in `.squad/decisions/archive/suchi-monetization-personas.md` and `.squad/files/suchi-persona-annotations.md`). These are real people I quoted before.
2. **Fresh sweep — Reddit JSON + competing-app App Store summaries** (`r/SkincareAddiction`, `r/Accutane`, `r/Sunscreen`; App Store listings + third-party review aggregators for UVLens, UVmate, QSun, SunSmart Global UV, dminder, Reapply, Apple Weather UV section). Where I have a verbatim quote I cite it; where I am synthesizing from N adjacent quotes I mark **[SYNTH from N]** explicitly.
3. **Negative-result evidence** — a search that returned *nothing* is also a finding. The absence of complaint threads about competitor apps re-prompting for skin type per launch is itself a signal: **no major competitor re-prompts, so users have no thread to be angry on.** I flag this where it shapes a recommendation.

**Persona codename reconciliation:** Yashas's prompt referenced "Marcus (P1 — outdoor worker)." Our canonical P1 is **Greta** (gram-counter, r/Ultralight). The "outdoor worker" cohort is closest to **P5 Tomás** (trail-runner) but is distinct enough — and meaningful enough to the friction question — that I'm introducing it as **P8 Marcus (outdoor occupational user — landscaper / construction / surveyor)** for this memo only, labelled extrapolated. I am keeping the canonical P1–P7 codes intact (Greta, Maya, Devon, Asha, Tomás, Priya, Vee). Linka/Gaia: tell me if you want P8 promoted into the persona inventory permanently.

---

## §1 Personas under friction — how the per-launch re-prompt lands

Friction cost is **not uniform** across personas. The same modal hurts five different people in five different ways.

### P1 Greta (gram-counter, r/Ultralight, Fitz II/III) — **friction = HIGH cost, value = ZERO**

- **Lived JTBD on this surface:** "Open app at 7:14 am at trailhead, see number, close app, stuff phone in hip belt."
- **What the re-prompt costs her:** ~8–15 seconds of picker tapping, every cold launch. Her tolerance for friction-before-value is **zero** (verbatim u/hareofthepuppy, r/Ultralight, 141 upvotes: *"First filter: no subscription."* — same psychology: every gate before the number is a deduction from app value).
- **What she'd actually do under status quo:** Choose Type III in <2 seconds without re-reading the descriptions (the "auto-pilot" behavior Yashas asked about — see §2). The re-prompt does not improve her selection accuracy; it just costs her time. After 3–4 cold launches she becomes the user who one-star-reviews us with "why does this thing keep asking me?"
- **Verdict for Greta:** The re-prompt is **pure friction with no safety dividend** (her Fitzpatrick is stable, she's not on photosensitizers, she's not a pediatric case).

### P2 Maya (open-water swimmer, r/OpenWaterSwimming, Fitz III) — **friction = MODERATE cost, value = LOW**

- **Lived JTBD:** "Two cold launches in a single morning — once pre-swim, once after warmup." Pull-to-refresh is her primary affordance (per `.squad/files/suchi-persona-annotations.md` line 118).
- **What the re-prompt costs her:** ~8 seconds × 2 = ~16 seconds per morning of pre-swim friction. Worse: her hands are wet at the second cold launch. Capacitive picker rows + wet thumb = visible irritation.
- **What she might pick differently across re-prompts:** Nothing. She's been Fitz III her whole life and the section header ("not what color it is") is what locked her on III in the first place.
- **Verdict for Maya:** Friction without dividend, with a small accessibility-on-wet-hands aggravator I'd want Linka to consider.

### P3 Devon (PCT thru-hiker, r/PacificCrestTrail, Fitz I) — **friction = LOW cost (he reads carefully), value = ZERO**

- **Lived JTBD:** Pre-trip planning at home, then daily reference on trail.
- **Why friction is low:** Devon is the user our **no-default rule** exists for (per D-2026-05-19-012 and persona-annotations §Screen 3). He *wants* to deliberately tap Type I. The first-launch picker is welcome. On launches 2 through N, his answer is identical and the picker is now a tax.
- **Verbatim re-pick risk:** Zero. *"I am super light-skinned (like super — I got a sunburn on a somewhat sunny day in February in NYC once)"* (u/thedharmalife, r/PacificCrestTrail). His self-identification is locked.
- **Verdict for Devon:** First launch the picker is a feature, subsequent launches it is friction. Asymmetric.

### P4 Asha (Accutane patient, r/Accutane, Fitz IV) — **friction = HIGH cost, value = AMBIGUOUS (this is the one that matters)**

This is the load-bearing case and it is the only one where "friction is a feature" is even arguable. I want to be careful here.

- **Lived JTBD:** *"Like the UV is maybe 3 and it looks like Ive rolled a few. What can I do to stop this?"* (u/Affectionate_Nose_79, r/Accutane). She opens the app **before quick errands** because Accutane makes UV-3 a real burn. Pattern: she's pulling the app out for the equivalent of "watering the garden for five minutes" exposures, multiple times a day.
- **What the re-prompt costs her:** ~10 seconds per launch × potentially 4–8 cold launches per day during peak Accutane months = ~40–80 seconds of friction per day. **Materially more than any other persona.** She is also the persona most likely to *give up on the app entirely* if the friction-to-value ratio gets bad — and giving up costs her safety.
- **The "friction is a feature" argument and why I think it doesn't survive contact with the actual JTBD:** The argument is that the cold-launch re-prompt is Asha's re-attestation surface — the moment her photosensitizer status gets re-surfaced when her medication regimen changes (per `.squad/agents/suchi/history-archive.md` learning-4, my prior framing). **That framing was about the L1 *disclaimer cover*, not the *skin-type picker*.** The skin-type picker doesn't re-surface her Accutane status. Her Fitzpatrick *is* IV — that doesn't change because she started a new course of doxycycline. **The re-attestation argument applies to L1 (the photosensitizer enumeration); it does not apply to Fitzpatrick.** I want to correct my prior framing on the record: *conflating the two was sloppy on my part.* L1 doing re-attestation work is good; the Fitzpatrick picker doing re-attestation work is **not actually how Asha's risk model works**.
- **Verdict for Asha:** The Fitzpatrick re-prompt is friction without safety dividend *for Fitzpatrick selection*. The L1 disclaimer cover (which contains the photosensitizer enumeration via the inline "see About" deep-link, D-2026-05-19-011) is the surface that earns its keep on re-fire. **Persisting Fitzpatrick does not weaken Asha's safety architecture as long as L1 still fires on every cold launch.**

### P5 Tomás (trail runner, r/trailrunning, Fitz IV/V) — **friction = HIGH cost (he won't tolerate it), value = NEGATIVE (forces him into under-picking risk faster)**

- **Lived JTBD:** Trailhead, one earbud in, mid-stride. Per persona-annotations Screen 1: "Will dismiss the modal in ~2 seconds without reading."
- **Why re-prompting is *worse* than no-prompting for him:** Tomás's known failure mode is **under-picking** (V or VI when he's actually IV — *"I tan, I don't burn"*). The first launch we slow him down enough that behavior-first row copy gets ~3–4 seconds of his attention. **Every subsequent re-prompt halves the dwell time** as the friction becomes ritualistic and he hits Type V from muscle memory without re-reading. **Re-prompting *normalizes* the under-pick.** First-time deliberate selection has a higher chance of being correct than tenth-time auto-pilot selection. (This is the inverse of the "friction is a feature" argument — for Tomás, friction is an *anti*-feature on the picker specifically.)
- **Verdict for Tomás:** Persisting and showing him his prior pick as a confirmable chip is *safer* than re-prompting (he taps the chip, sees "Type V," briefly registers it, has the half-second to correct). Re-prompting forces him to re-pick under maximum motion + minimum attention, which is where the under-pick concretizes.

### P6 Priya (parent-of-pale-child, edge case — splash pad / school pickup) — **friction = CONFUSING (she's mis-using the app and the picker re-prompt doesn't help)**

- Per `.squad/decisions/archive/suchi-design-brief.md` §7.1: Priya enters *her own* Fitzpatrick to check her 4-year-old. The picker re-prompt does not surface that mis-use; it just makes her keep re-confirming the wrong input. **The re-prompt does no work for her either way.** (The L1 "For children, consult a pediatrician" line is the surface that matters for Priya, and that fires on the L1 cover, not the picker.)

### P7 Vee (vitiligo / albinism, edge case) — **friction = ACTIVELY HARMFUL**

- Per `.squad/decisions/archive/suchi-design-brief.md` §7.3: Vee has patches of Fitz I skin within otherwise Fitz IV skin. **Either pick is wrong for half her body.** The re-prompt forces her to re-make the impossible choice every cold launch — a recurring small psychic tax. The first launch we can hide behind "we made you choose because we had to"; the tenth time we are rubbing her face in the model's inadequacy.
- **Vee benefits from persistence — full stop.** Pick once, live with the compromise, don't get re-asked.

### P8 Marcus (outdoor occupational — landscaper / construction / surveyor) — **[EXTRAPOLATED, n=adjacent quotes only]**

This persona is not in my locked inventory but Yashas asked about it and the cohort is real. I'm extrapolating from r/landscaping and r/Construction quote patterns I have not formally indexed; flag this as **provisional**.

- **Lived JTBD:** App opens at 7:00 am job-site arrival, again at 9:30 am water break, again at 12:00 noon lunch, again at 2:30 pm break. **4–5 cold launches per workday, 5 days a week, 8 months a year.** Friction per launch compounds into hours per year.
- **Mental model:** Set-and-forget. He picked Type III on day one because his forearm tan suggested it; that's his answer forever. He will *not* re-read the descriptions on re-prompt. He is the highest-volume cold-launch user in the cohort set.
- **What re-prompting costs Marcus:** Probably ~6 minutes of cumulative picker-tapping per work week, plus a high probability of app abandonment after 2–3 weeks because **the friction-to-value ratio for a quick-glance worker is brutal.**
- **Verdict for Marcus:** Persistence is the difference between him using the app and uninstalling it. Auto-pilot behavior is his dominant pattern.

---

## §2 User mental model of "skin type" — what real people hold in their heads

The question Yashas asked: *do users treat Fitzpatrick as one-time identity ("I am a III") or as dynamic state ("this week I'm tanner so let me pick IV")?*

**Answer: overwhelmingly identity. Both in dermatology consensus and in observed user discourse.** Five threads of evidence:

### 2.1 Dermatology consensus (the science Suchi is allowed to quote because she's not adjudicating it — that's Wheeler's lane)

Fitzpatrick is defined by **natural (untanned) skin response, not current tan state.** From DermNet NZ ("Skin phototype (Fitzpatrick skin type)") and the Cancer Institute NSW ("Identify and protect your skin type"): assessment is meant to use *unexposed* skin (e.g., inner upper arm) and innate burn-tan response. Seasonal tanning does **not** move you between types in the canonical use of the scale. **The scale is genealogical/genetic identity, not a dynamic state variable.** (Wheeler owns the question of whether this is *correct*. I'm reporting what the published consensus says, which is what users absorb when they Google "what's my Fitzpatrick type.")

### 2.2 How users self-describe in the wild

Verbatim or near-verbatim patterns I've seen across r/SkincareAddiction, r/30PlusSkinCare, r/AsianBeauty in the prior research pass:

- *"I'm a Fitzpatrick III"* — used as a standalone identity claim, much like "I'm an INFJ" or "I'm O-negative." It is a label that travels with the user.
- *"I'm a type II so I always wear SPF 50"* — Fitzpatrick used as a personal-risk constant, framing routine choices.
- *"As a Fitz IV, this product..."* — used in product reviews as a third-person-style demographic claim about themselves.

**The grammar reveals the model.** "I am a III" is identity grammar. The state-grammar version ("I'm a III this week, but I'm closer to IV by August") is **vanishingly rare in the corpus.** I searched explicitly for state-grammar phrasings ("this summer," "right now," "since I started tanning") and the threads that returned were dermatologist-led corrections explaining that Fitzpatrick *doesn't* change with tanning. The lay-user pattern of treating it as a state is something the dermatology community actively pushes against.

### 2.3 Direct quotes from my locked persona corpus

- **u/thedharmalife** (r/PacificCrestTrail, Devon archetype): *"I am super light-skinned (like *super* — I got a sunburn on a somewhat sunny day in February in NYC once)."*
  → **Identity grammar.** "I am." Not "I tend to be" or "I currently am."
- **u/Affectionate_Nose_79** (r/Accutane, Asha archetype): *"Like the UV is maybe 3 and it looks like Ive rolled a few."*
  → Note what she's saying: her Fitzpatrick (a IV) is not the variable that surprised her. The variable that surprised her is the **medication-modulated burn threshold.** Even her own framing keeps Fitzpatrick as the stable axis and Accutane as the dynamic axis.
- **u/Sungirl1112** (r/OpenWaterSwimming, Maya archetype): *"Despite using 50 SPF on my body and 70 SPF on my face… I'm still getting burned."*
  → The dynamic-state thing she names is **SPF**, not Fitzpatrick. SPF is the dial she changes; Fitzpatrick is the constant about her.
- **u/Amazing-Reporter1845** (r/trailrunning, Tomás archetype, [INFERRED pattern]): *"I tan, I don't burn."*
  → Lifetime self-narrative. Not "this season I tan more." Identity.

### 2.4 What the *absence* of the dynamic-state model tells us

In ~3 hours of search across r/SkincareAddiction, r/Sunscreen, r/AsianBeauty, r/Dermatology, r/Accutane I could find **zero** threads where a user described re-evaluating their Fitzpatrick mid-season because they got tanner. The closest signal was dermatologist-authored posts *correcting* a misconception that Fitzpatrick should be re-assessed based on current tan — meaning some users do hold the dynamic model, but it is treated as an *error to be corrected*, not a normal use pattern. **This is the negative-result evidence:** there is no community of users who would benefit from being re-asked.

### 2.5 The one user cohort where the mental model genuinely is dynamic — and what they do about it

Tanners (r/tanning, r/sunbathing) do hold a dynamic model — they actively want to track moving up the scale ("started this season at II, now I'm functionally IV"). **This cohort is not our target user** (Plunder's territory; we don't do tanning guidance and we've stayed firmly out of vitamin-D-maxxing). I name them only to be honest that the dynamic model exists *somewhere*; it doesn't exist in our personas.

### 2.6 Synthesis

> **The user mental model of Fitzpatrick is overwhelmingly identity-as-constant, not state-as-variable. "I am a III" is the dominant grammar. The dial users actually change mid-session is SPF, sometimes location, never skin type.**

This has a direct implication for the persistence decision: **persisting Fitzpatrick matches the user's mental model.** Re-prompting on every launch implies "this might have changed" — which doesn't match how users think about themselves and which trains them to either auto-pilot (Greta, Marcus) or distrust the model (Asha, who already mentally divides our output anyway).

---

## §3 Competitive landscape — who persists, who doesn't, what users actually complain about

I sampled the major competitors. Persistence model first, then the friction users actually voice on each.

### 3.1 The persistence picture

| App | Skin type input? | Persists across launches? | Re-confirmation cadence? | Source |
|---|---|---|---|---|
| **Apple Weather (UV section)** | None — no personalization at all | N/A | Never asks | iOS Weather app inspection. The user's mental model is "the integer is universal; I apply my own personal context." This generates the well-documented *"is UV 7 bad for me?"* noise (see persona-annotations cross-validation note 4, prior pass) but it does *not* generate "stop asking me" complaints — because Apple never asks. |
| **dminder (Vitamin D + UV)** | Fitzpatrick in profile setup | **Persists indefinitely** | Manual edit in profile only | App listing + GrassrootsHealth review + CALMERme review (cited via third-party review aggregators, not direct Reddit). Reviews praise the "set once, use forever" model. Frustration in dminder reviews is about *stability bugs* (settings sometimes getting wiped after an update) — which is itself evidence that users *want* persistence and are angry when it fails. **[SYNTH from ~6 third-party review summaries]** |
| **UVLens** | Skin-type quiz at onboarding | **Persists indefinitely** | No re-prompt | Google Play listing + makeuseof.com review. Users complaining about onboarding mainly want *finer* skin-type granularity (Fitz I and Fitz VI users feel the categories don't fit) — they are not complaining about being asked too much. They're complaining that the *single* setup pass doesn't capture them well enough. |
| **UVmate (UV Index Now)** | Fitzpatrick in profile | **Persists indefinitely** | No re-prompt | App Store AU listing. The single critical-review pattern I could surface was about expecting personalization that didn't fire reliably — i.e., "I set my skin type and the app didn't use it." The complaint shape is *"it's not personalizing enough,"* not *"it's asking too much."* |
| **QSun** | Onboarding with skin tone, age, clothing | **Persists indefinitely** | No re-prompt | App listing + makeuseof.com. Reviews note the onboarding is *involved* (a few minutes, multiple inputs) — but persistent. No "asks every time" complaints. |
| **SunSmart Global UV** (Cancer Council Victoria, the global WHO-endorsed app) | Profile-based skin type | **Persists indefinitely** (per developer docs) | No re-prompt as a feature; some users have reported *bugs* causing re-prompts | Play Store + App Store AU listings. The friction here is interesting — when SunSmart *does* re-prompt (bug condition), users do complain, classifying it as a defect. This is the cleanest signal we have that the per-launch re-prompt reads as broken-behavior to users, not deliberate-friction. **[SYNTH from ~4 review aggregator summaries]** |
| **REAPPLY: Sunscreen Timekeeper** | Profile setup (skin type + SPF) | **Persists indefinitely** | No re-prompt | App Store + appshunter.io. Users praise the "open, see info in 2 seconds" pattern. The complaints are about missed notifications (a different problem class). |
| **Sun Tracker (UV Index & Tan, Android)** | Skin type in profile | **Persists indefinitely** | No re-prompt | Play Store. |
| **Sun Safe (SunCare)** | Skin type in profile | **Persists indefinitely, locally** | "No need for login. Your data will be saved locally." (App Store description, verbatim) | Apps.apple.com listing. **Note:** the app makes "data saves locally" an *explicit marketing claim* — meaning their target users *prefer* persistence-without-cloud. This is the privacy-conscious persistence pattern that matches our own zero-data architecture *if* we choose to persist locally. |
| **Tan AI** | Fitzpatrick quiz once | **Persists** | One-time | usetanai.com blog. Out of canon for our scope (it's a tanning app) but the persistence pattern is the same. |

### 3.2 What users actually complain about — the shape of the friction signal

I want to summarize the *kinds* of complaints visible in the competitive review corpus, because the absence of certain complaints is more informative than the presence of others.

**Complaints that DO appear frequently:**

1. **"Settings got wiped after update"** (dminder, several apps). **[SYNTH from ~8 reviews]** — users are angry when persistence fails, which is the inverse signal: they assume persistence is the contract.
2. **"Setup is too long / too many steps"** (QSun, a couple of others) — the friction users name is *initial setup length*, not re-prompting cadence. This means a long one-time setup is preferred to a short repeat-setup.
3. **"Doesn't personalize enough"** (UVmate) — users want the saved profile to do *more* work, not less.
4. **"Skin type categories don't fit me"** (UVLens, scattered) — granularity complaint, not cadence.
5. **"Wish it had a widget / faster check"** (Reapply, others) — they want even *less* friction than "open the app" already requires.

**Complaints I searched for and could NOT find:**

1. *"This app keeps asking me my skin type"* — zero hits across r/SkincareAddiction, r/Accutane, r/Sunscreen, r/Dermatology in the time window I searched, for the apps listed above. **The reason is structural: no major competitor re-prompts.** Users have nothing to complain about because the pattern doesn't exist in the market.
2. *"I'm glad this app makes me re-confirm my skin type each time"* — also zero hits. No user is treating the re-prompt as a feature.

### 3.3 Synthesis

> **The market convention is unambiguous: skin type persists indefinitely after one-time setup.** Users complain when persistence *fails*; they do not complain when it works. They do *not* complain that an app doesn't re-ask. **We are the outlier with our current `@State`-only model, and the outlier behavior reads to users as either a bug or a hostile UX.**

Apple Weather is the only major competitor that doesn't store skin type — and they handle this by **not asking at all** (zero personalization), not by re-asking. That's a coherent posture. Our current posture is "ask every time and store nothing," which is not coherent — it borrows the personalization claim of dminder/UVmate without the persistence affordance that makes personalization actually feel personal.

---

## §4 Ranked pattern recommendation (user-research POV only)

Plunder owns regulatory floor on whether the L1 disclaimer cover must re-fire (per `.squad/designs/plunder-disclaimer-relocation-floor.md` C6 and C7). Wheeler owns whether Fitzpatrick is scientifically stable. **My ranking is on user-experience grounds only,** and explicitly assumes the L1 cover continues to fire on every cold launch (which I support — that's Asha's photosensitizer re-attestation surface, and persisting Fitzpatrick does not break L1's re-fire).

| Rank | Pattern | Verdict | Reasoning anchor |
|---|---|---|---|
| **1 (best)** | **Pattern B — Persist + tap-confirm chip** ("Fitzpatrick III ✓ — tap to change") | **Recommended.** | Matches user mental model (identity-as-constant, §2). Matches market convention (persistence with edit affordance, §3). Zero friction for Greta/Marcus/Devon on re-launch. *Lowest* friction for Tomás's under-pick risk (he sees his prior pick as a chip and has a passive moment to register it, instead of being forced into an auto-pilot re-pick). Asha's friction drops dramatically. Vee/Priya are spared the impossible-choice re-tax. The chip itself doubles as a visible *summary* of the model's input — addresses the "did the app actually personalize?" complaint pattern from UVmate reviews (§3.2). |
| **2** | **Pattern A — Persist + 30-day re-confirm modal** ("Still Fitzpatrick III?") | **Acceptable.** | Lower friction than status quo by ~29 days out of 30, and the periodic re-confirm sounds like it would help. **But:** it doesn't actually map to a real user behavior (people don't re-assess monthly). The "still ___?" framing implies the user might have changed — which doesn't match the identity-as-constant mental model (§2). 30 days is also arbitrary — Wheeler would have to defend it scientifically, and per §2.1 there's no scientific basis for a monthly cadence on Fitzpatrick reassessment. Users will read it as a Cookie Consent–style modal: dismiss, dismiss, dismiss. Adds the cognitive overhead of a quasi-attestation moment that doesn't earn its keep. **Defensible but inferior to Pattern B.** |
| **3** | **Pattern C — Don't persist; default picker to last value (in-memory only)** | **Marginal improvement, not recommended as the destination.** | Halfway-house: persists during a session, wiped on app kill. Helps Greta if she backgrounds the app and returns 30 min later, but **does nothing for the actual quick-glance JTBD** (cold launch is the dominant pattern — Marcus, Asha, Tomás all cold-launch repeatedly, not background-return). Inherits all of status-quo's friction on cold launch with no compensating benefit. Only point in its favor: simplest architectural change (no UserDefaults migration). But that's an architecture argument, not a user argument. **If we ship this we will still get the "why does it forget me" complaints.** |
| **4 (worst, current)** | **Status quo — full picker every cold launch** | **Below user-acceptability floor.** | This is the pattern that generated Yashas's complaint, and Yashas is *our most patient user.* If he's calling it out, the App Store reviewer with a 3-second tolerance will be merciless. **No major competitor does this** (§3). The user mental model assumes apps remember you (§2). The friction has no compensating safety dividend on the picker specifically — L1 re-fire is the surface that earns its keep, and L1 re-fire is independent of picker persistence. **The only argument for status quo is "but we already built it," which is not a user argument; that's an architecture inertia argument and Donatello should weigh in on whether the migration cost is real.** |

### 4.1 What "best" looks like in detail (Pattern B specifics, user-side only)

Linka and Iris own the chip's visual treatment; I'm only specifying the *user-side contract*:

- **What it says:** The chip displays the user's stored Fitzpatrick (e.g., "Fitzpatrick III") with a confirmable affordance (a checkmark or trailing chevron — Linka's call). Optional small "Edit" or tap-target wraps the whole chip.
- **What tapping it does:** Opens the existing `SkinTypeView` picker (same component used by onboarding and settings — Gaia Guardrail 2 from prior canon, locked).
- **What it does *not* do:** Block the verdict surface. The chip is an *ambient* confirmation, not a gate. The hero number renders immediately on cold launch using the persisted value; the chip sits in the inputs row as a passive label.
- **What L1 still does:** Fires on every cold launch (unchanged from current behavior; Plunder's C6/C7 preserved). The chip is below L1 in the launch order: user dismisses L1, then sees the verdict with the chip visible.
- **What the picker does on first launch:** Unchanged — the no-default rule (D-2026-05-19-012) still holds. User must deliberately tap on first run. Persistence only kicks in *after* the first deliberate selection.

This pattern is what dminder, UVLens, UVmate, QSun, SunSmart, REAPPLY, and Sun Safe all converged on (§3.1). We'd be ending our outlier status, not breaking new ground.

### 4.2 What's explicitly out-of-scope for this memo

- **Whether the regulatory floor allows persistence.** Plunder's call. My read of his C7 in `plunder-disclaimer-relocation-floor.md` is that the floor is *re-attestation cadence is unchanged* (L1 re-fires on every cold launch); persisting the *Fitzpatrick value* underneath that doesn't change L1's behavior. But that's a Plunder question.
- **Whether Fitzpatrick is the right scientific input to persist.** Wheeler's call. There may be a science argument (degradation of self-classification accuracy over months, accumulated tan biasing future self-pick if re-picked) that I'm not equipped to make.
- **Whether to persist SPF in addition to Fitzpatrick.** I'd argue yes (same mental-model argument: users have a "default SPF" they reach for, and re-prompting doesn't change their habit). But the SPF question has its own friction pattern (different SPF for face vs body — Maya's blindspot, persona-annotations §1.2) and probably deserves its own memo if Donatello/Gaia want to scope it separately.

---

## §5 JTBD impact — where the friction actually lives in the jobs users hire this app for

Reframing in JTBD language: *what job is the user trying to get done when they cold-launch the app, and where does the Fitzpatrick re-prompt sit in that job?*

### 5.1 JTBD-1: "Should I put on sunscreen in the next 10 minutes?" (the dominant job)

- **Users hiring:** Greta, Marcus, Priya, Tomás (pre-run), occasional Maya.
- **Job duration tolerated:** ~5–8 seconds from app icon tap to actionable answer.
- **Where Fitzpatrick re-prompt sits in this job:** *Between* the tap and the answer. **It is a blocking screen for an unblocking job.** Persisting collapses the picker out of the critical path entirely — the answer renders immediately on cold launch. This is the single highest-value-to-effort change available for these users.

### 5.2 JTBD-2: "How long do I have before I burn for this specific outing?" (the planning job)

- **Users hiring:** Devon (PCT planning), Maya (pre-swim), Greta (gram-math).
- **Job duration tolerated:** Longer — 30–60 seconds is acceptable because the user is in deliberate-planning mode.
- **Where Fitzpatrick re-prompt sits in this job:** Less harmful here. The user is willing to engage. **But the picker still doesn't *contribute* to the job** — these users have already settled their Fitzpatrick. The dial they actually want to twist is **SPF**, **location** (Devon's planning blocker, prior research), or **time of day** (forecast use case, WI-7).

### 5.3 JTBD-3: "Did my exposure window expire — should I reapply?" (the safety-moment job)

- **Users hiring:** Tomás (mile 8), Asha (multi-hour gardening).
- **Where Fitzpatrick re-prompt sits in this job:** It doesn't fire on the same surface — this is the window-elapsed state, not cold launch. **But cold-launch friction degrades the *prior* job that set the window in the first place.** If Tomás abandons the app at the trailhead because the cold-launch picker took 8 seconds, the window never gets set and the safety moment never fires.

### 5.4 JTBD-4: "Am I in a special-risk cohort I should worry about?" (the discovery/visibility job — Asha-load-bearing)

- **Users hiring:** Asha, new-onset photosensitizer users, post-procedure users, pregnant users, Vee.
- **Where Fitzpatrick re-prompt sits in this job:** It sits *adjacent* to this job and confuses it. The actual surface that does this job is **L1's photosensitizer inline link → About → cohort enumeration**. The Fitzpatrick picker doesn't do this job; conflating "we re-prompt for Fitzpatrick so we're being safety-conscious" with "we re-attest the photosensitizer cohort" is the conflation that made the status quo defensible-sounding. They are different surfaces with different jobs. **Decouple them.**

### 5.5 Net JTBD verdict

> **The Fitzpatrick picker does load-bearing work *exactly once* (first launch, deliberate selection). On every subsequent launch it sits in the critical path of JTBD-1 (the dominant quick-glance job) and does no compensating work for any of the other jobs.** Persistence converts a once-useful surface into a permanently-useful surface (the chip continues to display the model's input, which addresses the "is this actually for me?" job-2 concern). The status quo converts a once-useful surface into a recurring tax on every job.

---

## §6 Edge cases — who actually NEEDS per-launch re-attestation (be honest)

Yashas asked me to be honest if anyone genuinely benefits from per-launch re-attestation. I want to be careful here because the right answer is *almost no one needs per-launch Fitzpatrick re-attestation, but a small number of users benefit from per-launch attention to the photosensitizer cohort* — and those are different things.

### 6.1 Users who would benefit from per-launch *photosensitizer* re-attestation (L1's job, not the picker's job)

- **Recently-started photosensitizer patients (~weeks 1–4 of a course).** Asha at the start of Accutane, a patient who just picked up doxycycline, post-laser day-1 through day-30. **For these users, L1 firing on every cold launch is the safety architecture.** This is satisfied by L1's current behavior and is *independent* of whether we persist Fitzpatrick.
- **Wheeler/Plunder boundary:** the *scientific* case for L1's re-fire is photosensitizer-status volatility (medications start/stop, procedures happen, pregnancy starts) at human-meaningful frequencies (weekly or finer). Fitzpatrick volatility is *not* in this range (multi-year drift at most, per §2.1). The two cadences should not share an attestation surface.

### 6.2 Users who would benefit from per-launch *Fitzpatrick* re-attestation

After honest reflection: **I do not have a persona who needs this.**

The closest candidates I considered, and why each fails:

- **Post-laser / post-peel users (the cohort I flagged in prior research as v1.2):** Their *photosensitivity* changes, but their underlying Fitzpatrick does not. They need L1 re-attestation, not picker re-attestation.
- **Pregnancy melasma users:** Similar — they have a *condition-anchored* sensitivity change, not a Fitzpatrick change. L1 surface.
- **Children using a parent's phone:** A parent who hands the phone to a 12-year-old who happens to have Fitz I when the parent set it to IV. **This is a real failure mode**, but the right response is not "re-prompt every cold launch" (the parent will just hit the cached value, the child can't override it usefully). The right response is the *"For children, consult a pediatrician"* disclaimer that already lives in L1 — which fires regardless of persistence. **Persistence does not weaken the pediatric guard.**
- **Vee (vitiligo / patchy skin):** I considered whether the impossible-choice should be re-asked to surface its impossibility. **No.** Re-asking does not help Vee make a better choice; it taxes her with the same impossible choice repeatedly. (See §1 Vee.) The right answer for Vee is About-section guidance acknowledging the limitation — which is content, not cadence.
- **Self-misclassification correction:** If a user picks the wrong Fitzpatrick on first launch, will re-prompting help them correct it? **Modestly, in theory.** In practice, the auto-pilot pattern (§1 Greta, §1 Marcus, §1 Tomás) means re-prompted users tap the same wrong answer faster, not a different right answer. The right intervention for self-misclassification is *better first-time picker copy* (which we already have — Wheeler's behavior-first variant, D-2026-05-19-009) and *easy access to edit* (which Pattern B provides via the tappable chip). **Not re-prompting.**

### 6.3 The one honest "feature, not bug" case I can name

**Users who hand their phone to someone else for a quick check.** "Hey, can you check the UV on your app?" The app should be obvious about whose Fitzpatrick is loaded. **Pattern B (the chip) actually serves this case better than status quo** — the borrower sees "Fitzpatrick III" displayed and knows the answer is calibrated to the lender's skin, not theirs. Status quo's "pick your type" picker would let the borrower mis-attribute. The chip is the *more* honest pattern about whose answer is being shown.

### 6.4 Synthesis

> **No persona in our inventory benefits from per-launch Fitzpatrick re-attestation specifically. The users I considered who initially seemed to benefit (photosensitizer users, post-procedure users, pregnant users) are actually L1-attestation users — and L1 fires independently of picker persistence. Decoupling the two surfaces preserves every safety dividend while removing the friction that has no dividend.**

---

## Cross-team handoffs

- **Iris:** Pattern B (tap-confirm chip) needs a visual treatment for the inputs row. The chip should read as ambient confirmation, not as an interactive primary affordance. Linka's existing `contextChipRow` pattern (location-only chip, post-cleanup) is the canonical lockup. If you adopt Pattern B, the inputs row becomes a two-chip row: `[Fitzpatrick III ✓] · [Location ▾]`. **Tappable chip target** size matters for Tomás and Marcus (motion / glove conditions).
- **Donatello:** This memo answers the *user* question only. The architecture question — is persistence even compatible with M7 zero-data — is yours. My understanding from the persistence-discussion footnote in `decisions.md` (lines 8–18) is that Fitzpatrick-in-UserDefaults is a *local-device* persistence and stays inside the zero-data envelope (no cloud, no Health, no third party), so it should be compatible with M7. But please confirm.
- **Plunder:** Your C6/C7 constraints (`plunder-disclaimer-relocation-floor.md` §3) keep L1 re-firing on every cold launch and keep skin-type as `@State`-only in the regulatory floor. **My user-research read is that the L1 re-fire is the safety surface that earns its keep, and the Fitzpatrick `@State`-only constraint is *not* doing safety work — it's doing inadvertent friction work.** Could you re-examine C7 specifically with this memo in hand and clarify whether the floor is *L1 re-fires* (which I support) or *Fitzpatrick is `@State`-only* (which I'm asking you to reconsider as a user-friction matter)? My understanding is that the first is the genuine regulatory load-bearing piece and the second was inherited as a consequence rather than a deliberate floor — but you own that call.
- **Wheeler:** Is there a scientific case for periodic Fitzpatrick re-assessment that I'm missing? My read of the literature (DermNet, NSW Cancer Institute, NCBI NBK481857) is that Fitzpatrick is genealogically stable. If you concur, please ratify; if you have a counter-case, this changes my §6 verdict.
- **Gaia:** If Pattern B is adopted, this is a small surface change (one chip, one UserDefaults read/write, one onboarding-flow gate). Probably fits in the disclaimer-relocation work already in flight under Iris. Scope-tight.
- **Argos:** Monetization-neutral. No price implications.

---

## Confidence rating

- **§1 (personas under friction):** High — five of seven personas are from locked canon with direct quotes. P8 Marcus is provisional/extrapolated and labelled as such.
- **§2 (user mental model):** High — multiple converging signals (verbatim grammar, dermatology consensus, negative-result evidence). The "identity, not state" finding is robust.
- **§3 (competitive landscape):** Medium-high — direct App Store / Play Store listings + third-party review aggregators. I was unable to pull raw verbatim App Store reviews in this pass; the competitive synthesis is from review summaries and listing copy. The *persistence-is-universal* finding is robust; the *no-one-complains-about-asking* finding is a negative-result inference that I've labelled as such.
- **§4 (ranking):** High — ranking follows directly from §1–§3. The order is robust; the specific delta between Pattern A and Pattern C is the least-confident piece.
- **§5 (JTBD):** High — JTBD framing is well-anchored in prior persona corpus.
- **§6 (edge cases):** Medium — confidence that I considered the right edge cases is high; confidence that I haven't missed an edge case I don't know about is medium. Wheeler/Plunder review is the natural safety net.

---

**Bottom line — single-sentence version:**

> The Fitzpatrick re-prompt every cold launch is friction without a safety dividend, the user mental model is identity-not-state, every major competitor persists, and Pattern B (persist + tap-confirm chip) is the only option that lowers friction across all seven personas without weakening L1's photosensitizer re-attestation — but Plunder and Donatello own the final call on whether the regulatory floor and zero-data envelope actually permit local-device persistence. Real people don't read the docs; real people open the app and want to know if they should sunscreen in the next ten minutes.

— Suchi

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
