# Skill: Excalidraw Multi-Lane Flow Diagrams via MCP

**Author:** Linka (UI/UX, Apple HIG & Accessibility)
**First captured:** 2026-05-19 — UV Burn Timer onboarding + main-screen user flow
**When to use:** When a Squad agent must produce a flow diagram on the Excalidraw canvas via an MCP server (tools `excalidraw-create_element`, `excalidraw-group_elements`, `excalidraw-query_elements`, etc.) rather than as a static image. The diagram must be readable as a flow (not a UI mockup) and must encode design decisions, branch points, and persona variance in one scene.

---

## The MCP schema gotchas (learn-once)

The `excalidraw-create_element` tool's full schema is:
```ts
{
  type: "rectangle" | "ellipse" | "diamond" | "arrow" | "text" | "label" | "line" | ...,
  x: number,            // required — top-left for rect/text; tail for arrow
  y: number,            // required
  width?: number,       // for rect: width; for arrow: ΔX from tail to head
  height?: number,      // for rect: height; for arrow: ΔY from tail to head
  text?: string,        // for type=text — supports \n for multi-line
  fontSize?: number,
  fontFamily?: string,
  strokeColor?: string,
  backgroundColor?: string,
  strokeWidth?: number, // 1 = thin, 2 = normal, 3 = bold/safety-critical
  opacity?: number,
  roughness?: number
}
```

Six things that bit me on the first pass and would have been easy to miss:

1. **Arrows are `(x, y, width, height)` where width/height are deltas, NOT corners.** An arrow with `x=300, y=320, width=80, height=0` points from `(300,320)` to `(380,320)` — i.e. **80 pixels right, horizontal**. To draw an arrow that points UP-LEFT from `(1450, 1540)` to `(290, 1060)`, use `width = 290 - 1450 = -1160` and `height = 1060 - 1540 = -480`. Negative deltas are how you get up-and-left arrows.

2. **Text elements ignore `width` and `height` for layout.** The text shape sizes itself to its content. If you set `width`/`height` on a text element, the values are stored but the rendered box scales to the string. **Use rectangles for the background, separate text elements for the label.** Trying to put a multi-line caption inside a rectangle by setting text on the rectangle doesn't work the way you'd expect — keep them as sibling elements at the same (x,y).

3. **Text supports `\n` newlines.** Multi-line bullet lists work — write `"• Foo\n• Bar\n• Baz"` and let it render on three lines. This lets you put a content list inside a screen box without 5 separate text elements.

4. **No "rounded corner" param at element level.** You can set `roughness` to 0/1/2 (sketchy-ness) but not a corner radius. Decided not to fight it — Excalidraw's hand-drawn aesthetic is fine for a flow diagram.

5. **The arrow body and the arrowhead are one element.** You don't get to style the head separately; `strokeColor` colors the whole arrow.

6. **`excalidraw-query_elements` returns ALL elements and can blow context.** On a 100+ element scene the JSON is 30–50 KB. **Pipe it through `wc`/`jq`/`python -c` for counts rather than reading the full output.** A `Counter(e['type'] for e in elements)` is the fastest sanity check.

---

## The layout algorithm I converged on

For a multi-lane flow diagram with 3+ lanes:

1. **Reserve a y-band per lane.** Pre-decide lane boundaries before drawing anything. For my UV Burn Timer flow:
   - Title block:   y =   20–100
   - LANE 1 (onboarding screens):   y =  110–460
   - LANE 2 (main screen):          y =  540–1420
   - LANE 3 (branch-point callouts):y = 1480–1970
   - LANE 4 (persona overlays):     y = 2010–2580
   - Legend (parked top-right):     y =  110–350,  x = 1660–2240

2. **For lanes with linear sequences, pre-compute x positions.** Six onboarding screens with 240w boxes and 80px gutters → x = 60, 380, 700, 1020, 1340, 1660. Step = 320. Decide step early; you can't iterate easily once arrows are drawn.

3. **Draw screens FIRST, arrows LAST.** This way the screen positions don't shift after the arrows are pinned. If you draw an arrow then move a rectangle, the arrow stays where it was.

4. **For each screen: rectangle → title text → body text.** Three elements per screen. Use `strokeWidth: 2` for normal-stakes, `3` for safety-critical (the L1 disclaimer modal, the no-default Fitzpatrick callout, the load-bearing persona cells).

5. **Color-code by semantic role, not by aesthetic preference.** Pick a palette where the fill encodes meaning, not just visual variety. For disclaimers I used: red=L1 hard gate, gray=L2 footer (inert), blue=L3 inline link, pink/purple=L4 source-of-truth. Annotation callouts are uniformly yellow to read as "metadata about the flow" instead of "more flow."

6. **Annotations belong in a lane, not floating.** I tried putting branch-point callouts directly next to the screen they describe; it broke the lane structure and made the diagram dense. Putting them in their own LANE 3 with long arrows up to the referenced surface trades drawing distance for visual clarity, and it scales — you can add a 9th callout without re-flowing the upper lanes.

---

## Swimlane convention for persona-keyed flows

When a flow must show how different personas traverse the same screens, **LANE per persona, COLUMN per screen** is the clearest pattern.

```
                  ┌─ Screen 1 ─┬─ Screen 2 ─┬─ Screen 3 ─┬─ Screen 4 ─┐
                  │            │            │            │            │
P1 (color A)  ┌──┤  annotation │ annotation │ annotation │ annotation │
              │  │            │            │            │            │
P2 (color B)  ├──┤  annotation │ annotation │ annotation │ annotation │
              │  │            │            │            │            │
P3 (color C)  ├──┤  annotation │ ★LOAD-BR★  │ annotation │ annotation │
              │  │            │            │            │            │
```

