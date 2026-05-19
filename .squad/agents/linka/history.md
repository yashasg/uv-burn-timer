# Linka — History

## Core Context

- **Project:** A UV exposure and sunburn timer app
- **Role:** UI/UX Designer (Apple HIG & Accessibility)
- **Joined:** 2026-05-19T06:26:01.546Z
- **Archive:** See `history-archive.md` for session 2026-05-19 iOS spec + Excalidraw diagram work (detailed learnings 1–20, archived to keep working history <15KB).

## Learnings (Session 2026-05-19 patch — Excalidraw export normalisation)

### 21. MCP `query_elements` returns a minimal element shape — must normalise before export

**Symptom:** `user-flow-onboarding-main.excalidraw` exported from MCP would not import into excalidraw.com — generic `Error: invalid file`.

**Root cause:** The Excalidraw MCP server's `query_elements` only surfaces `id, type, x, y, text, fontSize, strokeColor, width, height, strokeWidth, createdAt, updatedAt, version`. The excalidraw.com loader's strict path is `loadFromBlob → restoreElements → reduce(isInvisiblySmallElement(raw)) → restoreElement`. The pre-restore `isInvisiblySmallElement` calls `e.points.length` on arrows — and our arrows had no `points` → `TypeError` → outer catch rewrites to "invalid file." A second cascading failure waits behind `fontFamily`/`lineHeight`/`height` missing on text.

**Fix:** Wrote `.squad/files/excalidraw-normalize.py` to fill every required field per the canonical `ExcalidrawElement` schema (types.ts) + restore defaults (restore.ts). Visual layout untouched. Verified by running real `loadFromBlob` from `@excalidraw/excalidraw@0.18.1` in Node + jsdom + esbuild harness — file restores cleanly, all 146 elements, same type distribution (35 rect / 99 text / 12 arrows).

**Skill captured:** `.squad/skills/excalidraw-flow-diagrams-via-mcp/SKILL.md` got a new "Export gotcha" section with the full defaults table inline. The single load-bearing field is `points: [[0,0],[width,height]]` on arrows — without it, every excalidraw.com import fails.

**Process change:** All future Excalidraw MCP exports must pass through `excalidraw-normalize.py` before commit. Decision recorded at `.squad/decisions/inbox/linka-excalidraw-export-fix.md`.

## Learnings (Session 2026-05-19 Summary)

### Design Principles Locked for iOS v1

1. **iOS app is single-job app.** NavigationStack root (not TabView). Primary surface: NowView verdict card. One-off surfaces (Settings, About, Privacy) via .sheet. Hard gate: L1 .fullScreenCover disclaimer on cold launch.

2. **Layered disclaimer pattern is load-bearing:** L1 (cold-launch gate) + L2 (footer on verdict screens) + L3 (verdict-card "Is this estimate for me?" deep-link) + L4 (About source-of-truth). All four necessary; none sufficient alone. Serves low-risk personas (banner-blindness prevention) + high-risk Accutane/lupus personas (mid-task re-surface).

3. **No-default Fitzpatrick picker** forces user choice. Eliminates "I never saw the picker" mode. Critical for both Devon (low Fitz, high burn risk if anchored to III) and for privacy constraint (Fitz stays @State only, never @AppStorage per GDPR Art.9).

4. **Accessibility: AAA (≥7:1) for safety-critical signals.** Hero burn-time + tier badge use multiple channels: color + SF Symbol + shape + text + position. System Auto-Brightness + True Tone owns outdoor luminance; app's job is making the default outdoor-tolerant.

5. **WeatherKit attribution mandatory, always-visible.** Apple legal requirement. Will fail App Store review if missing. Apple Weather lockup on Home + About.

### Excalidraw Diagram Captured (D-2026-05-19-013)

- **4 lanes:** onboarding flow · main screen · branch-point callouts (8 yellow safety notes) · Suchi persona overlays (5 personas × 6 flow positions)
- **146 elements:** 35 rectangles, 99 text labels, 12 arrows. Exported to `user-flow-onboarding-main.excalidraw` at **repo root** (61.7 KB portable JSON). *(Originally written to `.squad/files/`; moved to repo root per user directive 2026-05-19T08:34Z — `.excalidraw` deliverables live at root for top-level visibility.)*
- **Key design truth:** Photosensitization is a **loop off L1** (visibility, not attestation). No hard screen. Drawn as passive-moment box.
- **Visualizes:** D-2026-05-19-002 through -012 (all active decisions).

### Skills Extracted (3 new files)

- `.squad/skills/persona-keyed-disclaimer-visibility/SKILL.md` — L1+L2+L3+L4 pattern with load-bearing reasoning.
- `.squad/skills/outdoor-readability-ios/SKILL.md` — AAA contrast + multi-channel severity encoding for outdoor safety.
- `.squad/skills/excalidraw-flow-diagrams-via-mcp/SKILL.md` — MCP drawing patterns, swimlane layout, batch strategy for drawing 100+ element diagrams via agent.

### High-Uncertainty Items at Kwame Handoff

1. Photosensitizer disclosure wording on verdict card (Wheeler D-2026-05-19-007 still pending ratification).
2. L3 link exact wording (Linka + Suchi pick "Is this estimate for me?").
3. Long-tier 240-minute display cap (Wheeler must confirm math defensibility at extreme, not just UX-driven).

### Process Learning — Parallel with Suchi

**What worked:** Write canonical flow independently (spec + decisions), then poll for persona overlays mid-task. Avoid entangling personas into the canonical lane. Layer overlays as separate LANE 4 so either producer can adapt independently.

**Suchi's key correction:** Photosensitization is "visibility, not attestation." L1 modal has inline deep-link; no separate screen needed. Phrasing "don't reify an architecture we deliberately don't have" became team design-honesty rule.

