---
name: "persona-screen-matrix"
description: "A handoff template from User Researcher to Designer. For each major screen/surface in a prototype, capture what each top persona NEEDS to SEE / NEEDS to DO / NEEDS to AVOID. Forces the researcher to translate verbatim quotes into actionable design constraints, and forces the designer to see the same screen through multiple persona lenses rather than averaging. Has a sibling variant — persona-as-overlay-on-flow-diagram — for handoffs to a designer who is drawing a user-flow / Excalidraw artifact rather than (or in addition to) individual screens."
domain: "user-research, ux-design, design-handoff, persona-research, flow-diagrams"
confidence: "medium-high"
source: "earned — UV Burn Timer design-lens pass on `prototype/index.html` (Suchi, 2026-05-19, persona × screen matrix in `.squad/decisions/archive/suchi-design-brief.md`). Validated a second time by the Excalidraw-flow overlay variant (Suchi, 2026-05-19T01:15:44-07:00, `.squad/files/suchi-persona-annotations.md`)."
---

## Context

Use when:
- A User Researcher has already done qualitative persona work (real threads, verbatim quotes) and now needs to hand the personas off to a Designer in an **actionable** form.
- A Designer is about to begin work on a prototype and needs to know **which persona breaks on which screen** — not which persona is "most important."
- The team is small enough that the researcher and designer are pairing, not communicating through PRD-by-Notion.

This pattern resists the most common failure modes of persona handoff:
- Generic personas (demographics, no scars).
- One-paragraph persona "summaries" that don't tell the designer what to actually do.
- Designer averaging across personas because the handoff didn't force specificity.
- Researcher quoting verbatim in a vacuum without converting the quote into a design constraint.

Pair tightly with: existing JTBD framing, accessibility-context lists, mental-model-trap analysis. The matrix is the **center** of a fuller brief, not the entire brief.

## Patterns

### Inputs the researcher must have before starting

1. **Top 4–6 personas, named, with at least one verbatim quote each.** If the personas are "Persona A / Persona B" or are described by demographics ("woman 25–34, urban"), the matrix will not work. Personas need names, scars, and a documented JTBD.

2. **Every surface in the prototype, enumerated.** Walk it screen by screen. Include error states, modals, onboarding flows, and ambient elements (footers, persistent disclaimers). Don't skip the "small" screens — they're often where personas diverge most sharply.

3. **A vocabulary for the cells.** This skill uses **NEEDS to SEE / NEEDS to DO / NEEDS to AVOID** because:
   - SEE is content / information requirements.
   - DO is interaction / affordance requirements.
   - AVOID is the negative space — what would break this persona's trust or task.
   - All three forces are present on every screen; if the researcher can't fill all three for a (persona, screen) cell, it's a sign that either the persona or the screen needs more work before continuing.

### The matrix structure (one table per screen)

```
| Persona | Needs to see | Needs to do | Needs to avoid |
|---------|--------------|-------------|----------------|
| P1 [name] | [content] | [interaction] | [anti-pattern] |
| P2 [name] | ... | ... | ... |
| ... | ... | ... | ... |
```

Then, **below each matrix**, a "Design directives to [Designer]" bulleted list synthesizing what the cells imply that the designer should DO. The cells are diagnostic; the directives are prescriptive.

### What goes in each cell — quality rubric

**Good cell content:**
- Quotes the persona verbatim where possible. ("Verbatim from her cohort: ...")
- References a real behavior, scar, or constraint from the persona's documented life.
- Marks INFERRED clearly when extending beyond a citation.
- Is specific enough that the designer could violate it. ("Tap targets ≥ 52pt for wet hands" beats "good touch targets.")

**Bad cell content:**
- "User wants a clean interface." (every persona; not actionable)
- "User needs to feel safe." (vague; what action does this drive?)
- "Same as P1." (if two personas have identical needs on a screen, the matrix is averaging — re-check the personas.)

### When two personas have the same cell

If three personas all have the same "Needs to see" on a screen, that's a strong design signal — the cell is **load-bearing**. Note it explicitly: "All three of P1/P2/P3 need X; this is a load-bearing element."

If two personas have **contradictory** cell content on the same screen (P1 needs the disclaimer prominent, P5 needs it invisible), the matrix has surfaced a **design tension** that requires a layered or contextual solution. This is the highest-value output of the matrix — it's the moment the designer sees a real tradeoff.

### Synthesizing across the matrix

