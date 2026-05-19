---
name: "health-adjacent-constant-adoption"
description: "A discipline for adopting any numerical constant, formula, or classification that touches user health or safety. Forces the adopter to name the source, verify the verbatim text, label confidence per value, and bound the claim surface before any of it lands in code or UI. Resists the silent-guess failure mode where a plausible-looking constant ships without provenance."
domain: "health-adjacent, science-spec, citation-discipline, formula-derivation"
confidence: "medium"
source: "earned — UV Burn Timer Fitzpatrick / MED / time-to-burn adoption pass (Wheeler, 2026-05-19). Validated against the NCBI Bookshelf NBK481857 + WHO 2002 UVI Guide + Diffey 1991 source set; spec at `.squad/decisions/inbox/wheeler-fitzpatrick-and-med-anchor.md`."
---

## Context

Use when:
- An app needs to ship a health-adjacent number — a dose threshold, a classification scale, a clinical formula, a body-modeling constant — and the team is tempted to copy it from the first plausible-looking source.
- The number will be exposed (directly or indirectly) to end users as advice, guidance, or a calculated result they will act on.
- The team has a citation-discipline mandate (legal, compliance, or self-imposed) and needs a repeatable process to produce evidence trails that survive scrutiny.

This pattern resists the most common failure modes of health-adjacent constants:
- "Diffey says…" — citing an author's name as if naming an author *is* a citation.
- Copying numbers from a Wikipedia table or a blog post without checking the primary source.
- Mixing units silently (mJ/cm² broadband-UVB clinical doses vs. J/m² solar-erythemal — a 5–10× difference).
- Mixing a 1981-era constant with a 2002-era spectral weighting without checking they're internally consistent.
- Shipping a "reasonable approximation" without labeling it as such, so downstream readers can't tell which numbers are bedrock and which are gap-fillers.
- Building a formula whose constants are well-cited but whose *combination* extends a claim beyond what any single source supports.

Pair tightly with: existing legal-claim review, prototype unit-testing, the `cite the sources` mandate. The protocol is the **front gate** to any health-adjacent science spec, not the entire spec.

## Patterns

### The seven-step protocol

#### 1. SOURCE — pick the canonical reference

- Prefer (in order): an international standards body (WHO, CIE, ISO, ICNIRP, IEC) → a peer-reviewed primary paper (the *original* measurement or formulation) → a peer-reviewed modern review that explicitly cites the primary → a textbook → an open-access curated reference like NCBI Bookshelf when it directly reproduces clinical scales.
- **Reject:** Wikipedia, blogs, app store competitor copy, the AI chat that gave you the number, "I've seen this in a few places."
- For each candidate source, note: who published it, what year, whether it is open-access or behind a paywall (matters for the user-facing About surface), and what license terms govern reuse vs. citation.

#### 2. VERIFY — direct-fetch and verbatim-diff

- Open the source URL (or the paper PDF) yourself, in this session. Do not trust a summary, a paraphrase, or a memory.
- Diff the source text against the value or scale you're about to adopt. Quote it.
- If the diff is non-trivial, the divergence is the news. Document it precisely.
- If the source is offline / paywalled and you cannot verify, that is a finding: name the source you *cannot* check, and either find an open-access mirror or downgrade the confidence label.

#### 3. DERIVE — lock the specific values, show the working

- Reproduce the table, formula, or scale in the unit system the app will use internally (prefer SI).
- If the source uses a different unit (e.g., mJ/cm² vs J/m²), show the conversion factor with its own citation.
- For ranges (e.g., "MED Type IV: 350–600 J/m²"), pick a single value and state the rule by which you picked it (mid-point, conservative-for-the-user, modal across the literature). Do not silently average.
- Where the formula is composed of multiple sources, show that each constant is internally consistent with the others (same action spectrum, same era, same convention).

#### 4. CITE — author / journal / year, per value, not per spec

