# Linka — History Archive

## Session 2026-05-19 — iOS design spec + Excalidraw flow diagram (Summary)

**Scope:** Complete iOS HIG-compliant design spec from cold launch through onboarding to main screen. Then drew comprehensive Excalidraw user-flow diagram (4 lanes, 146 elements) with Suchi persona overlays.

**Core design decisions:**
- Single-root NavigationStack (not TabView). .fullScreenCover for L1 disclaimer, .sheet for Settings/About/Privacy.
- WeatherKit attribution mandatory, always-visible per Apple legal.
- No-default Fitzpatrick picker (forces user choice; eliminates "I never saw the picker" failure mode).
- Layered disclaimer pattern: L1 (cold-launch .fullScreenCover) + L2 (persistent inert footer) + L3 (verdict-card "Is this estimate for me?" deep-link) + L4 (About long-form source-of-truth).
- Accessibility: AAA contrast (≥7:1) for safety-critical signals. Severity encoding uses ≥2 independent channels (color + symbol + shape + text + position).
- Fitz V/VI descriptions lead with behavior, not color ("Rarely burns" beats "Dark brown to black").
- Long tier display cap at 240+ minutes (prevents false-precision at extreme).

**Why the layered disclaimer works:**
L1 alone fails (modal-blindness on cold launch). L2 alone trains banner-blindness. L3 alone misses first-launch risk. All four together: L1 + L2 reach baseline awareness; L3 serves high-risk Accutane/lupus persona mid-task; L4 is source-of-truth. Load-bearing for Asha (Accutane) and Maya (swimmer) personas.

**Privacy constraint:**
Fitzpatrick stays @State only, never @AppStorage (GDPR Art.9 special-category-adjacent data). Consequence: cold launch requires Fitz re-entry every time. **Why no-default selection is critical:** defaulting Fitz III would be both wrong-for-user and a UX-tax bandage on the privacy constraint.

**Uncertainty at handoff:**
1. Photosensitizer disclosure on verdict card — Wheeler must ratify (D-2026-05-19-007).
2. L3 link wording — Three variants; Linka + Suchi pick "Is this estimate for me?"
3. Long-tier 240+ display cap — Wheeler must confirm math defensibility at extreme.

**Skills extracted:**
- `.squad/skills/persona-keyed-disclaimer-visibility/SKILL.md` — The L1+L2+L3+L4 layered pattern.
- `.squad/skills/outdoor-readability-ios/SKILL.md` — AAA contrast + multi-channel severity encoding.
- `.squad/skills/excalidraw-flow-diagrams-via-mcp/SKILL.md` — MCP drawing patterns, swimlane layout, batch strategy.

**Excalidraw diagram (D-2026-05-19-013):**
146 elements, 4 lanes: (1) onboarding flow 6 screens left-to-right, (2) main screen 7 sub-regions, (3) branch-point callouts + 8 yellow annotations, (4) Suchi persona overlays (5 personas × 6 columns). Deliberately omits photosensitization hard screen — drawn as passive-moment with L1 loop (zero-data architecture). Visualizes all key decisions. Exported to `.squad/files/user-flow-onboarding-main.excalidraw` (61.7 KB portable JSON).

**MCP gotchas discovered:**
- Arrows are (x, y, width, height) where width/height are **deltas**, not corners.
- Text ignores width/height; bounding box scales to string.
- Multi-line text via \n is cheap; bullet lists work.
- `query_elements()` blows context on 100+ element scenes (45 KB JSON) — pipe through python/jq.
- Always export scene manually (Python one-liner) so it's portable.

**Process learning — parallel with Suchi:**
1. Wrote full spec first (primary sources: decisions, prototype, persona histories).
2. Checked Suchi's inbox at end-of-work (brief landed).
3. Integrated inline (not as separate "Suchi sync" section) — keeps spec readable as one document.
4. Drew LANES 1–3 independently, polled for LANE 4 annotations mid-flight, integrated cleanly.
5. Documented integration choices in decision file for transparency.

**Pattern to reuse:** Canonical flow first (canonical authority), then layer persona-keyed annotations as separate lane. Avoids entanglement; enables independent producer feedback mid-task.

**Suchi's photosensitization architecture correction:**
Flagged that "photosensitization attestation" is **NOT a separate screen** — it's a **loop off L1** (visibility, not attestation per Donatello M7 zero-data). L1 modal contains inline deep-link to AboutView → return to L1. Now canonical in D-2026-05-19-013. Correcting this phrasing early ("don't reify an architecture we deliberately don't have") became a generalized design honesty rule for the team.

---

**File paths (spec + diagram):**
- `.squad/decisions/inbox/linka-ios-design-spec.md` — primary design spec
- `.squad/files/user-flow-onboarding-main.excalidraw` — portable Excalidraw scene
- `.squad/files/user-flow-onboarding-main-spec.md` — textual snapshot
- `.squad/files/suchi-persona-annotations.md` — persona overlay spec

**Status:** v1 design spec locked. Excalidraw diagram is source-of-truth for implementation. Ready for Kwame (iOS developer) handoff.