After all the per-screen tables, write a "**Design directive synthesis**" section. Cluster the directives by:

1. **Universal wins** (every persona benefits — do these first).
2. **Persona-specific wins** (designer can implement without conflict).
3. **Tensions** (require a layered, contextual, or progressive-disclosure solution).
4. **Out-of-scope acknowledgments** (a persona need the team has decided not to serve — surface honestly).

### Edge-case persona pass

After the primary matrix, do a second pass: **who is the prototype implicitly assuming away?** Walk the same screens but with personas the launch plan does NOT target. Common cases:
- Dependents / children being monitored by adults.
- Users on the extreme ends of a quantitative scale (e.g., albinism on a Fitzpatrick I–VI scale).
- Users with a condition that violates a model assumption (e.g., vitiligo violates "one skin type per user").
- Underserved demographics within the targeted set (e.g., Fitz V/VI within a sun-safety app).

For each, decide: (a) design something, (b) disclose in About / help, (c) do nothing — and document **which** choice you made and why. "Do nothing" is a valid answer if you've considered it.

## Examples

### Worked example: UV Burn Timer disclaimer modal (excerpted)

| Persona | Needs to see | Needs to do | Needs to avoid |
|---------|--------------|-------------|----------------|
| **P1 Gram-counter Greta** (u/hareofthepuppy archetype) | Short, no-fluff "this is an estimate, not a measurement" line. | One tap dismiss. | Anything that smells like a marketing wall or sign-up gate. Tolerance for friction-before-value is zero. |
| **P4 Accutane Asha** (u/Affectionate_Nose_79 archetype) | Phrase "skin response varies" + a line naming photosensitizing medications/conditions. Verbatim: *"Like the UV is maybe 3 and it looks like Ive rolled a few."* | Read carefully, then dismiss. Be able to reach this content again from the verdict card. | A disclaimer she can't find later. |
| **P5 Trail-run Tomás** (u/Amazing-Reporter1845 archetype) | Almost nothing. He's at the trailhead, one earbud in. | One tap, < 4 seconds. | A modal that requires reading time. He'll dismiss; the footer disclaimer must do real work for him. |

**Design directive synthesis from this cell:**
- The first-launch modal must be **hard-gated** for Asha but **fast** for Tomás — those are not in conflict: a 4-second reading time hard gate is doable.
- A reachable re-entry path from the verdict card (NEW affordance) resolves Asha's "I dismissed it and forgot" risk.
- The current single-paragraph copy is too dense. Pull the photosensitization category to the **first body line**.

This single cell forced three concrete design directives — the matrix earns its keep.

### Counter-example: when the matrix doesn't help

If the prototype is a marketing landing page (one screen, one CTA), the matrix degenerates to "everyone needs to see the CTA." Skip the matrix and use a different framework (e.g., funnel analysis, message-test).

If the personas are not yet well-researched (no quotes, no scars, demographics-only), do the persona work first. The matrix amplifies persona quality — it does not substitute for it.

## Anti-Patterns

- **Filling the cell with adjectives.** "Clean," "intuitive," "modern." These are aesthetic preferences, not persona needs. Replace with a behavior or a content requirement.

- **Quoting persona research without translating to a constraint.** A verbatim user quote in a research doc is data. A verbatim user quote in a design handoff that has no implied design constraint is decoration. Each quote should imply "therefore, on this screen, the designer should..."

- **Letting the matrix become a wishlist.** Every persona cell should be either (a) addressable by the designer or (b) explicitly acknowledged as out-of-scope. Open-ended needs without a disposition decision rot in the doc.

- **Skipping the AVOID column.** Designers often discover the most expensive mistakes in the AVOID column — the wrong default, the unintended exclusion, the gesture that fails for wet hands. If the AVOID column is mostly empty, the researcher hasn't pushed the personas hard enough.

- **Pretending design tensions don't exist.** If two personas need opposite things on a screen, the matrix MUST surface that. The designer needs to know there's a tension to resolve. "Average the personas" is the wrong answer; "layered/contextual UI" is usually the right one.

- **One matrix for one persona.** A single-persona matrix is just a persona doc with extra steps. The point of the matrix is **comparison across personas on the same surface.** If you only have one persona, write a persona doc instead.

- **Treating the matrix as a deliverable.** It is a **diagnostic instrument** that feeds the design directives. The deliverable is the directives; the matrix is the work behind them. If the recipient designer only reads the directives, the matrix has still done its job.