- Every value gets its own citation. Not "as per WHO" — "WHO 2002 *Global Solar UV Index: A Practical Guide*, ISBN 92 4 159007 6."
- For derived values, cite both the base and the derivation.
- Distinguish *definitional* citations (the source defines the value by convention) from *empirical* citations (the source measured the value).
- Produce a single canonical citation string suitable for direct drop-in to the user-facing About / Citations surface — bibliographic style consistent with the project's existing citations.

#### 5. LABEL — established / reasonable approximation / out of scope

Every constant in the spec must carry one of these labels:

- **Established** — the source defines it (e.g., WHO UVI = irradiance × 40 m²/W is *definitional*) or multiple independent sources converge on it within a few percent.
- **Reasonable approximation** — the literature gives a range and we picked a value within that range, with a rationale. The number is defensible but not bedrock.
- **Out of scope** — we acknowledge the effect exists but the formula does not include it; the user must know the model is silent on this.

**Never ship a value labeled "guess" or unlabeled.** If you can't put one of these three labels on it, do not ship it — go back to step 1.

#### 6. BOUND — write the "what we do NOT claim" list

For every health-adjacent spec, explicitly enumerate:

- Claims the formula does not support (e.g., "this estimates 1 MED of erythema, not safety, not vitamin D, not tanning").
- Population edge cases the model does not cover (e.g., medications, conditions, pediatrics, pregnancy).
- Conditions under which the model materially fails (e.g., "photosensitization reduces MED 2–10×").
- The corresponding *user-facing surface* where each bound must be disclosed (modal, About, verdict card, footer).

The bound is the most overlooked step. Without it, the cited formula's claim surface silently expands in legal review, marketing copy, and support replies until someone says "the app says X" and X is not actually in the spec.

#### 7. HAND OFF — single canonical drop-in form

Produce one block per consumer:

- For the engineer: pseudo-code in the project's primary language, with the constants in-line and comments naming the citation.
- For the designer / UI: the exact text strings (verbatim if from a clinical scale; "adapted from" if edited, with rationale).
- For the legal / compliance reviewer: the citation-per-claim table from step 4.

Each consumer should be able to act from *their* block without needing to read the full spec. The spec exists as the audit trail; the hand-off blocks exist for the work.

### Anti-patterns this protocol catches

| Anti-pattern | What it looks like | What the protocol forces |
|--------------|--------------------|--------------------------|
| The plausible blog quote | "I read that MED Type I is 30 mJ/cm²" — adopted | Step 2 forces direct-fetch of the primary; step 3 catches the unit mismatch (mJ/cm² broadband-UVB ≠ J/m² solar-weighted) |
| The orphaned constant | "We use 0.025 W/m² per UVI" — no citation in the codebase | Step 4 forces citation per value, inline at the call site |
| The silent gap-filler | "I just picked something reasonable for Type V" — value unlabeled | Step 5 forces a label; "reasonable approximation" is the label and forces the rationale |
| The expanding claim | Cited formula computes A; marketing copy implies B | Step 6 forces a "what we don't claim" list at adoption time |
| The mixed era / mixed convention | 1980 MED value + 2014 action spectrum, never reconciled | Step 3 forces showing internal consistency across the chosen source set |
| The author-name-as-citation | "Per Diffey…" appears in user-facing copy | Step 4 produces a single canonical citation string with full bibliographic detail |

### When to skip the protocol

