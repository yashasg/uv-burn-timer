# Orchestration: Design, Science, and Legal Fan-Out (2026-05-19)

**Date:** 2026-05-19T00:10:00 – 2026-05-19T00:30:00 (Pacific)
**Coordinator Intent:** Cross-check user directive against multi-disciplinary review (design × skin science × legal compliance).
**Pattern:** Parallel fan-out with mid-flight convergence checks. Two independent sub-flows (Linka+Suchi in parallel; Wheeler+Plunder in parallel) with post-flight integration gate.

---

## Orchestration Flow

```
┌─── User directive (NCBI Fitzpatrick canonical) ───┐
│                                                     │
├─ Suchi (User Research)        ─┐                  │
│  • Persona × screen matrix     │                  │
│  • JTBD per channel            │ [Parallel]      │
│  • P4 (Accutane) load-bearing │ [No sync]       │
│                                ├─ Convergence check
├─ Linka (iOS Design Spec)      ─┤ (pre-Scribe)
│  • IA, screen-by-screen        │ • Suchi's no-default
│  • Three-surface disclaimer    │ • Linka's no-default
│  • Live timer + Dark mode      │ • Wheeler's behavioral
│  • L1/L2/L3/L4 layers         │   anchor
│                                │ ✅ Converged: no-default
│ [Started before Suchi brief    │ [Zero coordination]
│  landed; re-checked during]    │
│                                │
├─ Wheeler (Skin Science)       ─┐
│  • NCBI verification           │
│  • MED anchor table            │ [Parallel]
│  • Time-to-burn formula        │ [No sync]
│  • Photosensitization          ├─ Convergence check
│    disclosure (3 surfaces)     │ (pre-Scribe)
│                                │ • Suchi's 3-surface
├─ Plunder (Legal/Compliance)  ─┤ • Linka's 3-surface
│  • Citation licensing          │ • Wheeler's 3-surface
│  • Verbatim-vs-edited debate   │ • Plunder's regula-
│  • Attribution wording         │   tory framing
│  • Disclaimer frame            │ ✅ Converged: L1/L2/L3/L4
│  • App Store surfaces          │ [Zero coordination]
│  • Attorney checklist          │
│                                │
└─────────────────────────────────┘
        ↓
[Scribe merges into D-2026-05-19-008..012]
[Coordinator escalates 🟡 D-2026-05-19-009 to user]
```

---

## Agent Profiles & Timelines

### Suchi (User Researcher)
- **Start:** 2026-05-19T00:10:00 (concurrent with Coordinator directive)
- **Input:** User directive (NCBI), prototype surfaces, prior persona work
- **Work:** Persona × screen matrix (P1–P5 + edge cases P6/P7), JTBD per flow, accessibility contexts, persona-keyed disclaimer visibility, three new channels
- **Output:** `.squad/decisions/inbox/suchi-design-brief.md` (482 lines)
- **Key finding:** P4 (Accutane Asha) **load-bearing** — photosensitization is a safety boundary, not edge copy. Disclaimer must be reachable from verdict card.
- **Key recommendation:** No-default Fitzpatrick picker (anchor effect ~50% on Types I/II).
- **Integration:** Passed to Linka (design lead); referenced by Wheeler + Plunder.

### Linka (UI/UX Designer)
- **Start:** 2026-05-19T00:10:00 (concurrent; had not waited for Suchi brief at start)
- **Input:** Prototype surfaces, iOS HIG, prior decisions D-2026-05-19-001..007, Suchi's `.squad/agents/suchi/history.md` (pre-this-session)
- **Work:** IA (single-root NavigationStack), screen-by-screen spec (DisclaimerCover, NowView, SettingsSheet, AboutView), live timer surface, Dark mode + outdoor readability, L1/L2/L3/L4 disclaimer layers, design tokens (AAA contrast, color-blind safe)
- **Output:** `.squad/decisions/inbox/linka-ios-design-spec.md` (1,122 lines)
- **Re-check during work:** Suchi brief landed mid-pass; Linka integrated every directive into spec (§12 "Suchi sync log" lists edits, §14 lists targeted revisions).
- **Key finding:** Three-surface disclaimer pattern (L1 cover, L2 footer, L3 verdict photosensitizer, L4 About) is the design-native anchor for P4 personas.
- **Key recommendation:** No-default Fitzpatrick picker (design confirms user must explicitly choose).

### Wheeler (Skin Science)
- **Start:** 2026-05-19T00:25:58 (after user directive + Suchi brief landed)
- **Input:** User directive (NCBI), Suchi brief, prior decisions D-2026-05-19-001..007
- **Work:** NCBI source verification (§1.2 verbatim diff), MED anchor table (§2 per-type J·m⁻² values + CIE weighting), time-to-burn formula (`t = (MED × SPF) / (UVI × 0.025 × 60)`), three-surface photosensitization disclosure, verbatim-vs-edited recommendation
- **Output:** `.squad/decisions/inbox/wheeler-fitzpatrick-and-med-anchor.md` (462 lines)
- **Key finding:** Three-surface photosensitization disclosure is a **safety boundary, not edge copy** (matches D-2026-05-19-007 independently).
- **Key recommendation:** Ship NCBI verbatim text (clinical convention; edited variant also acceptable and internally consistent).

