# Skill: xcodebuild Test Count Reliability

## Problem

`xcodebuild` multi-target projects have separate test targets (e.g., unit tests + UI tests). Running with the framework/library scheme only executes the unit target. Reporting "all tests pass" without explicitly running both targets leaves UI test failures invisible.

Discovered via: 6 UI test failures missed across two consecutive agent handoffs (Kwame-7 + Ma-Ti-2) on `feature/main-screen-cleanup`. Both agents ran the unit target only and reported clean.

## Pattern

### Wrong (runs UVBurnTimerCoreTests only)
```bash
xcodebuild -scheme UVBurnTimerCore -destination '...' test
```

### Correct (runs both UVBurnTimerCoreTests + UVBurnTimerUITests)
```bash
xcodebuild -scheme UVBurnTimer -destination 'platform=iOS Simulator,name=iPhone 15' test \
  2>&1 | grep "Executed"
```

Expected output has **two** `Executed N tests` lines — one per target. Verify both are present and both show `0 failures`.

## Verification checklist

After any test run:
1. Confirm scheme used covers all test targets (check with `xcodebuild -list`).
2. Count `Executed N tests` lines in output — must match number of test targets.
3. Confirm each line shows `0 failures` before reporting clean.
4. If the suite has known-issue wrappers (`withKnownIssue`), those show as `N unexpected` = 0, and may show as `N failures` = 0 too — but `unexpected` is the key field; `withKnownIssue` failures are expected by design.

## Applicability

Any multi-target iOS/macOS Xcode project where unit tests and UI tests live in separate targets under a parent app scheme. The unit target scheme (`UVBurnTimerCore`) does NOT include UI tests — always use the app scheme (`UVBurnTimer`) for a full run.
