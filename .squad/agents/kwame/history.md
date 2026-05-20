# Kwame — History

## Core Context

- **Project:** A UV exposure and sunburn timer app
- **Role:** Backend Dev
- **Joined:** 2026-05-19T06:26:01.546Z

## Learnings

<!-- Append learnings below -->

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
