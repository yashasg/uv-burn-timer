# User-Flow Diagram — Onboarding + Main Screen (Excalidraw Snapshot Spec)

**Author:** Iris (UI/UX, Apple HIG & Accessibility; revising Linka's canonical scene)
**Date:** 2026-05-19
**Companion Excalidraw scene:** `user-flow-onboarding-main.excalidraw` (repo root — 142 elements, 4 swimlanes, ~2240 × 2591 logical px)
**Source of truth:** `.squad/decisions/archive/linka-ios-design-spec.md`
**Persona overlays:** `.squad/files/suchi-persona-annotations.md` (incorporated as LANE 4)

This document is the textual record of what is on the live Excalidraw canvas. If the canvas and this file disagree, **the canvas is the deliverable** but this file should be updated to match. The `.excalidraw` JSON file is the portable export.

---

## Canvas layout (4 swimlanes, top-to-bottom)

```
y = 20    Title block + source/decisions citation
y = 110   ┌─ LANE 1 — ONBOARDING (cold launch → first verdict) ─┐
y = 180   │   6 screen rectangles, left-to-right                │
y = 460   └──────────────────────────────────────────────────────┘
y = 540   ┌─ LANE 2 — MAIN SCREEN (NowView) ────────────────────┐
y = 600   │   one portrait iPhone frame + HIG annotation block  │
y = 1420  └──────────────────────────────────────────────────────┘
y = 1480  ┌─ LANE 3 — BRANCH POINTS / ANNOTATIONS (callouts) ───┐
y = 1540  │   8 yellow callouts arranged in 2 rows              │
y = 1970  └──────────────────────────────────────────────────────┘
y = 2010  ┌─ LANE 4 — PERSONA OVERLAYS (Suchi, 5 swimlanes) ────┐
y = 2090  │   one row per persona × 6 columns of annotations    │
y = 2580  └──────────────────────────────────────────────────────┘
```

Legend box is parked top-right at (1660, 110).

---

## LANE 1 — Onboarding screens

Six rectangles, each ~240w × 280h. Left edge at x=60, 380, 700, 1020, 1340, 1660 (steps of 320). All connected by blue right-pointing arrows at y≈320.

| # | Screen | Fill | Border | Purpose | Key copy |
|---|---|---|---|---|---|
| 1 | Cold Launch | light gray | gray | Splash → gated by L1 | "No Fitz persisted — @State only" |
| 2 | **L1 Disclaimer** (`.fullScreenCover`) | red | red bold | Mandatory acknowledgment | "How accurate is this for you?" + inline *see About* + photosensitizer line + "I understand" |
| 3 | Skin-Type Picker | light blue | blue | Fitzpatrick I–VI | Header: *"Pick the row that matches what your skin does, not its color"*. **NO default** (D-...-012). Wheeler edited variant. |
| 4 | Location Permission | light blue | blue | Grant "When in Use"; SPF picker also shown | Privacy rationale BEFORE iOS prompt; CTA in `.safeAreaInset(.bottom)` |
| 5 | **Photo-Sens Awareness** | yellow (passive moment) | orange | NOT a separate screen — three surfaces (a) inside L1, (b) L3 link, (c) L4 About anchor | No "I'm photosensitive" toggle (zero-data architecture) |
| 6 | First Verdict → Main | light green | dark green | Hand-off into NowView | Animates `.contentTransition(.numericText)`; success haptic |

Arrow labels: "tap I understand" → "deliberate Fitz tap" → "grant location" → *passive moment* (orange) → "UV fetch ok".

The orange arrow between screen 4 and 5 marks that screen 5 is conceptual (a moment, not a hard screen), per Suchi: "**Don't reify an architecture we deliberately don't have.**"

---

## LANE 2 — Main Screen (NowView)

The desktop-shaped 7-region grid is gone. LANE 2 now centers one portrait phone frame (360×780 logical units, at x=540, y=600) with a small HIG / accessibility annotation block to its right.

1. **Status bar** — `9:41` on the left, `signal · wifi · battery` on the right. Annotated only; not pixel-perfect.
2. **Large Title nav bar** — left-aligned `UV Burn Timer` + trailing ⚙︎ gear (SettingsSheet entry point).
3. **Photosensitization loop banner** (yellow, 320×40) — `Taking photosensitizing meds? →`; this is the L1 reach-back surface when the loop is active, not a separate screen.
4. **Hero verdict card** (amber, 320×224) — label `Burn time`, hero `47 min`, verdict `Moderate`, and inline caveat `Meds + conditions can shorten this. Learn more →`. The caveat preserves the `notForMe` deep-link pattern without reintroducing a desktop sub-panel.
5. **UV Index secondary card** (neutral, 320×96) — `UV Index 6.2` + `Source: Apple Weather`. This attribution stays visible in the portrait viewport.
6. **Location + SPF row** — compact 44pt controls for `📍 San Francisco ›` and `SPF 30`. Location refreshes the UV lookup; SPF stays directly adjustable on the main screen. Fitzpatrick selection is intentionally kept in onboarding and Settings, not on the repeated-use main surface.
7. **L1 disclaimer link** — inline bottom-of-content link: `Informational only. Not medical advice. →`.
8. **Home indicator** — thin bottom pill for safe-area completeness.
9. **HIG note block (beside the frame)** — calls out: Large Title nav bar, safe-area top/bottom, ≥44×44pt targets, SF Symbols, semantic system colors, Dynamic Type AX5 reflow, and VoiceOver combined-card reading.

A green arrow from screen 6 (LANE 1) now lands diagonally into the portrait frame near the nav bar to show the first-verdict handoff.

---

## LANE 3 — Branch points / annotations

8 yellow callout rectangles (380×200, bright orange border, light-yellow fill), arranged in 2 rows of 4.

**Row 1 (y=1540):**
1. 🚨 **No-default Fitzpatrick** (D-2026-05-19-012) — arrow up to skin-type picker.
2. 🚨 **L1 sticky + photo-sens reach-back** — arrow up to the yellow NowView banner.
3. 📌 **Compact duration display cap** — arrow up to the portrait hero number. Sub-hour estimates render as `~45 min`; hour-plus estimates render as `~1 hr`, `~1 hr 20 min`, `~2 hr 47 min`; sunscreen-protected windows cap at `Up to 2 hr`; unprotected windows ≥ 240 min cap at `4+ hr`. (Format ratified by Kwame 2026-05-19T22:50:27 and Ma-Ti's duration-format test contract; supersedes the earlier `240+ min` shorthand.)
4. 📌 **WeatherKit attribution always visible** (D-2026-05-19-002/003/004 launch-blocker) — arrow up to the UV secondary card's source line.

**Row 2 (y=1770):**
5. 📌 **Verdict-card learn-more deep-link** — arrow up to the hero-card caveat line.
6. ⚖️ **Plunder's 8 attorney pre-submit flags** (non-blocking) — listed inline; no arrow (multi-surface).
7. 🔁 **Re-attestation on window-elapsed** — arrow up to the hero card (swaps in place).
8. 📌 **Accessibility conformance gate** (AX5, VoiceOver, Reduce Motion, Increase Contrast, polarized OLED test) — no arrow (cross-cutting).

---

## LANE 4 — Persona overlays (Suchi)

5 persona swimlanes, one row each, ~90px tall. Persona-name box on left (140w, colored fill per Suchi's palette). Six annotation cells across the row align horizontally with onboarding screens above.

| Row | Persona | Color | Load-bearing annotation (★ = bold-bordered) |
|---|---|---|---|
| 1 | **P1 Greta** (gram-counter, Fitz II/III) | green #2E7D32 | ★ L2 footer is her primary reading on repeating use |
| 2 | **P2 Maya** (open-water swim, Fitz III) | blue #1565C0 | ★ Pull-to-refresh is her primary affordance; cannot see window-elapsed in water |
| 3 | **P3 Devon** (PCT thru-hike, Fitz I) | red #C62828 | ★ **THE NO-DEFAULT VALIDATOR** — bold-bordered cell on Fitz picker column |
| 4 | **P4 Asha** (Accutane, Fitz IV) | purple #6A1B9A | ★ **LOAD-BEARING** visibility loop on L1; ★ **MOST IMPORTANT L3 TAP** on verdict; ★ L1 re-fires = re-attestation |
| 5 | **P5 Tomás** (trail runner, Fitz IV/V) | orange #EF6C00 | ★ Under-pick risk on Fitz V row; ★ **HIS SAFETY MOMENT** — window-elapsed |

Three load-bearing safety annotations have bold (strokeWidth 3) borders: Devon's no-default star, Asha's L1 + L3 cells, Tomás's window-elapsed.

---

## Element inventory

| Type | Count |
|---|---|
| rectangle | 33 |
| text | 97 |
| arrow | 12 |
| **TOTAL** | **142** |

Spatial extent: x ∈ [60, 2240], y ∈ [20, 2591].

---

## Reading order (recommended viewer flow)

1. Read the title + source line.
2. LANE 1 left → right (cold launch → first verdict).
3. Drop into LANE 2 and read the portrait phone frame top → bottom (status bar, nav, banner, hero card, UV card, chips, disclaimer link, home indicator), then glance at the HIG note block.
4. Glance down at LANE 3 callouts; follow each arrow up to its referenced surface.
5. LANE 4 row-by-row to layer persona context onto the canonical flow.
6. The legend (top-right) covers color conventions.

---

## What's deliberately NOT on the canvas

Per Suchi's note "**Don't reify an architecture we deliberately don't have**":
- **No "Photosensitization Attestation" hard screen.** Drawn as a yellow passive-moment box (LANE 1, screen 5) plus a yellow reach-back banner in LANE 2. There is no toggle, no medical-question-answer, no special-category-data form. Per Donatello M7 + Raphael Art.9 + D-2026-05-19-007/011.
- **No Live Activity / Dynamic Island surfaces.** Deferred to v1.1 (spec §3.7).
- **No reapplication-timer UI.** The portrait redraw still omits a second timer; v1 stays focused on burn-time verdict + explanatory links.
- **No "Outdoor Mode" toggle.** System auto-brightness + True Tone owns luminance; HC asset variants via Asset Catalog handle contrast.
- **No watchOS / Live Activity / push-notification surfaces.** Out of v1 scope.

---

## Decisions referenced on-canvas

- **D-2026-05-19-002** iOS pivot from web prototype.
- **D-2026-05-19-003** WeatherKit is the iOS UV source.
- **D-2026-05-19-004** Remove Open-Meteo attribution from iOS surfaces.
- **D-2026-05-19-007** Photosensitivity is a safety boundary, not edge copy.
- **D-2026-05-19-009 ✅** Wheeler edited variant for picker copy (paraphrase, do not reproduce NCBI verbatim).
- **D-2026-05-19-011** Three-surface L1–L4 layered disclaimer pattern.
- **D-2026-05-19-012** No-default Fitzpatrick selection.

---

## Companion skills

- `.squad/skills/persona-keyed-disclaimer-visibility/SKILL.md` — the L1/L2/L3/L4 pattern.
- `.squad/skills/outdoor-readability-ios/SKILL.md` — AAA contrast, redundant severity encoding.
- `.squad/skills/excalidraw-flow-diagrams-via-mcp/SKILL.md` — *(new)* how to draw multi-lane flow diagrams via MCP. **See its "Export gotcha" section** before re-exporting from MCP — `query_elements` returns a minimal element shape and the raw JSON will not import into excalidraw.com without schema normalisation.

---

## Export history

- **2026-05-19T08:19Z** — Initial export from live MCP canvas (61.7 KB, 146 elements). **Did not import into excalidraw.com** ("Error: invalid file"): MCP's `query_elements` returns only `id, type, x, y, text, fontSize, strokeColor, width, height, strokeWidth, createdAt, updatedAt, version` per element — missing the bulk of the `ExcalidrawElement` schema (most critically, arrows lacked `points`, which causes `isInvisiblySmallElement` to throw inside `restoreElements` before defaults are filled in).
- **2026-05-19T01:49-07:00** — Re-saved at ~162 KB after normalising every element to the full schema (`seed`, `versionNonce`, `groupIds`, `frameId`, `boundElements`, `isDeleted`, `roundness`, `index`, `roughness`, `opacity`, `angle`, `fillStyle`, `strokeStyle`, `link`, `locked`, `updated`; text adds `fontFamily`, `textAlign`, `verticalAlign`, `containerId`, `originalText`, `lineHeight`, `autoResize`; arrows add `points`, `startBinding`, `endBinding`, `startArrowhead`, `endArrowhead`, `elbowed`, `lastCommittedPoint`). Visual layout, positions, sizes, colors, and text are unchanged — schema-only fix. Verified by running the file through Excalidraw 0.18.1's actual `loadFromBlob` in Node + jsdom (146 elements restored, type counts preserved at 35 rectangles / 99 text / 12 arrows). The previous file is kept on disk as `user-flow-onboarding-main.excalidraw.bak` for one cycle.
- **2026-05-19** — Iris replaced LANE 2's desktop-style 7-region grid with a portrait iPhone frame, stacked cards, and a right-side HIG note block. Relevant LANE 3 arrows were re-anchored to the banner, hero card, UV card, and inline learn-more caveat; the exported scene now has 142 elements (33 rectangles / 97 text / 12 arrows).

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