Rules I found:

1. **Persona name + 1-line scar on the left, in a colored fill box (140w).** Don't redraw the name on every cell.
2. **Annotation cells use the persona's color in the stroke, not the fill.** Background stays light (light-yellow/orange/blue/etc.) so the text is readable. Only the **load-bearing** cells get a saturated colored fill — those are the moments where the persona drives a design decision.
3. **Mark 3 load-bearing cells with `strokeWidth: 3` and a ★ prefix** so the eye lands on them first when scanning a row.
4. **Six annotation columns is the practical ceiling.** Going to 8+ makes each cell too narrow to be readable; either merge personas or merge screens.

---

## Batching strategy (MCP performance)

The MCP tools accept one element per call, so a 146-element scene means 146 round-trips. Mitigation:

1. **Batch parallel `create_element` calls per turn.** The agent harness accepts multiple tool calls in one response; group them. I averaged ~10–15 elements per turn rather than one element per turn. **For a Squad-coordinator workflow this is critical** — solo per-call would be intolerable.

2. **Stage the diagram in conceptual chunks.** I batched in 4 chunks:
   - Chunk A: title block + legend.
   - Chunk B: LANE 1 onboarding (6 screens + 5 arrows + arrow labels = ~30 elements).
   - Chunk C: LANE 2 main screen (1 container + 7 sub-regions + their text = ~25 elements).
   - Chunk D: LANE 3 callouts (8 boxes + 8 arrows + their text = ~30 elements).
   - Chunk E: LANE 4 persona swimlanes (5 personas × 7 cells = ~35 elements).
   - Final verification + export.

3. **`excalidraw-get_resource(resource: "scene")` returns only the viewport/theme**, not the elements. To export the scene, query `elements` (or build the Excalidraw JSON wrapper around the `query_elements` result yourself):
   ```python
   {
     "type": "excalidraw",
     "version": 2,
     "source": "...",
     "elements": <query_elements result>,
     "appState": {"gridSize": null, "viewBackgroundColor": "#ffffff"},
     "files": {}
   }
   ```
   That JSON can be saved as `.excalidraw` and re-imported into excalidraw.com — making the scene portable beyond the MCP session.

---

## "Don't reify what you don't have" — a design honesty rule

When the input directive specifies a screen or surface that the design has **deliberately omitted** (here: "photosensitization attestation"), do NOT draw a box for it just because the directive names it.

Instead:
1. Draw the **functional equivalent** as it actually exists in the design (here: the three-surface visibility pattern — L1 inline link + L3 verdict-card link + L4 About anchor).
2. Use a **visually distinct fill** (I used yellow / passive-moment, not the standard screen blue) to mark "this is a moment, not a screen."
3. **Annotate why the screen does not exist** — in this case, "❌ NO toggle (zero special-category data, Raphael Art.9 / Casey M7)." Future readers (Kwame implementing the screen, an auditor reviewing the spec) will see both the absence AND the rationale at the same glance.

The user directive language is suggestive, not normative. The design is the source of truth for what the diagram should show.

---

## Applicability — when to use this skill

All five should be true:

- [ ] **1. You need a flow diagram, not a UI mockup.** This skill optimizes for clarity over polish.
- [ ] **2. There are ≥ 2 swimlanes of orthogonal information** (e.g., flow + persona, flow + state, flow + responsibility). For single-axis flows a plain left-to-right sequence is fine without lanes.
- [ ] **3. There are branch points the diagram must visually call out.** If the flow is purely linear, you don't need LANE 3.
- [ ] **4. Multiple agents / stakeholders will read the diagram independently.** Solo readers can tolerate a denser layout; multi-stakeholder readers benefit from explicit color-coding + a legend.
- [ ] **5. The MCP `excalidraw-*` tool set is available** (or you're documenting the pattern for someone who has it).

If only 3-4 are true, you can still use parts of the skill (the schema gotchas + the layout algorithm) but skip the persona-swimlane and branch-callout patterns.

---

## Anti-patterns to avoid

- **Drawing arrows before screens.** Arrows pinned to (x, y) won't follow if you move the rectangles after.
- **Trying to nest one rectangle "inside" another.** Excalidraw rectangles don't parent/child; nesting is purely visual. You move the parent, the children stay put. Use `excalidraw-group_elements` if you need them to move together — though I didn't need it for this diagram because I committed to positions early.
- **Reading `query_elements` output fully into context.** 30–50 KB of JSON for a 100+ element scene. Pipe through Python/jq for summary stats.
- **Over-explaining in the text labels.** Excalidraw text doesn't word-wrap inside a box width. Long sentences run off; multi-line lists with `\n` are easier to scan.
- **Color without a legend.** A 7-color diagram is unreadable without a parked legend block in a corner. Always include a legend if you use ≥ 4 fill colors.

---

## Worked example (this engagement, 2026-05-19)

| Phase | Element count | Time-ish |
|---|---|---|
| Read inputs (Linka spec, Suchi brief, Wheeler/Plunder archives) | — | ~3 turns of reads |
| Draw title + legend | 5 | 1 turn |
| LANE 1 onboarding (6 screens + arrows + labels) | 36 | 2 turns |
| LANE 2 main screen (container + 7 sub-regions) | 31 | 2 turns |
| LANE 3 callouts (8 yellow boxes + 8 arrows) | 28 | 2 turns |
| LANE 4 persona overlays (5 lanes × 7 cells + bold cells) | 41 | 2 turns |
| Query + export + snapshot file | — | 1 turn |
| **Total elements** | **146** | **~13 turns** |

Final spatial extent: 1720 × 2480 logical px. Imports cleanly into excalidraw.com from the `.excalidraw` JSON export.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
