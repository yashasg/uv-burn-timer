# Squad Loop-End Parallel Review — 2026-05-20

- **Loop being closed:** the loop opened by
  `.squad/decisions/inbox/gaia-backlog-20260520T0430Z.md` (WI-11..WI-17
  + test-infra hardening MR !21)
- **Date:** 2026-05-20
- **Reviewed against:** `loop.md` §6 Goals Checklist (current `main`
  version, updated by WI-16 to require both Iris checklists)
- **Branch under review:** `main` @ `6a00209`
  (`Merge branch 'squad/wi-16-iris-launch-readiness-checklist' into 'main'`)
- **Cross-checked inputs:**
  - `.squad/files/user-flow-onboarding-main-spec.md`
  - `.squad/files/suchi-persona-annotations.md`
  - `.squad/files/iris-launch-readiness-checklist.md` (newly on main)
  - `README.md` "User scenarios captured" + "Privacy and product
    guardrails"
  - Decisions-ledger tail (`tail -600 .squad/decisions.md`)
  - Current backlog (`.squad/decisions/inbox/gaia-backlog-20260520T0430Z.md`)
  - `git log --oneline main` and `git show <sha>` for every commit
    asserted below
  - Open feature branches `squad/wi-{12,13,15,17}-*` and
    `squad/harden-disclaimer-cover-tap-loop`

## What is actually on `main` right now

Only **two** of the seven closing MRs from this loop have been merged.
Per the loop's review constraint, *open MRs do not count* against the
Goals Checklist until they land on `main`.

| WI / MR | Status on `main` | SHA |
|---|---|---|
| **WI-11** (P1) Hero empty state copy | ✅ MERGED | `4eac024` (merge `e795c35`) |
| **WI-16** (P3) Iris polarized-OLED launch-readiness checklist + `loop.md` §6 update | ✅ MERGED | `ca87150` (merge `6a00209`) |
| **WI-12** (P2) Plunder ratifies `Clear saved location` does NOT clear rationale ack | ⛔ open MR !20 on `squad/wi-12-rationale-ack-clear-coord-adr` (`063b5cb`) | — |
| **WI-13 + WI-14** (P3) Inline `see About` deep-link + SPF spec correction | ⛔ open MR !22 on `squad/wi-13-inline-disclaimer-see-about-link` (`ec174a6`, `680ca87`) | — |
| **WI-15** (P3) Iris contrast QA checklist | ⛔ open MR !24 on `squad/wi-15-iris-contrast-qa-checklist` (`8e4f5da`) | — |
| **WI-17** (P3) Scribe fold inbox decisions into ledger | ⛔ open MR !25 on `squad/wi-17-scribe-fold-inbox-decisions` (`f19b7f7`, `00b74ea`) | — |
| Test-infra harden (cover-chain `{-1,-1}` race) | ⛔ open MR !21 on `squad/harden-disclaimer-cover-tap-loop` (`cc9fbaf`) | — |

This single state-of-`main` observation drives most of the verdicts
below: the loop **opened** seven changes and **closed only two** on
trunk. Five remain in flight, including the WI-15 file that the just-merged
`loop.md` §6 update explicitly names as a gate on Goal 5.

---

## 1. Gaia (Lead / Architect) — architecture, decision discipline, scope creep

**Verified.** Walked `git log --oneline 7daac21..main` (= `4eac024`,
`e795c35`, `ca87150`, `6a00209`) and confirmed every shipped change is a
squash-merge of a single-branch feature MR per loop.md §5. Confirmed
`main` has a clean tree, no in-progress feature branches sitting on
top, and no architectural surprises in either merged commit. The two
shipped commits are docs + a narrow SwiftUI copy refactor — both
within scope for a maintenance loop.

- ✅ Working app: `main` HEAD is `6a00209`, working tree clean, no
  unmerged conflicts.
