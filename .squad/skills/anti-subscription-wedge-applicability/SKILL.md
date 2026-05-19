# Skill: Anti-Subscription Wedge Applicability Checklist

**Author:** Argos (Monetization Strategy)
**First captured:** 2026-05-18 — UV Burn Timer monetization review
**When to use:** When evaluating whether a one-time price should be positioned symbolically against a comp's subscription (e.g., "$X once, not $X per month").

---

## What is the "anti-subscription wedge"?

A pricing/positioning move where a one-time product picks the **exact same dollar amount** as a competitor's monthly subscription, and uses that 1:1 symmetry as the launch headline. Example: QSun charges $2.99/mo for UV burn-time calculation; we charge $2.99 *once*. Headline: **"$2.99 ONCE, not $2.99 PER MONTH."**

The wedge does two things at once:
1. **Sets the conversion price** at a per-sale-rational number.
2. **Acts as the launch-post hook** that drives organic reach — the dollar-for-dollar symmetry is upvote-engine fuel in anti-subscription communities.

---

## Applicability checklist — all 7 must be true

The wedge is *load-bearing* (worth the per-sale revenue you might leave on the table) only when ALL of these hold:

- [ ] **1. There is a named, identifiable subscription comp in the same category** charging at or near your target one-time price. Generic "subscriptions are bad" isn't enough — you need a specific app with a specific monthly price to point at.

- [ ] **2. The subscription comp gates the core useful feature** behind the paywall, not optional/advanced features. The pain has to be on the value that the persona actually wants.

- [ ] **3. There is a documented persona pain signal** — an App Store review, a forum thread, a Reddit post — where a real user describes deleting/avoiding the subscription comp specifically because of the subscription model (not because the product was bad). Anonymous "industry sentiment" doesn't count.

- [ ] **4. The launch channel(s) have anti-subscription sentiment in the demographic.** r/Ultralight, BackpackingLight forums, gram-counter / DIY / open-source-adjacent communities qualify. Generic consumer Instagram doesn't.

- [ ] **5. Category evidence supports one-time pricing succeeding.** At least one one-time comp in the category has held its price for years without converting to subscription. (For UV Burn Timer: Sunscreen by Apium Co. at $1.99 and dminder Pro at $3.99 — both one-time, both stable.)

- [ ] **6. Your incremental per-customer cost is low enough that one-time pricing math closes.** API costs, content costs, support costs per user need to be a small fraction of net-per-sale. If you have meaningful per-user OpEx, subscription is structurally correct and the wedge doesn't apply.

- [ ] **7. The dollar amount is symmetric** (or close enough — within $0.50). "$2.99 once, not $2.99/mo" works. "$4.99 once, not $2.99/mo" loses the punch. If you can't price at the symmetric dollar without breaking your floor, the wedge is decorative not load-bearing.

If any one of the seven fails, the wedge is decorative — use a different positioning frame and optimize price on per-sale math + WTP signal alone.

---

## Quantifying the wedge value (decision math)

Once applicable, compare wedge vs. ceiling-push by:

1. **Per-sale uplift if you abandon the wedge for a higher price:**
   - Net-per-sale at wedge price × (1 - take-rate) = current net
   - Net-per-sale at higher price × (1 - take-rate) = new net
   - Per-sale uplift % = (new - current) / current

2. **Required conversion-retention to break even at the higher price:**
   - current_net ÷ new_net = required retention rate
   - Example: $2.99 vs. $3.99 with Apple small-business 15% → $2.5415 vs. $3.3915 → 74.9% retention required.

3. **Estimate reach multiplier from the wedge headline.** Conservative range on anti-subscription-sentiment channels: 2–3× engagement vs. generic "I made an app" framing. Multiply through the conversion funnel.

4. **Wedge wins when:** (wedge_reach × wedge_conversion × wedge_per_sale) > (no_wedge_reach × no_wedge_conversion × no_wedge_per_sale).

Typically the wedge wins by ~2× total revenue at launch, even with the per-sale dollars being smaller.

---

## When to reconsider (post-launch)

The wedge degrades or evaporates when:

- The subscription comp drops their gate (moves the core feature to free tier).
- The subscription comp changes their monthly price away from your dollar-symmetric anchor.
- A new one-time competitor enters at the wedge price.
- Customer reviews start asking for features that imply higher WTP (signal that ceiling has room).

Build these as explicit pre-90-day earlier-review triggers when you commit to a wedge.

---

## What the wedge does NOT excuse

- Adding IAP or a tip jar in the first 90 days. The wedge is "no subscription" — adding any monetary friction undermines the contract.
- Subtitle/description copy that softens the wedge ("Mostly no subscription. Just one optional tip jar."). Either fully commit or pick a different frame.
- Skipping the comp-monitoring step. The wedge depends on what the comp does after you launch. Schedule quarterly comp pricing checks for the first year.

---

## Worked example (UV Burn Timer, 2026-05-18)

| Check | Status | Evidence |
|-------|--------|----------|
| 1. Named subscription comp at dollar-symmetric price | ✅ | QSun UV Tracker at $2.99/mo |
| 2. Subscription gates the core feature | ✅ | QSun gates burn-time calc behind paywall |
| 3. Documented persona pain | ✅ | "SunburnedSailor" App Store review: deleted QSun specifically for the subscription |
| 4. Anti-subscription sentiment in launch channels | ✅ | r/Ultralight, BackpackingLight, r/openwater all have documented anti-sub sentiment |
| 5. Category evidence for one-time success | ✅ | Sunscreen by Apium Co. ($1.99) and dminder Pro ($3.99) both stable one-time for years |
| 6. Low incremental per-user cost | ✅ | WeatherKit bundled with $99/yr dev program; incremental cost ≈ $0 |
| 7. Dollar-symmetric pricing | ✅ | $2.99 once vs. $2.99/mo — exact symmetry |

**All 7 pass. Wedge is load-bearing. Hold $2.99.**

Quantified value: ~2× revenue at launch vs. ceiling-push to $3.99. Per-sale gain of $0.85 (33.4%) at $3.99 is outweighed by ~50% reach loss + ~25%+ conversion loss without the symbolic headline.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