- **Forgetting the edge-case-persona pass.** The primary matrix tells you what your launch personas need. The edge-case pass tells you who you'll silently fail — which is often the more important set of design decisions.

## Variant — Persona-as-overlay-on-flow-diagram

When the recipient designer is drawing a **user-flow diagram** (Excalidraw, Figma flow, Miro) rather than (or in addition to) individual screens, the per-screen matrix doesn't survive translation. The flow artifact is sequential; the matrix is parallel. Convert the matrix into an **overlay spec**: one document the designer reads mid-canvas to add a persona-keyed lane (or set of callouts) on top of the canonical flow.

### When to use this variant

- The team has reached "design v1" and is now drawing the canonical flow for handoff to engineering, marketing, App Store reviewers, etc.
- The designer has canvas authority — you are not drawing.
- There is parallel work happening (researcher writes overlay spec, designer draws canvas) and the spec must be readable mid-task.

### Structure of the overlay spec

1. **Personas reference card** — names, Fitz/type, source, scar quote, suggested lane color. Suggest colors that pass colorblind simulation (Coblis / Sim Daltonism).
2. **Per-screen annotations** — for each screen in the canonical flow, one line per persona unless the persona breaks the screen hard enough to need more. Mark STICKY screens (where a persona dwells), BRANCH screens (where a persona diverges), and RISK screens (where the persona is in danger of mis-using).
3. **Branch-Point Specials** — 3–5 places in the flow where persona divergence creates a design tension the diagram should annotate visually. For each: where, who diverges and how, and what the designer should draw (color, callout, arrow target).
4. **Visual hints for the designer** — dashed vs. solid vs. dotted arrows; sticky-disclaimer indicators; swimlane structure; which lanes to merge if density is too high.
5. **Quotes inventory** — verbatim quotes with their target annotation, so the designer can drop them inline on the canvas where space allows.

### Repeating-use pass (new — surfaced by the overlay exercise)

The per-screen matrix implicitly snapshots each persona at one moment. The overlay forces a **repeating-use pass**: how does each persona's relationship to the screens change after their 1st, 10th, 100th launch? This often surfaces JTBD shifts that the matrix missed — e.g., a persona whose primary need shifts from "first verdict" to "reapplication cadence" after one successful use. Add a "Main screen — repeating use" row to the overlay spec.

### Anti-pattern: drawing a screen we don't have

If the user directive lists a screen that the architecture deliberately does not have (e.g., "photosensitization attestation screen" when the data architecture is zero-data and attestation would require collecting special-category medical data), **do not reify it on the canvas.** Draw the actual pattern (e.g., a side-quest cluster off the modal where the user reads cohort info without storing status) and label it with the architectural rationale. The researcher's job in the overlay spec is to call this out explicitly so the designer doesn't draw the assumed-but-absent screen.

### Branch-point density rule of thumb

A flow with 5 personas × 6 screens has 30 cells in principle, but a diagram can only show ~5 visually-distinct branch annotations before it becomes unreadable. The overlay spec must therefore **rank** the branch points by safety-criticality and design-tension. Top 3 are mandatory annotations; 4–5 are if-space-allows; the rest are documented in the spec but not on the canvas. The diagram is not a complete enumeration — it is a teaching artifact for the most important divergences.

### Worked example: UV Burn Timer onboarding + main-screen flow

The overlay spec at `.squad/files/suchi-persona-annotations.md` (Suchi, 2026-05-19) is the canonical worked example. 5 personas × 6 screens, 5 Branch-Point Specials, ~222 lines. Key learnings from that exercise:

- The repeating-use pass surfaced that Persona 1 (Greta)'s JTBD shifts from "first verdict" → "reapplication cadence" once she's seen one number — the L2 footer (not the verdict card) becomes her primary surface. The per-screen matrix had missed this entirely.
- The "photosensitization attestation" framing in the user directive was wrong by architecture, not by oversight; the overlay spec is the right surface to flag this explicitly and propose the visibility-loop alternative.
- One persona (Tomás) had a symmetric under-picking risk on Fitzpatrick V that the per-screen matrix had not explicitly connected to the behavior-first copy rule — the overlay made the connection visible.
- One persona (Maya) was discovered to be unable to read repeating-use screens at all (she's in the water), making her pre-action verdict the only safety-critical reading — an insight that only surfaces when projecting personas across the full flow.