### Plunder (Legal & Compliance)
- **Start:** 2026-05-19T00:30:00 (after Wheeler spec landed)
- **Input:** Wheeler recommendation, user directive, Suchi brief, prior decisions D-2026-05-19-001..007, Linka spec
- **Work:** Citation licensing taxonomy (§1.1–1.5), NCBI Bookshelf analysis (§2.1–2.3 and §C1), NC-license implications (§2.2, §4), verbatim-vs-edited reconciliation (§C2 Option 1 vs. Option 2), WeatherKit attribution lockup, disclaimer ratification (§8), App Store surfaces (§9), attorney pre-submit checklist (§10)
- **Output:** `.squad/decisions/inbox/plunder-citation-framework.md` (848 lines)
- **Key finding:** Both verbatim and edited paths are acceptable **with explicit conditions**. Verbatim requires "adapted from" + attorney review. Edited (Plunder-preferred) sidesteps NC question entirely.
- **Key recommendation:** Escalate verbatim-vs-edited decision to user; both paths are compliant.

---

## Convergence Checks (Captured in Decisions Ledger)

### ✅ No-Default Fitzpatrick Picker (High-Confidence Signal)

| Agent | Finding | Evidence | Timing |
|-------|---------|----------|--------|
| **Suchi** | Anchor effect ~50% on Types I/II → recommend no-default | `.squad/decisions/inbox/suchi-design-brief.md` §1.2 | 2026-05-19T00:10 |
| **Linka** | Designed picker as explicit user selection (no auto-select) | `.squad/decisions/inbox/linka-ios-design-spec.md` §2.2 SkinTypeView | 2026-05-19T00:10–00:25 |
| **Wheeler** | "Assumed defaults" flagged as behavioral anchor risk | `.squad/decisions/inbox/wheeler-fitzpatrick-and-med-anchor.md` §6 | 2026-05-19T00:25 |

**Pattern:** Three independent agents, zero inter-agent coordination required, same conclusion. **Convergent triangulation = high-confidence UX/safety decision.** Now locked as D-2026-05-19-012 `active`.

### ✅ Three-Surface L1–L4 Layered Disclaimer Pattern (High-Confidence Signal)

| Agent | Design Element(s) | Evidence | Timing |
|-------|-------------------|----------|--------|
| **Suchi** | P4 load-bearing disclaimer; reachable from verdict card | `.squad/decisions/inbox/suchi-design-brief.md` §1.1 P4 row | 2026-05-19T00:10 |
| **Linka** | L1 (DisclaimerCover), L2 (footer), L3 (verdict photo), L4 (About) | `.squad/decisions/inbox/linka-ios-design-spec.md` §2.1–2.3 + §3 | 2026-05-19T00:10–00:25 |
| **Wheeler** | Three-surface photosensitization disclosure (matches safety boundary) | `.squad/decisions/inbox/wheeler-fitzpatrick-and-med-anchor.md` §6.1 | 2026-05-19T00:25 |
| **Plunder** | Disclaimer ratification + regulatory framing | `.squad/decisions/inbox/plunder-citation-framework.md` §8 | 2026-05-19T00:30 |

**Pattern:** Four independent agents, all designed their respective layers before cross-check. **Convergent across design, science, legal = canonical pattern.** Now locked as D-2026-05-19-011 `active`.

---

## Unresolved: 🟡 Verbatim-vs-Edited Picker Copy (D-2026-05-19-009)

### The Debate

**Wheeler's recommendation:** Ship NCBI verbatim text.
- Rationale: Clinical convention; 50-year-old classification; short factual phrases; attribution string already names source.
- Path: "White skin. Always burns, never tans." [etc., all six types verbatim from NCBI Table 1]

**Plunder's framework:** Both acceptable with conditions.
- **Option 1 (Wheeler's verbatim):** Requires "adapted from" wording in About + attorney review flag (live pre-App Store). Australian copyright doctrine may treat short phrases differently; Codon CC BY-NC 4.0 does not have originality escape hatch.
- **Option 2 (edited variant, Plunder-preferred):** "Very fair skin / Fair skin / Medium skin tone / Light-brown skin / Brown skin / Deeply pigmented skin" [behavioral phrasing preserved]. Removes NC question; attribution says "adapted from" (accurate); Suchi's directive #4 (behavior-first, symmetric framing) honored.

### Why Escalated to User

- **User's original directive** pinned NCBI as canonical but did not specify verbatim vs. adapted.
- **License posture ambiguous:** Codon Publications CC BY-NC 4.0 on NCBI Bookshelf. Verbatim picker copy falls in a gray zone (short factual phrase vs. creative expression; U.S. vs. Australian copyright doctrine).
- **Both paths ship NCBI as citation anchor.** The debate is picker-copy form only.
- **Legal + Science need user sign-off.** Wheeler + Plunder reached different conclusions; Coordinator must surface for user final call.

### Decision Mark

🟡 **PROPOSED** — not active until user responds. Coordinator is escalating to user; Scribe has flagged this decision as "open for user input" in the ledger.

---

## Orchestration Insights (for Scribe History)

1. **Convergent triangulation pattern:** When 3+ agents independently reach the same conclusion without inter-agent coordination, mark as high-confidence in the ledger. Suchi/Linka/Wheeler on no-default picker; Suchi/Linka/Wheeler/Plunder on three-surface disclaimer.

2. **Proposed-vs-active marking:** Use 🟡 **PROPOSED** when a decision is multi-stakeholder but remains open (like verbatim vs. edited). Do not mark active until all stakeholders align or user resolves. Coordinator owns escalation.

3. **Parallel-with-re-check pattern:** When agents work in parallel (e.g., Linka starts before Suchi lands), design re-check mechanisms. Linka did mid-pass integration (§12 sync log); this prevented rework and made convergences visible.

4. **Cross-agent notation in archive:** When merging to decisions.md, cite source files and capture which agents independently converged. This signals high-confidence design decisions and surfaces areas where user input is needed.