- ⚠️ Expert approved (architecture lens): the **Plunder ADR**
  ratifying the `Clear saved location` × rationale-ack decoupling
  (WI-12) sits on `squad/wi-12-rationale-ack-clear-coord-adr` and has
  not landed. `clearSavedRoundedCoordinate` (`AppViews.swift:483–488`)
  intentionally clears only the rounded coordinate and never touches
  `persistedLocationRationaleAcknowledged`, but on `main` this is
  undocumented architectural intent — no ADR addendum, no pinning
  test. This is the exact failure mode the ADR-first workflow is
  supposed to prevent.
- ⚠️ Decision discipline: `.squad/decisions/inbox/` on `main` still
  contains `gaia-backlog-20260520T0430Z.md` and
  `gaia-location-rationale-persistence.md` — neither folded into the
  ledger. WI-17 is the fold-pass and it is unmerged. Worse, the
  `loop-closure-20260520T043000Z.md` and `gaia-model-default-loop.md`
  files referenced by Gaia's own backlog (§ "Inflight inbox files not
  yet folded into the ledger") do not exist in git history at all
  (`git log --all -- .squad/decisions/inbox/loop-closure-20260520T043000Z.md`
  returns empty). The default-model directive is in `loop.md` §1 but
  has no ratified ADR backing it in the ledger.

**Proposal — WI-18 (P1, Gaia → Plunder review):** Land the WI-12 ADR
on `main` (rebase `squad/wi-12-rationale-ack-clear-coord-adr` onto
current `main`, re-run CI, merge) so the rationale-ack × clear-coord
contract is documented and pinned. Acceptance: new
`.squad/decisions/inbox/plunder-rationale-ack-clear-decision.md` (or
equivalent path chosen by the branch) ratified in the ledger; new
core test `clearSavedLocationDoesNotClearRationaleAcknowledgment`
green on CI; documentation explicitly names the user's escape hatch
(uninstall) per the original ADR's "out-of-scope" section. Files:
`.squad/decisions/inbox/plunder-rationale-ack-clear-decision.md`,
`app/Tests/UVBurnTimerCoreTests/UVWorkflowTests.swift`.

**Proposal — WI-19 (P2, Scribe → Gaia review):** Materialize a loop
closure note for **this** loop (`loop-closure-20260520T0530Z.md` or
similar) and ratify `gaia-model-default-loop` *as a tracked file*
(today `loop.md` §1 references the model default but no file backs
it). Acceptance: both files exist on disk, both are appended to
`.squad/decisions.md` via the existing `<!-- Source: ... -->`
pattern, and Gaia's next backlog can point at them by path. Files:
`.squad/decisions/inbox/loop-closure-20260520T0530Z.md`,
`.squad/decisions/inbox/gaia-model-default-loop.md`,
`.squad/decisions.md`. (Note: this supersedes the prior WI-17 scope
because that scope referenced now-stale file paths.)

---

## 2. Iris (UI/UX Designer) — HIG, accessibility, contrast, Dynamic Type, VoiceOver

**Verified.** Re-read every LANE-2 surface in `AppViews.swift`:
photosens banner, hero card, severity tier badge, gauge ring,
SafetyStatusCard, compact `Location + SPF` chip row, persistent
footer link. All match the spec at the level it was approved at
`7daac21`. Re-read my own newly-merged
`.squad/files/iris-launch-readiness-checklist.md` (145 lines, signed
into `ca87150`) and the `loop.md` §6 sentence it added.

- ✅ UI/UX approved (shipped surfaces): no regression vs. the
  state-of-`main` Gaia signed off in `gaia-backlog-20260520T0430Z.md`
  §1 row 2. WI-11's hero empty-state refactor preserves Dynamic Type,
  preserves the `accessibilityLabel` fallback path
  (`AppViews.swift:764`), and routes through `ProductCopy` so the
  copy is auditable.
- ⚠️ UI/UX approved (drift not yet closed): on `main` the L1
  `DisclaimerCover` still renders the deep-link as a separate
  bordered `Label("See About: when estimates may not apply",
  systemImage: "info.circle")` at `AppViews.swift:968`, not as an
  inline link inside the body prose. The spec at
  `.squad/files/user-flow-onboarding-main-spec.md:42` still says
  *"inline see About"*. WI-13 is the fix and it has not landed.
