# Kwame — History

## SUMMARY (Latest Round — 2026-05-21)

**WI-7 storage mechanism fully locked.** All three blocked design questions resolved: staleness signal = Apple's `Weather.metadata.expirationDate` (not hardcoded 6h); coord eviction = 50 km radius (not 10 km); data shape = always `dayCount × 24` hours (regularized, no variable counts). Storage: Option B (single-file JSON at `Caches/forecast-snapshot.json`), actor-based ForecastStore, no schema migration (version mismatch → discard + re-fetch). Picker D+7 hard cap confirmed. Loading-state UX contract finalized by Iris (skeleton rows, shimmer, disabled chips, error block). Offline behavior: stale snapshot + disclosure banner. All five prior WI-7 decisions confirmed. No blockers. Ready for SwiftUI implementation. Iris review gate on surfaces; Wheeler review on health-adjacent numbers; Ma-Ti test plan locked.

---


**Current role:** iOS developer (SwiftUI); owns implementation of burn-time picker, forecast surfaces, visual treatment, and edge-case handling.

**Recent major decisions & incoming work:**
1. **UVI forecast surface (WI-7):** 10-day card locked pending implementation. Flat visual treatment (no per-row opacity/decay). Integer UVI D1–5 only; WHO category band D6–10. Card-level `.caption .secondary` footnote. Daily refresh from WeatherKit; attribution adjacent to card.
2. **User-initiated date/time picker (2026-05-21, incoming):** "Plan for another time" chip on BurnTimeCard → `.sheet` with `DatePicker(.date, .hourAndMinute)` graphical. Range: `Date.now` to `Date.now + 7*24*3600` (D+7 hard cap, structural enforcement). Returns burn-time estimate at `.title2` scale in sheet.
3. **Picker edge cases (CRITICAL for ship):**
   - UVI 0 (night) → "No UV at this hour — no sun protection needed."
   - No skin type → Reuse D-2026-05-19-012 gate: "Set your skin type to see a planned burn window."
   - Forecast unavailable → "Forecast unavailable for this time" + retry button.
   - Day 8–10 (if clamped to D+10 fallback) → "Forecast accuracy beyond 7 days is limited..."
   - ReduceMotion → instant swap; normal → `.animation(.easeIn(duration: 0.15))`.
4. **L3 chevron + photosensitization disclosure:** New affordance at forecast card foot: "Is this estimate for me?" → About @ photosensitizer section. Picker sheet also carries photosensitization re-disclosure (D-2026-05-19-013 wording).
5. **WeatherKit attribution:** Present on forecast card and picker-sheet surfaces.

**Open delta awaiting user decision:**
- Picker range: D+7 (Wheeler, conservative) vs D+10 (Iris, data-bounded).

---

## Core Context

- **Project:** A UV exposure and sunburn timer app
- **Role:** Backend Dev
- **Joined:** 2026-05-19T06:26:01.546Z

## Learnings

<!-- Append learnings below -->

