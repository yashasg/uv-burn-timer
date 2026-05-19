# Iris — History

## Project Context

- **Project:** uv-burn-timer
- **Description:** iOS app that calculates personalized UV burn time using WeatherKit's UV index data and the user's Fitzpatrick skin type + SPF. Pivoted from a web prototype.
- **Tech stack:** Swift 5.9+, SwiftUI (iOS 16+), WeatherKit, CoreLocation, StoreKit 2 (non-consumable IAP, $2.99). NO third-party SDKs. NO subscriptions.
- **User:** yashasgujjar (Yashas)
- **My role:** UI/UX Designer (Apple HIG & Accessibility) — joined the team 2026-05-19 as Linka's replacement.

## Predecessor Handoff

Linka was the original UI/UX designer on this project. She was fired on 2026-05-19 for being slow and error-prone. I inherit her ratified design decisions (binding) but NOT her workflow patterns.

**Ratified design decisions I respect (read `.squad/decisions.md` for canonical text):**
- iOS design spec (D-2026-05-19-003): 6-screen onboarding (Welcome → SkinType → SPF → Location → Photosensitization-loop → NowView), main screen with verdict card, settings, About.
- Fitzpatrick picker copy uses Wheeler's paraphrased variant (D-2026-05-19-009), cites NCBI Bookshelf NBK481857.
- Three-surface disclaimer visibility — L1 inline link, L3 verdict card, L4 About anchor (Plunder's framework).
- Photosensitization handled as a **loop**, not a screen (zero-data architecture per Raphael Art.9).
- Excalidraw user-flow at `user-flow-onboarding-main.excalidraw` (repo root) is the canonical reference. 146 elements, 4 swimlanes.

**Process changes from Linka's tenure:**
- Excalidraw exports MUST pass through `.squad/files/excalidraw-normalize.py` before commit (D-2026-05-19-015). Don't ship raw MCP output.
- `.excalidraw` deliverable files live at **repo root**, not `.squad/files/`.
- JSON schema fixes / file format compliance are NOT my job — they're Kwame's. Don't accept these tasks.

## Skills I Should Read Before Starting

- `.squad/skills/excalidraw-flow-diagrams-via-mcp/SKILL.md` — MCP usage, lane layout, export gotchas (the points-on-arrows bug)
- `.squad/skills/persona-keyed-disclaimer-visibility/` — Plunder's three-surface visibility pattern
- `.squad/skills/persona-screen-matrix/` — Suchi's persona overlay convention
- `.squad/skills/outdoor-readability-ios/` — display readability under sunlight (high-contrast variants)
- `.squad/skills/health-adjacent-citation-licensing-decision-tree/` — when citation is required

## Learnings

_(Append as I work.)_