- ⛔ Code tested and validated (gating Iris artifact): the file
  `.squad/files/iris-contrast-qa-checklist.md` (WI-15) **does not
  exist on `main`** (`ls .squad/files/` shows only the launch-readiness
  checklist + spec + persona annotations + the normalize script).
  My own freshly-merged `iris-launch-readiness-checklist.md:11` and
  `:129` reference that file as a sibling gate, and `loop.md:44`
  (merged via `ca87150`) names it as required for Goal 5. The
  launch-readiness checklist is on `main` but its sign-off block has
  **never been filled in** — file existence ≠ executed pass.

**Proposal — WI-20 (P1, Iris → Ma-Ti review):** Land the WI-15
contrast checklist (rebase `squad/wi-15-iris-contrast-qa-checklist`,
verify it still satisfies the WI-15 acceptance criteria after WI-16's
loop.md edit, merge). Acceptance: `.squad/files/iris-contrast-qa-checklist.md`
exists on `main`; the file enumerates every surface I listed in
WI-15 (banner, gauge ring track, gauge progress arc per tier,
SafetyStatusCard, hero number, footer link, attribution link, L1
"I understand" action); the sign-off block is present even though
empty. Files: `.squad/files/iris-contrast-qa-checklist.md`.

**Proposal — WI-21 (P1, Iris → Argos review):** Execute the *first
signed pass* of **both** checklists on a physical OLED iPhone
(13 Pro or newer per the launch-readiness checklist's Setup §) and
record the result in the sign-off blocks. Without this, Goal 5
cannot turn green: `loop.md:44` requires a "green sign-off …
within the current build cycle", not just a file. Acceptance: both
files have a completed sign-off line (build version, device, tester,
date, tool, ratio per row for the contrast file, polarization-tilt
result per row for the launch-readiness file); any failing row is
filed as a follow-up WI before declaring the build launch-ready.
Files: `.squad/files/iris-contrast-qa-checklist.md`,
`.squad/files/iris-launch-readiness-checklist.md`.

---

## 3. Kwame (iOS / SwiftUI / WeatherKit / CoreLocation)

**Verified.** Re-read `4eac024` end-to-end. The WI-11 implementation
matches the WI's acceptance criteria #1–#4 verbatim:
`ProductCopy.heroEmptyStatePrompt(hasSkinType:)` is a pure derivation
(no `@State` mutation), `displayedStatusMessage` (`AppViews.swift:278–289`)
prefers transient `statusMessage` and falls back to the computed
prompt, and the hero `accessibilityLabel` continues to use the same
field (`AppViews.swift:764`). The session-only branch is correct: the
mutation site at line 31 keeps `statusMessage = ""` so the computed
path runs whenever no transient event has fired.

- ✅ Working app: `./build.sh` Debug + Release pass on `main` at
  `6a00209` (`build.log` tail shows `** BUILD SUCCEEDED **`). WI-11
  did not introduce warnings (warnings-are-errors gate still green).
- ✅ Expert approved (iOS lens): WI-11 chose the SwiftUI-idiomatic
  fix — computed `var` over `@State` mutation — which is exactly the
  refactor I would have asked for in code review.
- ⚠️ Working app (test base): the test-infra hardening MR !21
  (`squad/harden-disclaimer-cover-tap-loop`, `cc9fbaf`) is not on
  `main`. `test.log` from this loop ends in `** BUILD INTERRUPTED **`
  at `t = 14.55s` with the cover-chain still mid-tap — exactly the
  iOS 26 / Xcode 26 `{-1, -1}` hit-point race that MR !21 is designed
  to fix via the `coordinate(withNormalizedOffset:)` path. Until !21
  lands the next loop will keep absorbing this flake.

**Proposal — WI-22 (P1, Kwame → Ma-Ti review):** Land MR !21
(rebase `squad/harden-disclaimer-cover-tap-loop` onto current `main`,
re-run CI under the same simulator matrix that surfaced the flake,
merge). Acceptance: `tapWithRetry` uses the coordinate-offset path
on iOS 26+ as described in `cc9fbaf`; the UI test sequence that
currently aborts at `t = 14.55s` runs to a green completion under
`./build.sh` locally; no regression on iOS 17 / 18 fall-back path.
Files: `app/Tests/UVBurnTimerUITests/UVBurnTimerUITests.swift`
(only the test helper change — no production code change).

---

## 4. Wheeler (Skin science — MED math, photobiology, citations, sunscreen 2-hour cap)

**Verified.** No commit on `main` since my prior approval at
`7daac21` touched `BurnTimeCalculator.swift`,
`ProductTiming.sunscreenReapplicationIntervalSeconds`,
`FitzpatrickSkinType.pickerDescription`, or the citation string set.
`4eac024` is a copy refactor scoped to the hero empty-state prompt
and adds no clinical claim. `ca87150` is a manual-QA checklist with
no MED-model implication.

- ✅ Expert approved (skin-science lens): no drift. The
  120-minute sunscreen cap is still pinned at
  `BurnTimeCalculatorTests.swift` (existing
  `uncappedLongEstimateStillExpiresAtTwoHourRefreshInterval` plus the
  display tests). Pass.

**Nothing to add.**

---

## 5. Plunder (Legal / compliance / privacy / attribution / prohibited integrations / copy truthfulness)

**Verified.** Re-read WI-11 copy
(`ProductCopy.emptyStateAwaitingLocation = "Tap Use my location to
compute your estimate."`) against my 8-flag pre-submit list. No
clinical claim, no monetization implication, no third-party data
flow, no attribution change. Confirmed `auditCopySurfaces`
(`BurnTimeCalculatorTests.swift:419`) now covers both new strings,
so the `productCopyAvoidsMonetizationDriftLanguage` and banned
clinical-claim audits apply to them.

- ✅ Expert approved (compliance lens, code only): WI-11 + WI-16
  introduce zero new legal surface.
- ⚠️ Expert approved (ADR discipline lens): **my WI-12
  ratification is the missing artifact.** On
  `squad/wi-12-rationale-ack-clear-coord-adr` (`063b5cb`) I have
  written the ADR addendum stating that
  `clearSavedRoundedCoordinate` deliberately does not reset
  `persistedLocationRationaleAcknowledged`, and added the pinning
  test, but the branch hasn't been merged. On `main` the behavior is
  shipped (line 483–488 of `AppViews.swift`) without the legal/IA
  paper trail that the original
  `gaia-location-rationale-persistence.md` guardrail #2 explicitly
  flagged to me for sign-off. That's a Plunder-discipline regression
  even though the code is right.

**See Gaia's WI-18 proposal** (Land WI-12 ADR). I co-own it; no
duplicate WI proposed here.

---

## 6. Argos (Monetization-absence guards, pricing copy, IAP-free posture)

**Verified.** Re-ran the grep set I rely on: no `StoreKit`,
`SKProduct`, `SKPaymentQueue`, `requestReview`, `SubscriptionStoreView`,
or any pricing string surfaced in the two commits since `7daac21`.
`pricingGuardrailsRejectInAppPurchaseFrameworks`
(`BurnTimeCalculatorTests.swift`) is still green and unmodified.
WI-11's new strings are routed through `ProductCopy` and added to
`auditCopySurfaces`, so the existing
`productCopyAvoidsMonetizationDriftLanguage` audit covers them.

- ✅ Expert approved (monetization-absence lens): the IAP-free
  posture is intact. Pass.
- ⚠️ Expert approved (launch-readiness reviewer lens, per WI-16):
  I am the listed reviewer for the polarized-OLED launch-readiness
  checklist, and I have **not** signed off the sign-off block on
  `.squad/files/iris-launch-readiness-checklist.md`. The file exists
  on `main` but is a blank template. Goal 5 cannot turn green on
  the strength of file existence alone.

**See Iris's WI-21 proposal** (First signed pass of both
checklists). I'm the executor for the launch-readiness half; no
duplicate WI proposed here.

