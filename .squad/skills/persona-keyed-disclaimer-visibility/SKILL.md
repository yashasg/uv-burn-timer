# Skill: Persona-Keyed Disclaimer Visibility (L1/L2/L3 Layered Pattern)

**Author:** Linka (UI/UX, Apple HIG & Accessibility)
**First captured:** 2026-05-19 — UV Burn Timer iOS design spec
**When to use:** When a single legal/safety disclaimer must serve multiple personas with very different appetites for its prominence — and putting it everywhere makes the product feel paranoid, but burying it endangers the highest-risk user.

---

## The problem this skill solves

Health-adjacent or safety-adjacent apps face a recurring design conflict:

- **Low-risk persona** (e.g., the gram-counter who already knows UV exists) treats every visible disclaimer as friction; "I get it, stop nagging me."
- **High-risk persona** (e.g., the user on Accutane or with lupus for whom the app's model under-estimates burn risk by a clinically meaningful amount) needs the disclaimer to be **reachable from the result surface**, not buried six taps deep behind a Settings → About → Privacy chain.

The naive solutions both fail:
- **Modal-only on first launch** (re-fires per cold launch): satisfies legal but leaves the high-risk persona with no recourse mid-session when they're staring at a too-optimistic burn time.
- **Inline persistent disclaimer on every result**: legally bulletproof but trains the low-risk persona to banner-blind.

The pattern below threads the needle by **layering** the disclaimer at three different prominence tiers, each keyed to a different persona's mental model.

---

## The pattern: L1 + L2 + L3 + L4

### L1 — Hard gate, first launch + every cold launch
- **Surface:** Full-screen modal (`.fullScreenCover` on iOS), unskippable, one button: "I understand."
- **Re-fires:** Every cold launch. No "Don't Show Again." (Donatello M1.)
- **Persona served:** Legal/policy primarily. The low-risk persona accepts it because it's once-per-session and gone. The high-risk persona sees it but treats it as ambient — the L3 surface is what they'll actually use mid-task.
- **Critical content rules:**
  - Lead with a question, not "Important Notice." A question primes reading; a notice primes dismissal.
  - Highest-stakes lines (children, medical conditions) get **their own line + glyph**, not buried mid-paragraph.
  - Include an inline link to the L3 destination ("See About for conditions and medications that may affect this estimate") so the modal isn't a dead end.

### L2 — Always-on ambient footer
- **Surface:** Persistent text below every screen that displays the safety-critical value (the burn-time number, in our case).
- **Voice:** Short, declarative. "Estimate only. Not medical advice. Cover up if skin reddens."
- **Touch behavior:** Inert text — NOT tappable. (Tappable footer becomes a dark pattern: users will tap it to make it go away.)
- **Persona served:** Low-risk persona, ambiently. They will banner-blind after session 3; that's fine. The text is there for compliance + spillover-glance moments + accessibility (VoiceOver reads it as part of the screen).
- **Contrast rule:** Footer copy must meet WCAG AA against background but NOT compete with the hero number. Use secondary label color. The footer is meant to be peripheral, not focal.

### L3 — Persona-keyed, verdict-card inline link
- **Surface:** A subordinate but visible affordance directly on the result/verdict card. Phrased as a **second-person question** addressed to the user's situation, not a clinical category name.
  - ✅ "Is this estimate for me?"
  - ⚠️ "Photosensitizing medications and conditions" (clinical, but feels like it's for someone else)
  - ❌ "Disclaimer details" (low information, feels like fine-print)
- **Behavior:** Deep-link to an anchored section in About (e.g., `notForMe` anchor reached via `ScrollViewReader` on iOS). Anchor lives **near the top** of About, not buried.
- **Destination heading** can be more clinical than the link itself. Pattern: question-as-link → declarative-as-destination ("Is this estimate for me?" → "When this estimate may not apply").
- **Persona served:** High-risk persona (Accutane, lupus, vitiligo, albinism, pregnancy, post-procedure, anti-malarials, certain antibiotics) — the cohort whose actual burn time the model gets *meaningfully wrong* and who therefore most needs to know the model has limits.
- **Visibility rule:** The link must be readable without scrolling from the hero number. It is subordinate to the number but visible at the same glance.

### L4 — About, the source of truth
- **Surface:** Long-form, scrollable, copy-paste-able. Cites Diffey/Fitzpatrick math, lists the categories that move the estimate.
- **Persona served:** The methodologist who wants to verify, the high-risk user clicking through from L3, and any external auditor.
- **Rule:** L4 sections must be **anchor-linkable** so L3 deep-links can land precisely. Do not put the most safety-critical content (the "may not apply" list) at the bottom — put it near the top of About.

---

## Applicability checklist — all 5 must be true

The pattern is *worth the build complexity* only when ALL of these hold:

- [ ] **1. There is a documented persona for whom the app's model is wrong in a safety-critical direction.** Not just "could theoretically be misused" — an actual user cohort (medication X, condition Y) where the app's output under-estimates harm by a meaningful amount.
- [ ] **2. That persona will not see themselves in L1 alone.** Modal-blind, or processes the modal as "for someone else." They need an in-result-context affordance.
- [ ] **3. There is a low-risk persona who would treat L3-style visibility everywhere as friction.** If everyone is high-risk, just make L3 the default. The pattern is for *mixed* cohorts.
- [ ] **4. The result surface has room for a subordinate-but-visible link** below the hero value. If the result UI is already crowded, redesign the result first; don't bolt L3 onto a busy screen.
- [ ] **5. About (L4) has a single owner who'll keep the "may not apply" list current.** Stale L4 content is worse than no L3 — the link goes somewhere outdated.

If any check fails, fall back to a simpler pattern (L1 + L2 only, or persistent inline-on-result), accept the costs, and document the choice.

---

## Persona prominence table (the design move)

You can render the layer-to-persona mapping as a small matrix in the design spec — this is the artifact that gets stakeholder buy-in:

| Persona | L1 modal | L2 footer | L3 verdict link | L4 About |
|---|---|---|---|---|
| Low-risk (gram-counter, gear-weight) | First exposure | Banner-blind by S3 — fine | Ignored — fine | Never opened — fine |
| Methodologist (wants math) | First exposure | Glanced | Tapped once for curiosity | Read thoroughly |
| **High-risk (Accutane/lupus)** | First exposure | Cross-checked against L3 | **Primary surface** — they use this | Read thoroughly |
| New/unsure user | First exposure | Glanced | Sometimes tapped | Bookmarked |

The high-risk row is the existence-proof for L3. If L3 doesn't exist, that row's "Primary surface" cell becomes "Buried — DANGER."

---

## Wording rules

- **L1 title:** A question, not a notice. ("How accurate is this for you?" beats "Important Notice.")
- **L1 body:** Highest-stakes lines get their own row + glyph. Avoid wall-of-text.
- **L2 footer:** ≤ 12 words. Declarative. Inert.
- **L3 link:** Second-person question. ≤ 6 words ideally.
- **L4 destination heading:** Declarative. Can be clinical.
- **L3 → L4 deep-link:** Smooth-scroll to anchor, do not flash-jump. On iOS use `withAnimation { proxy.scrollTo(anchor, anchor: .top) }`.

---

## What the pattern is NOT

- **Not a way to soften L1.** L1 stays hard-gated. L3 is *additive* to L1, not a replacement.
- **Not a "Don't Show Again" loophole.** Per Donatello M1: no "Don't Show Again" on L1. L3 doesn't change that.
- **Not a tip-of-the-iceberg pattern.** L3 must point to real L4 content, not a stub. If L4 isn't ready, don't ship L3.
- **Not for marketing copy.** Don't repurpose L3 as a "premium tier" or upsell affordance. It is safety-critical UI, period.

---

## Implementation notes (iOS SwiftUI)

```swift
// L3 link inside the verdict card
Label("Is this estimate for me?", systemImage: "info.circle")
    .font(.footnote.weight(.medium))
    .accessibilityLabel("Is this estimate for me? Opens About, conditions and medications that may affect this estimate.")
    .onTapGesture {
        aboutAnchor = .notForMe
        showAbout = true
    }

// Sheet receives the anchor and scrolls
.sheet(isPresented: $showAbout) {
    AboutView(initialAnchor: aboutAnchor)
}

// Inside AboutView
ScrollViewReader { proxy in
    ScrollView { /* sections, each with .id(AboutAnchor.xxx) */ }
        .onAppear {
            if let anchor = initialAnchor {
                withAnimation { proxy.scrollTo(anchor, anchor: .top) }
            }
        }
}
```

Accessibility: the L3 link's `accessibilityLabel` must spell out the destination, because the visual context ("on the verdict card") isn't available to VoiceOver.

---

## Worked example (UV Burn Timer, 2026-05-19)

| Layer | Surface | Content | Persona prominence |
|---|---|---|---|
| L1 | `.fullScreenCover` on cold launch | "How accurate is this for you?" + full disclaimer + see-About inline link | All personas, once per session |
| L2 | Persistent footer on every screen with a burn-time number | "Estimate only. Not medical advice. Cover up if skin reddens." | Ambient |
| L3 | Inline `Label` below verdict-card context line | "Is this estimate for me?" → deep-links to About `notForMe` anchor | High-risk persona (Accutane/lupus); low-risk persona ignores |
| L4 | About sheet, `notForMe` anchor | "When this estimate may not apply" — categories list | Methodologist, high-risk user |

All five applicability checks passed. Pattern is load-bearing for the Accutane/lupus persona safety case.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
