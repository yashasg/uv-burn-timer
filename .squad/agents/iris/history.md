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
- Excalidraw user-flow at `user-flow-onboarding-main.excalidraw` (repo root) is the canonical reference. 142 elements, 4 swimlanes.

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

- **2026-05-19** — Redrew the canonical LANE 2 main screen as a centered 360×780 portrait iPhone frame inside the existing swimlane band; preserved LANE 1 and LANE 4, and only re-anchored the affected LANE 3 arrows.
- **2026-05-19** — The reliable iOS flow-diagram pattern here is: status bar → Large Title nav → optional safety banner → hero verdict card → UV attribution card → 44pt settings chips → inline disclaimer link → home indicator, with HIC/AX notes outside the phone rather than inside it.
- **2026-05-19** — Excalidraw MCP canvas first, export second: redraw live, wrap the queried elements in the `.excalidraw` JSON envelope, then run `.squad/files/excalidraw-normalize.py` before validation and commit.
- **2026-05-19T19:38:59Z (Cross-agent)** — Xcode project container path is now `app/app.xcodeproj` (D-2026-05-19-015). App/product/scheme names remain `UVBurnTimer`. See `.squad/decisions.md` for details.
- **2026-05-19 (Redesign audit, squad/4)** — By the time I audited, the implementation was further along than expected: skin type chip already removed from main, `SkinTypePickerRow` already a shared component, `SettingsSheet` already uses `NavigationLink` → `SkinTypeEditView`. Always read the full current file before writing blockers. The only structural gap left is the circular gauge.
- **2026-05-19 (Redesign audit, squad/4)** — `skinTypePickerPrompt` is used as a section header *headline* with `skinTypePickerSubtext` providing the detailed explanation below it. The prompt should be a short action-oriented headline ("Choose by how your skin burns and tans, not by how it looks."); the subtext carries the range-of-tones and sun-exposure framing.
- **2026-05-19 (Redesign audit, squad/4)** — When `SkinTypeOnboardingView` applies `.accessibilityHint(...)` directly on a `SkinTypePickerRow`, it overrides the row's built-in hint — this is the correct pattern for context-specific hints (onboarding vs. settings). The `SkinTypePickerRow` base hint is the settings default; onboarding overrides it to say "Tap Continue to confirm."
- **2026-05-19 (Redesign audit, squad/4)** — The `SkinTypePickerRow` already has `accessibilityLabel("Type N. [behavior+appearance]. Selected/Not selected.")` — explicit label pattern suppressing the redundant leading roman-numeral Text child. This is the canonical row label pattern for all Fitzpatrick pickers.
- **2026-05-19T20:34:41.561-07:00 (Gauge visibility audit)** — The circular burn-risk gauge now exists in `RootView`, but only after a valid estimate with `fetchedAt`, non-`.none` tier, and finite raw minutes. On iPhone Pro-class heights it can sit below the first viewport because the main stack renders the photosensitization banner and optional location-rationale card before the hero; at large Dynamic Type the gauge is even easier to miss unless placed inside/visually attached to the hero card.

- **2026-05-19T22:27:48-07:00 (Circular gauge audit)** — The repo contains the canonical Excalidraw flow (`user-flow-onboarding-main.excalidraw`) and old browser prototype, but neither contains a large user-shared circular ring mockup. Current SwiftUI implements a small `.accessoryCircularCapacity` gauge inside a secondary `Burn window` card under the hero; to match the user's mental image, the design target should be a large, hero-attached circular burn-window ring, not a tiny accessory gauge.
- **2026-05-19T22:27:48-07:00 (Location chip UX audit)** — A main-surface chip labeled `Location` but routing directly to the general Settings sheet is a discoverability/name mismatch even if technically intentional; either the label/hint must say it opens Settings/Location settings, or the route must open a location-specific management surface.

### 2026-05-20T00:01:47Z: Team Decision

**Scribe Log Entry**

Team approvals and implementations completed for approved redesign and paraphrasing initiatives:
- Wheeler: Paraphrase traceability review (conditional accept, fixes noted)
- Ma-Ti: Redesign tests passing + gauge guard tests verified
- Iris: HIG/accessibility audit passed
- Kwame: Implementation and circular gauge both passing

All inbox decisions merged into decisions.md.

