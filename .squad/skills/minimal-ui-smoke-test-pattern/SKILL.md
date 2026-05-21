# Skill: Minimal UI Smoke Test Pattern

**Extracted:** 2026-05-21T07:50:00Z  
**Author:** Ma-Ti (Test Engineer)  
**Triggered by:** Yashas directive to cut 38 UI tests to 5 smoke tests

---

## When to use UI tests vs contract tests

### Use contract tests (XCTest unit tests in `UVBurnTimerCoreTests`) for:
- String content: copy strings, labels, ProductCopy constants
- Business logic: burn time math, SPF cap, stale-estimate thresholds
- Data model invariants: ForecastPickerLogic, UserPreferenceStorage
- Per-surface presence of UI elements that live in Core (ViewModels, enums)
- Edge-case states (extreme UV, type I/VI, all four SPF levels)
- **Rule:** If the test only needs a `@testable import UVBurnTimerCore`, it belongs here.

### Use UI tests (XCUITest in `UVBurnTimerUITests`) only for:
- Things that can **only** be verified end-to-end: the app didn't crash on launch, an OS-level alert fires, a sheet opens via a toolbar gesture
- Integration paths that cross two presentation layers (onboarding cover → skin-type cover → main screen)
- Structural regressions that unit tests cannot catch (a whole card being removed from a `VStack`)
- **Default is delete.** If a unit test covers the same invariant, the UI test is redundant.

---

## The 5 Canonical Smoke Tests for a Single-Screen iOS App

For apps with one main screen and an onboarding cover, these five tests provide maximum signal with minimum simulator time:

1. **App launches without crash** — cold start with a seeded state (skip live network), assert nav bar renders within 10 s
2. **Core onboarding flow completes** — disclaimer → picker → main screen; verifies the cover chain works end-to-end
3. **Primary CTA fires system affordance** — tap the main action button, verify the OS or app responds (not a no-op, not a wrong route)
4. **Key card/section is structurally present** — scroll to find a component that could be silently removed; assert its header exists
5. **Settings sheet opens** — toolbar gear → Settings nav bar; verifies the presentation layer isn't broken

---

## What makes a good smoke test

- **Under 30 lines** per test function
- **Structural assertions only** — no copy string comparisons (`label == "..."`)
- **One key invariant** per test — no omnibus scenario tests
- **Uses seeded launch arguments** (`-uiTestLongUncappedEstimate`, etc.) to avoid live network dependency
- **Deterministic** — passes the same way on CI and local; never depends on WeatherKit network
- **The `tapUntilAppears` pattern** for iOS 26 cover-chain races (see shared helper)

---

## What to delete (the "default delete" list)

Delete any UI test that:
- Asserts a specific copy string (covered by ProductCopy contract tests)
- Iterates over multiple skin types or SPF values (covered by unit tests)
- Checks per-surface element presence (banner, footer text, card links)
- Tests an edge-case state (stale estimate, capped estimate, weather unavailable) — these belong in unit tests against the ViewModel
- Takes more than 30 seconds of simulator time to set up
- Duplicates a scenario already covered by a contract test

---

## File-size target

| Metric | Target |
|---|---|
| Total UI tests | 4–6 |
| File size | < 300 lines |
| Per-test setup time | < 30 seconds |
| Total suite runtime | < 5 minutes on simulator |

---

## Test pyramid for single-screen apps

```
        /\
       /  \     UI Tests (5) — smoke only
      /----\
     /      \   Contract Tests (100+) — copy, logic, invariants
    /--------\
   /          \ Unit Tests — pure functions, math, state machines
  /____________\
```

The pyramid is inverted in simulator-heavy codebases. Contract tests at the constant layer run in milliseconds and cover 90% of regression surface. UI tests should be the thin apex, not the base.

---

## Learnings from the 38→5 cut (2026-05-21)

- **38 UI tests on a single-screen app is too many.** All the edge-case state tests (stale estimate, capped estimate, weather unavailable, attribution visibility) duplicated coverage that existed or could exist at the contract layer.
- **Attribution tests don't need UI.** `assertAppleWeatherAttributionVisible` ran the simulator just to check a string that `ProductCopy.weatherAttributionServiceName` already guardrails.
- **The simulator is a resource hog.** Every 10 UI tests ≈ 1–2 min of CI time. 5 tests ≈ 60 s. 38 tests ≈ 5–8 min.
- **The `testScenario*` naming pattern is a smell.** If a test is named after a scenario, it likely covers too many invariants. One invariant, one test.
