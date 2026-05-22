# Argos — History

## Core Context

- **Project:** A UV exposure and sunburn timer app — iOS app build (web prototype in `prototype/`)
- **Role:** Monetization Strategy
- **Joined:** 2026-05-18
- **Requested by:** yashasgujjar

## Inherited Context (from prior assignment — TMNT-cast team)

The previous squad's monetization owner (Karai, Stage 6) established the following baseline in `prototype/LAUNCH-PLAN.md`. Argos inherits this scope and is responsible for validating/extending it under the current cast.

- **Pricing:** $2.99 USD one-time, no subscription.
- **Confidence:** HIGH.
- **Wedge:** "$2.99 ONCE, not $2.99 per month" — anti-positioned against QSun ($2.99/mo subscription).
- **Comparable apps:** QSun ($2.99/mo, anti-comp), Sunscreen by Apium Co. ($1.99 one-time, floor comp), dminder Pro ($3.99 one-time, ceiling comp).
- **Non-negotiable guardrails (90 days post-launch):** No IAP, no subscription, no tip jar.
- **Original break-even math:** Open-Meteo €29/yr (~$31) → ~13 sales/year break-even.
- **Subtitle (locked):** `Estimated burn time, no subscription.`

## Active Directives Affecting Monetization

- **2026-05-19:** Pivot from Open-Meteo to Apple WeatherKit. WeatherKit ships with the Apple Developer Program ($99/yr, already required). Incremental API cost ≈ $0. **Break-even math needs revision.**

## Learnings

### 2026-05-18 — Monetization review post-WeatherKit pivot

**Decision: Hold $2.99 USD one-time. Confidence: HIGH (reaffirmed Karai's call under new cost model).**

**Updated break-even math:**
- Old (Open-Meteo €29/yr ≈ $31): ~13 sales/year. Net per $2.99 sale at small-biz 15%: $2.5415.
- New (WeatherKit, bundled with $99/yr Apple Developer Program already required for any iOS submission):
  - Incremental costs ≈ $0 (WeatherKit free up to 500K calls/month; JWT signing free; StoreKit/TestFlight included).
  - **Incremental-only break-even: 1 sale/year covers any plausible micro-cost** (e.g., $12/yr support-email domain).
  - **Full-amortization worst-case break-even (if dev program solely allocated to this app): $99 ÷ $2.5415 ≈ 39 sales/year.**
  - Both floors trivially achievable on r/Ultralight (~250K, anti-subscription sentiment, $200+ gear-spend norm).
- Net per sale unchanged at $2.5415 (Apple small-business take-rate applies regardless of API source).

**Cost-classification principle (reusable):** Apple Developer Program $99/yr is a sunk cost-of-doing-business for iOS distribution; it should NOT be charged against any single app's monetization decision. The honest break-even framing is "incremental-only" with "full-amortization worst-case" as a sanity floor.

**Comp data (named, with prices):**
- **QSun UV Tracker** — $2.99/mo subscription. Anti-comp / symbolic foil. Documented persona pain ("SunburnedSailor" deleted-it review).
- **Sunscreen by Apium Co.** — $1.99 one-time. Floor comp. Proves one-time works in category. Same Diffey-based math.
- **dminder Pro** — $3.99 one-time. Ceiling comp. UV / vitamin-D timer.

**Price-point trade quantified:**
- $2.99 → $3.99 per-sale uplift: $0.85 net (+33.4%). Required conversion-retention to match $2.99 gross: 74.9%.
- Wedge headline ("$2.99 ONCE, not $2.99 PER MONTH") is also the reach engine on r/Ultralight — losing it likely costs 2–3× reach in addition to ~25%+ conversion drop. Wedge wins ~2× over ceiling-push on combined reach × conversion × per-sale math.
- **Hold $2.99 unless:** QSun drops their gate / Apium raises floor / post-90-day data shows strong price-insensitivity / dev-program or take-rate changes materially.

**90-day no-IAP guardrail: KEEP.** Rule was brand-justified, not cost-justified. WeatherKit lowering costs strengthens the rule, doesn't weaken it. Tip jars and $0.99 micro-IAPs break the symbolic clarity of the description's "No subscription. No account. No ads. No tracking." contract.

**Attribution change (flagged for Plunder):**
- App Store description's `Weather data: Open-Meteo (CC BY 4.0).` line must be removed/replaced. Recommended: `Weather data: Apple Weather.`
- In-app About surface (Linka's surface) must carry Apple's required WeatherKit attribution lockup ( Weather logo + wordmark, Apple's exact style) + link to https://weatherkit.apple.com/legal-attribution.html. These are API license terms, not courtesies.
- All Reddit / BackpackingLight / r/trailrunning / Product Hunt launch-day copy drafts mentioning Open-Meteo need updating.
- Subtitle `Estimated burn time, no subscription.` — locked, unaffected by attribution change.

**Persona–price mapping (independent of Suchi, will refine with her work):**
- r/Ultralight persona: anti-subscription, price-insensitive at $2.99–$3.99. Wedge headline is the reach engine.
- SunburnedSailor persona: hard NO on subscription, prefers one-time. Validates wedge.
- Suchi may refine: if SunburnedSailor is anomalous-of-one (not pattern), wedge weakens slightly — but price stays $2.99. If she finds a new high-WTP persona ($4.99+), it informs post-90-day expansion, not v1 price.

**Post-launch pricing review schedule:**
- 30-day pulse check (lightweight — sales count, review scan, QSun/UV Lens monitor)
- 60-day signal review (brand-promise holding? IAP requests in reviews?)
- 90-day formal review (Karai's original cadence — confirm hold $2.99, consider $3.49/$3.99 push, expiry of no-IAP rule)
- 7 earlier-review triggers documented in the review file (QSun gate change, competitor launches, fee changes, take-rate changes, App Store rejection, >5% price-negative reviews, WeatherKit 500K cap approach).

**Key file paths referenced:**
- `prototype/LAUNCH-PLAN.md` — Karai's Stage 6 monetization section (lines ~150–211); API Cost Model (lines ~213–222); App Store description draft (lines ~21–39); launch-day copy drafts (lines ~78–146)
- `prototype/README.md` — product surface, zero-data privacy posture
- `.squad/decisions/inbox/copilot-directive-2026-05-19T06-42-14Z.md` — WeatherKit pivot directive
- `.squad/decisions/inbox/argos-monetization-review.md` — this review

**Skill extracted:** `anti-subscription-wedge-applicability` — checklist for when the "$X once not $X/mo" symbolic wedge is load-bearing vs. decorative.

Model assignment updated 2026-05-22T03:55: claude-opus-4.7-1m-internal (1M-context internal variant — for full-corpus photobiology consensus reviews).