---

## 7. Suchi (User research — personas, JTBD, user scenarios)

**Verified.** Cross-checked WI-11 against the persona annotations
(`suchi-persona-annotations.md`):
- Screen 2 ("Hero shows sun symbol + prompt 'Tap **Use my location**
  to compute your estimate'") now matches the implementation byte-for-
  byte after `4eac024`. Greta (P1), Devon (P3), and Tomás (P5) all
  observed the "stale 'pick a skin type' after onboarding" friction
  in earlier loops — that is closed.
- README "User scenarios captured" (10 items) is unchanged on `main`,
  and no scenario contradicts the new empty-state behavior.
- Cold-launch L1 re-attestation is preserved
  (`UVBurnTimerApp.swift` init), so Asha (P4)'s load-bearing safety
  loop is intact.

- ✅ User scenarios captured: README scenarios 1–10 still hold; no
  new scenario needed for WI-11 (it's a UI-state correction, not a
  new product behavior).
- ⚠️ User scenarios captured (persona-fit, Asha lane): per
  `suchi-persona-annotations.md` Screen 1 row "**Asha** *(purple)*",
  the design specifically says she taps an **inline** *see About*
  link inside the L1 body, then deep-links to `AboutView` at the
  `notForMe` anchor. On `main` that link is rendered as a separate
  bordered button (`AppViews.swift:968`), not an inline span in the
  prose. The deep-link is functional and her safety loop still
  works, so this is **not** a launch blocker — but the persona
  annotation that pins this as her attestation-via-visibility
  moment is, today, misaligned with shipped UI. WI-13 fixes the
  code; the persona annotation also needs a same-loop docs touch so
  the safety contract is named against the new inline anchor (not a
  generic button label) and future text edits cannot drift it.

**Proposal — WI-23 (P3, Suchi → Plunder review):** *After* WI-13
lands (Iris's inline-link rewrite of `DisclaimerCover`), update
`.squad/files/suchi-persona-annotations.md` Screen 1 Asha row to
explicitly name the inline span (e.g. *"taps the inline
`see About` link inside the disclaimer body"*) so the persona
overlay names the rendered control type, not a generic concept.
Acceptance: the persona annotation references the same
accessibility anchor the inline link exposes (so a future
`accessibilityIdentifier` rename is caught by review); the row
preserves the existing safety-architecture-via-visibility framing.
Files: `.squad/files/suchi-persona-annotations.md`. Test plan: N/A
(docs-only); the relevant XCUITest assertion already lives on the
WI-13 branch.

---

## 8. Gi (Skin types / UV-index data)

**Verified.** Walked the Fitzpatrick picker surface:
`FitzpatrickSkinType.pickerDescription` is unchanged on `main`,
`SkinTypeOnboardingView` still presents six rows with behavior-first
copy and no default selection, and the UV index handling
(`WeatherLocationServices.swift` round-coordinate path,
`legacyCachedUVSnapshotStorage` cleanup) is untouched by either
merged commit.

- ✅ Expert approved (skin-types + UV-index lens): no drift. WI-11
  only re-labels the hero empty state; nothing in the skin-type or
  UV pipeline moves.

**Nothing to add.**

---

## 9. Ma-Ti (Test coverage, edge cases, CI green-ness)

**Verified.** Counted tests on `main` HEAD: 67 `@Test` cases (59 in
`BurnTimeCalculatorTests.swift` + 8 in `UVWorkflowTests.swift`,
adding the three WI-11 cases:
`heroEmptyStatePromptForSelectedSkinTypeAsksForLocation`,
`heroEmptyStatePromptWithoutSkinTypePromptsForSkinType`,
`heroEmptyStateConstantsArePartOfAuditCopySurfaces`) plus 34 XCUI
funcs (adding `testHeroEmptyStateAfterOnboardingPromptsForLocation`).
That covers the WI-11 acceptance criteria contract test plan.

- ⚠️ CI green-ness: the assertion in Gaia's backlog row 1
  ("External GitHub-runner CI green on every merged MR per
  `loop-closure-20260520T043000Z.md`") cites a file that is not on
  `main`, not in git history, and not folded into the ledger
  (`git log --all -- .squad/decisions/inbox/loop-closure-20260520T043000Z.md`
  returns empty). The two merges since (`e795c35`, `6a00209`)
  follow the loop.md §5 "merge only on green CI" convention, but
  the convention is the only evidence — no captured artifact.
- ⛔ Code tested and validated (per `loop.md:44` post-WI-16): Goal
  5 now requires a green sign-off on `iris-contrast-qa-checklist.md`
  *and* `iris-launch-readiness-checklist.md`. The contrast file
  does not exist on `main` (Iris's gap above); the launch-readiness
  file exists but its sign-off block is blank. Two of the gates
  loop.md just added are unmet.
- ⚠️ Code tested and validated (local test base): `test.log` ends
  in `** BUILD INTERRUPTED **` at `t = 14.55s` during the
  cover-chain tap sequence, exactly the failure pattern MR !21 is
  designed to fix. On `main` the harden patch is missing, so any
  next-loop concurrent agent run reproduces the abort.
- ⚠️ Code tested and validated (WI-12 contract): no test on `main`
  pins the `Clear saved location` × rationale-ack decoupling. The
  closest existing UI test
  (`testScenario10SavedLocationRestoresAndCanBeCleared`,
  `UVBurnTimerUITests.swift:445`) exercises the clear path but does
  **not** assert that `LocationRationaleCard` stays gone after
  relaunch. The contract is silent on `main` and would not catch a
  regression that reset the ack as a side-effect.

**Proposal — WI-24 (P2, Ma-Ti → Gaia review):** Promote loop CI
artifacts into the ledger so "CI green" is verifiable, not asserted.
Acceptance: every merged MR's CI run URL (or a transcript) is
recorded in the loop-closure note created by WI-19; the next
backlog can cite a path instead of a memory. Files:
`.squad/decisions/inbox/loop-closure-20260520T0530Z.md` (the loop
closure WI-19 creates; this WI just adds the CI-URL schema). Test
plan: N/A (docs/process). **Dependency:** blocked on WI-19.

(WI-22 already covers the test-infra hardening; WI-18 already
covers the WI-12 pinning test. Not duplicated here.)

---

## Overall loop verdict

**⚠️ 7 gaps surfaced. The loop CANNOT be declared closed as "all
goals green".**

The dominant gap is structural: only 2 of 7 closing MRs landed on
`main` during this loop, and one of the un-landed MRs (WI-15) is the
explicit gating artifact named by the `loop.md` §6 sentence that the
*other* landed MR (WI-16) just added. The loop landed the rule
without landing the artifact the rule requires. This is a
process-discipline finding more than a code finding — the shipped
code on `main` (WI-11 + WI-16) is itself sound, and Wheeler, Gi, and
Argos's monetization-absence lane all have a clean ✅.

The other six gaps are downstream of "ship the in-flight MRs":
WI-12 ADR (Plunder + Gaia), WI-13 + WI-14 spec/copy (Iris + Suchi),
WI-17 ledger fold (Scribe + Gaia), MR !21 test-infra (Kwame +
Ma-Ti). Each has a corresponding new WI below; none is a new
feature.

---

## Aggregated new work items for the next loop

| # | Title | Pri | Owner | Reviewer | Type | Blocks |
|---|-------|-----|-------|----------|------|--------|
| **WI-18** | Land the WI-12 Plunder ADR + pinning test (rebase + merge `squad/wi-12-rationale-ack-clear-coord-adr`) | P1 | Plunder | Gaia | ADR + test | Goal 4 architecture lane |
| **WI-19** | Materialize loop-closure note for **this** loop and a ratified `gaia-model-default-loop.md`; fold both + the still-pending `gaia-backlog-20260520T0430Z.md` and `gaia-location-rationale-persistence.md` into `.squad/decisions.md` (replaces stale WI-17 scope) | P1 | Scribe | Gaia | docs | Decision discipline |
| **WI-20** | Land WI-15 (rebase + merge `squad/wi-15-iris-contrast-qa-checklist`) so `.squad/files/iris-contrast-qa-checklist.md` exists on `main` and Goal 5's gating doc is reachable | P1 | Iris | Ma-Ti | docs | Goal 5 |
| **WI-21** | First *signed* pass of both Iris checklists on a physical OLED iPhone — fill in sign-off blocks for `iris-contrast-qa-checklist.md` and `iris-launch-readiness-checklist.md` | P1 | Iris (execute with a physical-device launch-readiness reviewer; Argos signs the launch-readiness block) | Argos | manual QA + docs | Goal 5 (blocked on WI-20) |
| **WI-22** | Land test-infra harden MR !21 (`squad/harden-disclaimer-cover-tap-loop`) so the cover-chain `{-1,-1}` race fix reaches `main` | P1 | Kwame | Ma-Ti | test infra | Local CI flake |
| **WI-23** | After WI-13 lands, update `suchi-persona-annotations.md` Screen 1 Asha row to name the inline `see About` span (not a generic button) so the safety-via-visibility contract is pinned to the rendered control | P3 | Suchi | Plunder | docs | Goal 3 persona fit (blocked on WI-13/MR !22 landing as part of routine merge of in-flight MRs) |
| **WI-24** | Add captured CI-run URLs / transcripts to the loop-closure note so "CI green" is a path, not an assertion | P2 | Ma-Ti | Gaia | docs/process | Goal 5 evidence trail (blocked on WI-19) |

Also still needing routine merge (no new WI required — Gaia's
existing WI-13 + WI-14 MR !22 covers this scope; flagged here for
the next loop's backlog so the merge isn't forgotten):

- **Merge MR !22** (WI-13 + WI-14): inline `see About` deep-link in
  `DisclaimerCover` + SPF-placement spec correction. Once merged,
  unblocks WI-23.

---

## Goals Checklist (review consensus)

- [☑] **Working app** — `main` HEAD `6a00209` builds and codesigns
      clean (`./build.sh` Debug+Release pass at WI-11/WI-16 merges
      per loop.md §5 contract).
- [☑] **UI/UX approved** — LANE 2 shipped surfaces still match the
      spec at the level Iris signed off in
      `gaia-backlog-20260520T0430Z.md` row 2. *Caveat: the L1
      inline-link drift (WI-13) remains until MR !22 lands, but
      that drift was already known and tracked before review and
      does not regress any prior approval.*
- [☑] **User scenarios captured** — README scenarios 1–10
      unchanged on `main`; WI-11's hero copy correction matches
      persona Screen 2 expectations across all five personas.
      *Caveat: the persona-overlay docs touch (WI-23) is contingent
      on WI-13 landing.*
- [☐] **Expert approved** — Wheeler ✅, Gi ✅, Argos ✅
      (monetization-absence), but **Plunder ⚠** because the WI-12
      ADR ratifying `Clear saved location` × rationale-ack is not
      on `main`. Blocked on WI-18.
- [☐] **Code tested and validated** — fails the `loop.md:44`
      requirement merged this loop:
      `.squad/files/iris-contrast-qa-checklist.md` does not exist on
      `main` (blocked on WI-20), and
      `.squad/files/iris-launch-readiness-checklist.md` exists but
      has no green sign-off recorded (blocked on WI-21). Test-infra
      harden (WI-22) and the WI-12 pinning test (WI-18) are
      secondary blockers on the same goal.

**Next loop opens with 7 new WIs (WI-18..WI-24) plus the routine
merge of MR !22.** When WI-18, WI-20, WI-21, and WI-22 are merged
and signed, Goals 4 and 5 flip from ☐ to ☑ and the loop closes
cleanly.

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