- 2026-05-21T01:52:54Z — **WeatherKit polar-latitude Sun API research (kwame-weatherkit-polar-api-research.md):**
  - **Critical type-name correction:** The WeatherKit type is `SunEvents`, NOT `Sun`. `DayWeather.sun` is `var sun: SunEvents` — a non-optional struct. The optional Date fields are properties inside it. Access path `dayWeather.sun.sunrise` is correct; the intermediate type name matters for Swift code. Correct this in any team doc referencing "Sun struct."
  - **`sunrise == nil` is AMBIGUOUS.** Apple documents and WWDC22 session 10035 confirm: `SunEvents.sunrise` is nil during BOTH polar night (sun never rises) AND polar day (sun never sets, so there is no rising event). Using `sunrise == nil` as a polar-night-only trigger would false-positive on polar-day dates with UVI 8–14.
  - **`solarNoon == nil` is the canonical polar-night signal.** Apple explicitly documents: "If the highest point isn't above the horizon, this property is `nil`." This fires ONLY during polar night, not polar day.
  - **`solarMidnight == nil` is the canonical polar-day signal.** Apple explicitly documents: "If the lowest point is not below the horizon, this property is `nil`." Fires ONLY during polar day.
  - **Disambiguation table:** Polar night → solarNoon nil, solarMidnight non-nil. Polar day → solarNoon non-nil, solarMidnight nil. Normal → both non-nil. Sunrise/sunset → nil in both polar cases.
  - **`HourWeather.uvIndex`:** Apple does not document polar behavior. Non-optional, always present. Physics inference + Wheeler's science memo support UVI=0 during polar night, but this is NOT Apple-documented. Recommend empirical verification via test plan.
  - **Locked trigger (per research):** `dayForecast.sun.solarNoon == nil` — single-signal, Apple-documented, unambiguous. Replaces Iris's dual-condition (`sunrise == nil` + all-zero UVI) and drops the 18-hour fallback.
  - **Citations:** `SunEvents.sunrise/sunset/solarNoon/solarMidnight` property docs at docs.developer.apple.com/documentation/WeatherKit/SunEvents/*; WWDC22 session 10035.
  - **New skill extracted:** `.squad/skills/weatherkit-optional-sun-fields-polar-latitudes/SKILL.md`

- 2026-05-19T12:15:11.894-07:00 — Renamed the Xcode project container path to `app/app.xcodeproj`; product/module/scheme naming remains `UVBurnTimer`, and build/test references target the new container path.
- 2026-05-19T16:30:05-07:00 — Implemented approved redesign (work item #4, branch squad/4-approved-redesign-paraphrasing):
  - Fitzpatrick selector is now a single shared `SkinTypePickerRow` component; used by both `SkinTypeOnboardingView` (first-run, draft+Continue) and `SkinTypeEditView` (Settings, draft+Save). No duplicated picker code.
  - `SettingsSheet` now has a NavigationLink → `SkinTypeEditView` replacing the inline 6-row picker section. The "Skin type" row shows current selection or "Not set".
  - Main screen `contextChipRow` now renders location chip only; Fitzpatrick chip removed per Iris/Gaia spec (Scope 2).
  - `ProductCopy` gained `skinTypePickerSubtext` (Wheeler §3.1 helper text) and `skinTypeSourcePointer` (Plunder §2.3 inline citation pointer); both added to `auditCopySurfaces`.
  - `AboutView` gained "Skin type classification" section with Fitzpatrick TB (1988) + Ward & Farma NCBI Bookshelf NBK481857 bibliographic strings.
  - Skin type persistence remains @State-only (transient; Gaia Guardrail 1 confirmed this is the v1 design).
  - All 16 UI tests pass. `testSkinTypePickerInSettingsReusesOnboardingPattern` required a scroll fix: medium-detent sheet clips rows IV–VI below the fold; `swipeUp()` loop added before `waitForExistence`.
- 2026-05-19T16:47:52-07:00 — Implemented `BurnRiskGaugeCard` (circular gauge) on main screen:
  - `Gauge` with `.accessoryCircularCapacity` style, placed between `HeroTimerCard` and `UVIndexCard`.
  - Data: `burnFraction = clamp(0, elapsed / min(rawMinutes*60, 2h), 1)` — same window as `isElapsed`.
  - Guard: only shown when `estimate != nil && tier != .none && rawMinutes.isFinite`; hidden otherwise so VoiceOver never announces a phantom "0%".
  - Accessibility: `accessibilityLabel("Burn risk gauge. N% elapsed.")`, `accessibilityValue("N%")`, `accessibilityIdentifier("BurnRiskGauge")`. Percentage text in `currentValueLabel` ensures color is never the sole differentiator.
  - Reduce Motion: no `.animation` on appear — static arc.
  - Differentiate Without Color: extra `Text(percentText)` rendered (VoiceOver-hidden).
  - Tint: `Gradient` from `tier.color.opacity(0.5)` to `tier.color` using existing `SeverityLong/Moderate/Short` assets.
  - 2 new UI tests (`testBurnRiskGaugeExistsAndIsMeaningful...`, `testBurnRiskGaugeAbsentWhenNoEstimate`); 3 additional tests already present from Ma-Ti. Build + test build: PASSED.


### 2026-05-20T00:01:47Z: Team Decision

**Scribe Log Entry**

Team approvals and implementations completed for approved redesign and paraphrasing initiatives:
- Wheeler: Paraphrase traceability review (conditional accept, fixes noted)
- Ma-Ti: Redesign tests passing + gauge guard tests verified
- Iris: HIG/accessibility audit passed
- Kwame: Implementation and circular gauge both passing

All inbox decisions merged into decisions.md.



### 2026-05-19T17:14Z: Commit, push, and CI validation

**Branch:** `squad/4-approved-redesign-paraphrasing`
**Commit:** `738da12`

**Files committed (9):**
- `.squad/files/user-flow-onboarding-main-spec.md` — attribution paraphrasing: "Apple WeatherKit" → "Apple Weather"
- `app/Sources/UVBurnTimer/UVBurnTimerApp.swift` — explicit `showSkinTypeOnboarding` @State flag; onAppear + onChange guards; Task @MainActor double-check; onDismiss wired through `disclaimerPresentation`
- `app/Sources/UVBurnTimer/WeatherLocationServices.swift` — suppress unused-param warnings on `locationManager(_:didFailWithError:)`
- `app/Tests/UVBurnTimerCoreTests/UVWorkflowTests.swift` — added `uncappedLongEstimateStillExpiresAtTwoHourRefreshInterval` test
- `build.sh` — prefer iPhone 17 Pro simulator; shared `derived_data_path`; capture-then-cat log pattern to preserve exit code separately from warning scan
- `prototype/LAUNCH-PLAN.md` — monetization language: "90-Day No-IAP" → "Paid Download / No In-App Monetization" paraphrasing throughout
- `user-flow-onboarding-main.excalidraw` + `.bak` + `.kwame-fix.excalidraw` — excalidraw attribution and compliance notes updated

**File skipped (1):**
- `excalidraw.log` — pure MCP server runtime log (timestamps + "Listing available tools" noise); no semantic content; should be gitignored

**Validation:** `./build.sh` — Debug build ✅, test suite ✅, Release build ✅ (all warnings-as-errors, iPhone 17 Pro simulator)

**Push:** `origin/squad/4-approved-redesign-paraphrasing` — new branch, pushed successfully

**GitLab CI:** No `.gitlab-ci.yml` in repo → no pipeline triggered. Two pre-existing failed pipelines on unrelated branches (`main`, `squad/fix-app-icon-catalog`). CI is not blocking.

**Learning:** `excalidraw.log` should be added to `.gitignore` — currently tracked but is pure runtime noise. Recommend team decision.


### 2026-05-20T01:26Z: External CI monitoring — MR !3 fixed and green

**Task:** Monitor GitLab MR !3 for external CI/CD feedback and fix failures.

**CI system:** GitHub Actions triggered via GitLab webhook → Cloudflare Worker → `repository_dispatch`.  
The CI workflow lives on `github/main` (not on the GitLab branch).

**Failures found and fixed (4 separate CI runs):**

1. **Run 26133538471 — `Set build metadata` failed (exit code 2)**
   - Root cause: CI workflow referenced `app/VCA.xcodeproj/project.pbxproj` which doesn't exist; project is `app/app.xcodeproj`
   - Also: `cd app && ./build.sh` — no `app/build.sh`, script is at repo root
   - Fix: Updated `github/main`'s `.github/workflows/ci.yml` (pushed to `github main`):
     - `app/VCA.xcodeproj` → `app/app.xcodeproj` (4 occurrences incl. cache hashFiles keys)
     - Removed `cd app &&`; `./build.sh` now runs from repo root
   - Also added CI env var support to `build.sh` (CONFIGURATION, DERIVED_DATA_PATH, RUN_TESTS, TEST_CONFIGURATION, PLATFORM_MODE)
   - Created `.swift-format` config (required by CI lint step)
   - Commits: `470f893` + `c5266e4` → pushed to `origin/squad/4-approved-redesign-paraphrasing`

2. **Run 26133786055 — `Lint (swift-format --strict)` failed**
   - Root cause: `.swift-format` config set 2-space indentation; codebase uses 4-space
   - Fix: Changed config to 4 spaces; ran `xcrun swift-format format --in-place` on `app/Sources` + `app/Tests`
   - Fixed: Indentation, TrailingComma, NoAccessLevelOnExtensionDeclaration, AddLines, LineLength violations
   - Commit: `c5266e4`

3. **Run 26133857651 — `Build & Test` failed — "Failed to terminate"**
   - Error: `UVBurnTimerUITests.swift:153: Failed to terminate com.yashasgujjar.uvburntimer:47707`
   - Root cause: `XCUIApplication.launch()` tries to terminate prior instance; prior test left app in terminated/zombie state, termination failed
   - Fix attempt 1 (b185932): Added `tearDownWithError` + `runningApp` property — failed with Swift 6 actor isolation errors
   - Fix attempt 2 (21b5676): Added explicit `XCUIApplication().terminate()` before each `launchApp()` call — correct approach, no actor isolation issues

4. **Run 26134524947 — Swift 6 actor isolation compile error**
   - Error: `tearDownWithError()` override (nonisolated) accessing `@MainActor` property `runningApp`
   - Fix: Reverted tearDown+runningApp; used pre-launch explicit terminate instead
   - Commit: `21b5676`

5. **Run 26135131773 — cancelled (concurrency race)**
   - Webhook sent duplicate events; run cancelled before posting status to GitLab
   - Fix: Empty re-trigger commit `2bb02ab`

**Final result:** Run 26135229688 — ✅ **Build & Test PASSED** (10m21s)  
GitLab MR !3 pipeline: **`success`** (sha `2bb02ab`)

**Learnings:**
- The GitHub CI workflow (`github/main:.github/workflows/ci.yml`) is decoupled from the GitLab branch. When renaming the Xcode project, CI must also be updated. The two repos must stay in sync on project paths.
- `build.sh` must support CI env vars (`CONFIGURATION`, `DERIVED_DATA_PATH`, etc.) — the CI bridge passes these for selective build/test control.
- Swift 6 strict concurrency on Xcode 26: `tearDownWithError()` overrides are NOT implicitly `@MainActor` even if the class is. Using `XCUIApplication().terminate()` before launch is the correct pattern.
- Concurrency group `cancel-in-progress: true` can cause webhook-triggered runs to cancel each other if webhooks fire in rapid succession. An empty re-trigger commit resolves this.
- 2026-05-19T18:53:47.266-07:00 — Rebased MR !2 app icon catalog onto `origin/main`:
  - Existing `squad/fix-app-icon-catalog` history carried stale `squad-work-loop-ci-tests` commits, so I created a safety backup branch (`backup/app-icon-before-main-rebase-2026-05-19`) and rebased only the app-icon commit onto latest `main`.
  - Retargeted GitLab MR !2 from `squad-work-loop-ci-tests` to `main` and kept the existing MR to avoid duplicate review surfaces.
  - Validated icon catalog with a Contents.json/PNG pixel-dimension check (18 entries) and ran `./build.sh` locally on the project-selected iPhone simulator; both passed.
  - External CI bridge can emit duplicate GitHub repository_dispatch events; when the first MR run was cancelled, an empty `ci: retrigger app icon validation` commit restored a clean external pipeline.

- 2026-05-19T20:04:12.851-07:00 — Added root `run.sh` for local simulator launch:
  - Reuses `./build.sh` with `CONFIGURATION=Debug`, `RUN_TESTS=false`, a repo-local ignored `.build/DerivedData`, and the selected iPhone 17 Pro destination.
  - Resolves the built `.app` path from `xcodebuild -showBuildSettings`, then boots, installs, and launches via `xcrun simctl`.
  - Includes `--print-app-path` for quick path validation without launching.
  - Validation passed: `bash -n run.sh`, `./run.sh --print-app-path`, and full `./run.sh` (Debug build succeeded, simulator booted, app installed/launched on iPhone 17 Pro).
- 2026-05-19T20:34:41.561-07:00 — Fixed circular gauge visibility on the running iPhone 17 Pro app:
  - Root cause: `BurnRiskGaugeCard` was wired as a separate `ScrollView` sibling after `HeroTimerCard`; on iPhone 17 Pro the persistent footer/safe-area inset covered most of that sibling at first paint, so users could only see a clipped arc at the bottom instead of the circular gauge.
  - Fix: moved `BurnRiskGaugeCard` into `HeroTimerCard` below the estimate context line, preserving the existing data guard (`fetchedAt`, non-`.none` tier, finite raw minutes), health caveat copy, and gauge accessibility copy.
  - Files: `app/Sources/UVBurnTimer/AppViews.swift`, `app/Tests/UVBurnTimerUITests/UVBurnTimerUITests.swift`.
  - Validation: `DERIVED_DATA_PATH="$PWD/.build/DerivedData" CONFIGURATION=Debug RUN_TESTS=true ./build.sh`; `DERIVED_DATA_PATH="$PWD/.build/DerivedData" ./run.sh`; screenshot confirmed full gauge visible on iPhone 17 Pro.
- 2026-05-19T21:34:24.682-07:00 — Fixed simulator/development gauge visibility by rendering an explicit unavailable `BurnRiskGauge` shell inside the hero card whenever CoreLocation/WeatherKit have not produced a usable UV estimate. The fallback uses no fake UV data: accessibility value is "Unavailable," copy names the missing location/Apple Weather state, and valid estimates continue to drive the real percentage gauge. Added UI regression coverage for no-estimate, location-unavailable, weather-unavailable, and valid-estimate states.
- 2026-05-19T22:34:50.179-07:00 — Removed SPF None as a user-facing sunscreen choice:
  - `SPFLevel.allCases` now lists only sunscreen products (15, 30, 50, 70+); the old no-SPF path is retained only as `unprotectedReference` for internal/reference math tests.
  - UI/debug seeds now default to real SPF values, and UI coverage asserts the segmented control does not expose "None".
  - Validated with `DERIVED_DATA_PATH="$PWD/.build/DerivedData" CONFIGURATION=Debug RUN_TESTS=true ./build.sh` after integrating with the active 2-hour sunscreen-cap work.
- 2026-05-19T22:27:48.170-07:00 — Fixed main-screen Location chip routing and gauge prominence:
  - `Location` now invokes the location/UV refresh flow instead of presenting Settings; Settings remains on the gear button.
  - Reworked `BurnRiskGaugeCard` and unavailable gauge shell into large centered SwiftUI circular rings inside the hero card, preserving honest unavailable copy/value when WeatherKit/CoreLocation has no estimate.
  - Added UI regression coverage for Location-not-Settings routing and gauge minimum visual size on valid estimates.
- 2026-05-19T22:29:07.093-07:00 — Sunscreen-protected estimates now treat the 2-hour guidance as a hard reapplication cap: SPF calculations keep the raw MED math for honesty, but app display/elapsed-window logic uses an effective max of 120 minutes for sunscreen-backed windows. Unprotected-reference estimates are not capped by sunscreen timing. UI copy should say “at least every 2 hours” and explain that the 120-minute limit is a reapplication limit, not necessarily the mathematical burn threshold.
- 2026-05-19T22:43:49.465-07:00 — Implemented local preference persistence for skin type, SPF, and privacy-safe location choice on the active `squad/fix-location-gauge-ui` branch: `UserPreferenceStorage` restores skin/SPF from UserDefaults with `.spf30` as the safe fallback for invalid/legacy unprotected values, RootView syncs changes via `@AppStorage`, and location persistence remains rounded-coordinate-only plus a local rationale/mode acknowledgement. Disclaimer acknowledgement remains transient.
- 2026-05-19T22:50:27.684-07:00 — Burn/sunscreen duration display now uses compact hours+minutes labels instead of requiring users to convert long minute counts mentally. Current presentation examples: capped sunscreen window `Up to 2 hr`, exact hour `~1 hr`, under-hour `~33 min`, and long display cap `4+ hr`; the 120-minute sunscreen cap remains unchanged. Validation: core tests passed on iPhone 17 Pro Kwame Clean; `./build.sh` Debug build passed with `RUN_TESTS=false`; full UI test launch was blocked by CoreSimulator/testmanagerd Mach -308, not an assertion failure.
- 2026-05-19T23:31:00-07:00 — Incorporated the approximate/coarse location directive into the active location persistence workstream:
  - `DeviceLocationProvider` now requests reduced CoreLocation accuracy on iOS 14+ (`kCLLocationAccuracyReduced`) and falls back to kilometer accuracy only for older OS behavior.
  - Device coordinates are rounded before leaving the location provider, WeatherKit requests still use rounded coordinates, and `CachedRoundedCoordinate` now enforces rounded storage even if a precise coordinate is accidentally passed in.
  - Updated location permission/privacy copy and Info.plist usage text to state approximate location; added regression coverage that cached storage never persists precise coordinate strings.
  - Validation: Debug build succeeded; Swift Testing core suite passed 62/62 including the new coordinate-storage regression. Full UI test run and a targeted location UI retry were blocked by simulator automation/device-state failures after app launch, not Swift compile or core-test failures.
- 2026-05-19T23:10:55.677-07:00 — Investigated MR !7 GitHub CI failures on `squad/fix-location-gauge-ui`: the original warning failure was Xcode 16.4/actool selecting an iPhone 17 Pro simulator (`iPhone18,1`, iOS 26 runtime) whose trait set it could not resolve, not an asset-catalog content defect. The branch now avoids that CI-only pairing by selecting older stable simulators on Xcode <26 while keeping warnings-as-errors intact, and UI tests are forced serial with one simulator destination. A follow-up CI failure was a UI test using a >128-character direct accessibility identifier query; use the existing NSPredicate-based `staticText(in:containing:)` helper for long copy assertions.
- 2026-05-19T23:10:55.677-07:00 — Resolved MR !7 against latest `main` after MR !8 landed: preserved the large hero circular gauge and Location chip flow from `main` while keeping MR !7's SPF product-only options, 120-minute sunscreen reapplication cap, compact hour/minute duration labels, approximate/rounded location persistence, and CI simulator/script fixes. Local validation passed with `UV_BURN_TIMER_DESTINATION="platform=iOS Simulator,id=C9BB5ACD-3C59-4CC9-9713-A477506D455D,arch=arm64" DERIVED_DATA_PATH="$PWD/.build/DerivedData" ./build.sh` (serial UI tests, one simulator). The default iPhone 17 Pro simulator hit a local CoreSimulator service-hub failure, so iPhone 15 was used as the stable single-device validation target.

### 2026-05-21T00:55:49Z — Incoming: 10-day UVI forecast feature + time-to-burn picker (WI-7 round 2)

- **What's coming:** User-initiated date/time picker for burn-time estimates on forecasted days (user-initiated opt-in, hard cap at D+7). Flat visual treatment (no opacity/gray decay). Card-level `.caption .secondary` footnote. Integer UVI on D1–5 only; WHO category band on D6–10 (information geometry, not visual demotion).
- **Picker entry point:** "Plan for another time" chip below main burn-time number on BurnTimeCard. Taps → `.sheet` with `DatePicker(displayedComponents: [.date, .hourAndMinute])`, `.graphical` style.
- **Picker range:** `Date.now` to `Date.now + 7 * 24 * 3600` (D+7 hard cap, structural enforcement — Wheeler held this line, non-negotiable). Days 8–10 refuse with graceful-refusal copy: "Forecast accuracy beyond 7 days is limited. Use the 10-day UV forecast card to see the category for this day."
- **Picker edge cases (CRITICAL):**
  - UVI 0 (night / pre-dawn / sun below horizon) → "No UV at this hour — no sun protection needed." NOT ∞, NOT a number. Same `.none` tier treatment as live view.
  - User hasn't selected skin type → Show gate prompt (reuse D-2026-05-19-012 logic): "Set your skin type to see a planned burn window."
  - Forecast data unavailable for selected hour → Show "Forecast unavailable for this time" with retry button; disable Done until data resolves or user selects different time.
  - Picker hits day 7 boundary (D+7 + 1 second) → Clamp picker input; show day-8+ refusal copy.
  - ReduceMotion active → Instant burn-time result swap (no count-up, no spring animation); under normal: `.animation(.easeIn(duration: 0.15))`.
- **Visual treatment:** Result displayed at `.title2` scale in sheet, same language as hero card. No per-row opacity on the 10-day card itself (flat treatment locked).
- **Photosensitization disclosure on picker sheet:** D-2026-05-19-013 extends to this surface. If absent, picker doesn't ship.
- **L3 chevron on forecast card:** New affordance at card foot: "Is this estimate for me?" → navigates to About @ photosensitizer section (Plunder's minimum-compliant-surface pattern; reuses locked D-2026-05-19-011 copy).
- **WeatherKit attribution:** Present on forecast card and picker-sheet surfaces (D-2026-05-19-003 / D-2026-05-19-004 extend).
- **Orchestration log / session log:** Attached to `.squad/log/2026-05-21T00:55:49Z-uvi-forecast-pushback-round-2.md` and orchestration logs for Wheeler, Iris, Plunder.


### 2026-05-20T18:06:16-07:00 — WI-7 Forecast Storage Mechanism Proposal

## Learnings

- **Storage mechanism decision (WI-7 forecast data):** Recommend **Option B — single-file JSON cache in `FileManager.default.urls(for: .cachesDirectory)`**. File: `forecast-snapshot.json`, containing a `ForecastSnapshot` Codable struct with a `fetchedAt: Date`, `roundedCoordinate: UVCoordinate`, `dailyForecasts: [DailyForecastEntry]` (10 days), and `hourlyForecasts: [HourlyForecastEntry]` (up to 240 hours). Estimated payload ~20–25 KB uncompressed. Rationale: iOS 16 minimum prevents SwiftData; Caches directory is OS-evictable (free cleanup); single-file atomic overwrite eliminates partial-write corruption risk; no schema migration machinery needed; on decode failure → treat as absent and re-fetch. Multiple-coord support via `roundedCoordinate` field in snapshot header — on load, compare stored coord against current; discard if moved.
- **ForecastStore actor:** New `actor ForecastStore` in `UVBurnTimerCore` (or as a layer in the app target). Owns all disk I/O for the forecast cache. Protocol-backed for testability: `protocol ForecastStoring`. No `DispatchQueue`. Strict Concurrency compatible. WeatherKit fetch is done by caller (RootView or a new `ForecastViewModel`), then deposited into the store. Store never calls WeatherKit directly.
- **Picker data dependency:** Picker view-model calls `ForecastStore.hourlyUVIndex(at: Date) -> Double?`. O(1) lookup: round date to hour, binary-search hourly array. NEVER re-fetches synchronously. If cache is stale, serve stale data immediately and post a background refresh task. If cache is absent entirely, surface "Forecast unavailable for this time" + retry button (edge case locked in WI-7 spec).
- **Refresh trigger:** `scenePhase == .active` observer in RootView (already exists, line 110–128 of AppViews.swift). Add staleness check: if `ForecastStore.fetchedAt` is nil OR older than 6 hours, trigger `refreshForecast()` async. No BGAppRefreshTask for v1 — cost/complexity ratio too high for a planning feature. Once-per-day natural cadence is effectively enforced by 6h staleness gate: typical user opens app 1–2× daily.
- **Cleanup/eviction triggers (to coordinate with Gi):** Time-based (>24h → discard on next active), coord-based (user moved by > ~10 km / 0.1 degree at 2dp rounding → discard old snapshot), version-based (schema version field; mismatch → discard), OS-managed (Caches directory is evictable at any time — we never assume it's present).

## 2026-05-21 Session Update — WI-7 Consolidation Round

**Context:** Iris's UX spec (iris-2 spawn) is finalized. Wheeler has ratified polar-region science + one copy MODIFY. All three blocked design questions (picker horizon, days 6–10 scalar, data shape) have been answered via user directives.

**Status for Kwame:** No blockers. Iris's loading-state contract is finalized. Wheeler confirmed polar handling is correct (formula stands; no special-casing). All five prior WI-7 decisions reconfirmed unchanged. Ready to implement SwiftUI surfaces + WeatherKit integration per locked contracts:

1. **Storage:** `ForecastSnapshot` with `expirationDate` added (use Apple's metadata, not hardcoded threshold); `dayCount × 24` hourly regularization (pad or slice if WeatherKit < 10 days)
2. **Picker:** D+7 hard cap confirmed; edge cases locked (UVI=0 → `"No UV at this hour"`; no skin type → prompt; forecast unavailable → retry)
3. **UI state:** Loading-state UX locked (Iris §1.2–1.4: skeleton rows + shimmer, disabled chips, error block, retry button)
4. **Offline:** Stale snapshot + disclosure banner if fetch fails
5. **Coord eviction:** 50 km radius (not 10 km; aligns to Apple approximate-location precision)

**No re-specs pending.** Iris will review each surface as built; Wheeler will review health-adjacent numbers. Ma-Ti has acceptance criteria (polar-night collapsed state, picker edge cases, Dynamic Type, a11y, Reduce Motion).

Ready to proceed with implementation.

---

## WI-7 Supersedes — 2026-05-21T01:58:19Z (Scribe consolidation)

**Polar API research findings — locked, but scope narrowed in v1.**

Kwame's WeatherKit polar-latitude API research is complete. Key findings:
- WeatherKit type is `SunEvents` (not `Sun`). `DayWeather.sun: SunEvents` (non-optional).
- Canonical polar-night trigger: `DayWeather.sun.solarNoon == nil` (explicitly documented nil-only for polar night).
- `HourWeather.uvIndex` returns `0.0` for polar-night hours (not nil/missing).

User directive 2026-05-21T01:58:19Z (polar-treat-as-nighttime) narrows the scope: polar night is treated identically to regular nighttime (UVI = 0) at the UI layer. The canonical polar-night signal (`solarNoon == nil`) is locked but will NOT be used in v1 UI detection logic. When Kwame returns, findings synthesize into a one-line data-mapping rule ("handle UVI = 0 as nighttime") rather than a polar-specific detection code path.

Rationale: Apple treats polar night as UVI = 0. No special UI/copy needed in v1. Feature deferred to post-ship if needed.

**Status:** Research locked. Implementation path simplified. No blockers.