You can skip this protocol when:
- The constant has no health-adjacency (e.g., "we round coordinates to 2 decimals" — that's privacy, not health math).
- The constant is purely UI (e.g., "we use 8-point grid"); aesthetic, not safety.
- The constant is internal to the project (e.g., a polling interval) and is never exposed as user-facing guidance.

Do **not** skip when:
- The constant or formula will produce a number the user acts on with their body.
- The constant or formula could be cited in a support reply, App Store description, or marketing post.
- The constant is part of a clinical, medical, or safety classification — even an informal one.

## Examples

### Example 1: adopting the Fitzpatrick MED table (UV Burn Timer, 2026-05-19)

- **Source.** NCBI Bookshelf NBK481857 Table 1 (Ward & Farma 2017) for the *six-type classification*; Fitzpatrick 1988 + Sayre 1981 + Diffey 1991 + Harrison & Young 2002 weighted by CIE S 007/E:1998 for the *MED values*. Five independent sources because the scale and the values come from different bodies of work.
- **Verify.** Direct-fetched the NCBI page. Diffed all six rows verbatim against the user's directive. No divergence.
- **Derive.** Picked single-value MED per type (200/250/300/450/600/1000 J/m²) from the range each primary source gives. Showed the conversion to SED (÷100).
- **Cite.** Each row carries its citation. The picker copy carries the NCBI/Ward citation. The MED table carries the Fitzpatrick/Sayre citations. The action-spectrum weighting carries the CIE citation.
- **Label.** Types I–III: established. Types IV–VI: reasonable approximation (range was wider; picked conservative mid-point).
- **Bound.** Wrote explicit "what we don't claim" list — no "safe sun time," no vitamin D, no tanning duration, no cancer-risk implication. Documented photosensitization as the regime where the model materially fails, with citation per drug class and condition.
- **Hand off.** Swift enum for Kwame; verbatim picker text + edited variant for Linka; citation-per-claim table for Plunder.

### Example 2: UVI ↔ irradiance constant (UV Burn Timer, 2026-05-19)

- **Source.** WHO/WMO/UNEP/ICNIRP *Global Solar UV Index: A Practical Guide*, Geneva 2002, ISBN 92 4 159007 6.
- **Verify.** Cross-referenced the WHO definition against the prototype's existing comment (`1 UV index unit ≈ 25 mW/m² erythemal irradiance`). Match.
- **Derive.** UVI × 0.025 W/m² (definitional, not empirical).
- **Cite.** Inline in the Swift `estimateTimeToOneMED` function.
- **Label.** Established / definitional. (Not "reasonable approximation" — this is a definition.)
- **Bound.** Noted that the math is well-defined across all UVI values but display precision degrades at UVI < 1 (long predicted times become uncertain because spectral assumptions degrade at low solar elevation).
- **Hand off.** Single-constant Swift line; About-surface citation string for Plunder.

## Outputs

A spec produced via this protocol should have:

1. A **source vetting** section that names every reference with full bibliographic detail and notes its license posture for citation.
2. A **values table** with one row per constant and one column per attribute (value, unit, source, confidence label).
3. A **formula** stated in plain math and in pseudo-code, with constants linked to the values table.
4. A **claim-surface bound** ("what we do NOT claim") with a row per forbidden claim and a reason per row.
5. A **hand-off matrix** with one row per consumer (engineer, designer, legal) and a pointer to their actionable block.
6. An **open-questions** section that names which questions belong to which other team member by role.

If any of these six sections is missing, the spec is not done. Send it back to step 1.

## Failure modes

- **The protocol becomes paperwork.** If you find yourself filling in templates without doing the verify step, the protocol has failed. The protocol is verification-first; the documentation is the artifact of having verified.
- **Citation theater.** Listing 20 references in the About section without any of them backing a specific value. Each citation must back a specific claim.
- **Confidence label inflation.** Everything labeled "established" because labeling something "reasonable approximation" feels weaker. The opposite is true — honest labels are stronger than over-claimed labels. Treat "reasonable approximation" as a strength, not an apology.
- **Bound list under-population.** Only naming the obvious bounds (no medical advice). The real bounds are the regime-where-the-model-fails ones (e.g., photosensitization for a Fitzpatrick MED model). The hard part is naming the regime where you would be wrong; that is the part the legal reviewer cannot do for you.

## Related skills

- `cite-the-sources` (Plunder discipline — handles the legal-form citation, downstream of this).
- `persona-screen-matrix` (Suchi pattern — surfaces the personas whose safety the bounds in step 6 must serve).
- Project-specific `prototype/README.md` citation pattern (the in-app About surface contract).

---

*Earned in service of: the UV Burn Timer Fitzpatrick / MED / time-to-burn canonical adoption (2026-05-19). The protocol exists because health-adjacent numbers without provenance are the failure mode the rest of the team's discipline cannot recover from. — Wheeler*
