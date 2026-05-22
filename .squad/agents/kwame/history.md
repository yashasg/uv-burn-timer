
1. **Rebase, not merge, when base is squash-merged.** GitHub's squash collapses N commits into 1 with a new SHA; my branch's old base commits no longer exist in history. A merge would create a 2nd copy of the work on a parallel history line — confusing reviewers and producing a duplicate squash-merge later. Rebase replays the leaf commits onto the new SHA cleanly. The PR's `MERGEABLE` flip after force-push confirms this is what reviewers expect.
2. **`--force-with-lease` discipline.** Always pair force-push with `--force-with-lease` so a concurrent agent push to the same branch tip aborts the push instead of overwriting their commits. In this session a fresh-fetch + immediate rebase + immediate push made the window small; the lease flag would have caught any racing push.
3. **Two helpers with overlapping intent are fine if call sites diverge.** Tempting to consolidate `waitForToolbarSettled` (Bool) into `waitForMainToolbarSettled` (struct) — but the Bool gate is what `XCTAssertTrue(...)` wants, and the struct lets per-button assertions pinpoint *which* button missed. Consolidation would either lose per-button blame in error messages or force every caller to read snapshot fields. Mechanical-reconciliation rule: when in doubt during conflict resolution, KEEP BOTH and let a future PR consolidate if it's actually warranted. Don't invent design in a rebase.
4. **Build-for-testing is the right smoke for a test-file-only rebase.** Full sim suite is ~5 min × N flakes; `xcodebuild build-for-testing` is ~30s and proves the merged Swift compiles in the UI test target. CI runs the real thing — don't double-spend the local box.
5. **Stash-list discipline.** This repo has 40+ accumulated stashes from agents that didn't drop after recovery. None of mine added this session, but the inventory is becoming a hazard — a future cleanup pass should `git stash drop` everything older than 7 days.

**2026-05-22T20:30:00Z** — Loop-30 iter-2 closure: PR #114 merged (5b899df), PR #111 merged (c3f2bbc), cross-agent review discipline held, UI-runner flake corpus ready for WI-30-1 dispatch.

## 2026-05-22T20:55:00Z — WI-loop30-4a-iris-3sites: fix 3 SF Symbol a11y sites per Iris catalog (PR #120)

Iris's image-a11y fixture catalog (`.squad/decisions/inbox/iris-image-accessibility-fixtures.md`) classified three `app/Sources/` sites as POSITIVE under the upcoming `image_systemname_missing_accessibility_label` AST rule. All three are P5 shape — bare `Image(systemName:)` adjacent to a `Text`/`Label` sibling — leaking the SF Symbol name through VoiceOver, violating WCAG SC 1.1.1. This PR is the hard prerequisite for PR #119's revised landing per Gaia's adjudication (`gaia-pr119-adjudication.md`).

**Sites fixed:**

1. `app/Sources/UVBurnTimer/AppViews.swift:1152` (TierBadge accessory `differentiateWithoutColor` glyph) — `.accessibilityHidden(true)` on the `Image`. The sibling `Label(title, systemImage:)` already announces the tier; the accessory is purely visual.
2. `app/Sources/UVBurnTimer/ForecastPickerView.swift:209` (stale-banner spinner, `arrow.clockwise`) — `.accessibilityElement(children: .combine)` + `.accessibilityLabel("Updating forecast")` on the parent `HStack`. Banner is a single status announcement.
3. `app/Sources/UVBurnTimer/ForecastPickerView.swift:230` (refresh-error banner, `exclamationmark.icloud`) — `.accessibilityElement(children: .combine)` + `.accessibilityLabel("Could not update forecast")` on the parent `HStack`. Retry `Button` remains focusable (combine respects controls).

**TDD:** new file `app/Tests/UVBurnTimerCoreTests/ImageSystemNameAccessibilityContractTests.swift` with three `@Test` cases (`test_A11Y_1/2/3`). Source-scan contract per WI brief — slices around each `Image(systemName:)` expression and asserts the expected accessibility modifier appears. RED confirmed pre-edit; GREEN confirmed post-edit under `./build.sh`. Wired into `app/app.xcodeproj/project.pbxproj` (XCUI + SPM both see it; `scripts/check-test-membership.sh` clean).

**Side-effect:** Adding `.accessibilityHidden(true)` to TierBadge shifted lines below 1152 by +1, breaking `test_S5_adr0001CitationsMatchLiveSourceLineNumbers`. Bumped ADR-0001 PersistentFooter `AboutView` push citation: `line **2170**` → `line **2171**`, body block `2169–2171` → `2170–2172`. S5 now passes. All other ADR-0001 anchors are above line 1152 and unaffected.

**Verification:** `./build.sh` — SwiftLint HIG gate ✓ (0 violations), AST gate ✓ (0 violations), Debug + Release builds clean, all `UVBurnTimerCoreTests` pass (including new A11Y-1/2/3 and refreshed S5). One pre-existing UI-test flake (`testEstimateInfoButtonOpensAboutWithHighlightedApplicabilityAnchor`) also fails on `github/main` baseline — unrelated to this change.

**Scope guardrails:** `tools/swiftlint-rules/` untouched (Gaia's territory), `.swiftlint.yml` untouched, PR #119 not modified. 3 sites + 1 contract-test file + 1 ADR line-number refresh + 1 pbxproj wiring.

**PR #120:** https://github.com/yashasg/uv-burn-timer/pull/120 — CI runs `26312959589` (push) and `26313088707` (PR) in flight at write time. Decision-inbox file: `.squad/decisions/inbox/kwame-iris-3sites-opened.md` (full before/after snippets, HIG choice per site, CI capture).

### 2026-05-22T22:15:00Z — Loop-30 closure — final review delivered. Goals: 4/5 PASS (Goal-5 hardware-blocked). 8 PRs merged. 10 WIs carry-forward.
