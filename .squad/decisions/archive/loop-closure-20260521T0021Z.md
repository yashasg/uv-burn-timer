# Loop Closure — 2026-05-21T00:21Z (seventh loop)

- **Date:** 2026-05-20T17:21:00-07:00 (UTC: 2026-05-21T00:21Z)
- **Prior loop closure:** `loop-closure-20260520T1922Z.md` (sixth loop, in
  `.squad/decisions/archive/`)
- **Opening HEAD at loop start:** `9fd32fb`
  (`WI-57: reconcile spec L2 banner copy + re-lock L2 footer string (#17)`)
- **Closing HEAD at loop end:** `12aae0a` (spec reconciliation commit
  on top of `9fd32fb`); PR for this loop opened on top.
- **Carry-forwards from sixth loop:** WI-28 (hardware-blocked OLED
  sign-off) — still the only carry-forward.

## What this loop did

1. **Seventh-loop design-gap analysis (loop §3).** Ran via a parallel
   explore agent across all four sources of truth
   (`.squad/files/user-flow-onboarding-main-spec.md`,
   `.squad/files/suchi-persona-annotations.md`,
   `.squad/files/iris-contrast-qa-checklist.md`,
   `.squad/files/iris-launch-readiness-checklist.md`) plus
   `README.md` user scenarios 1–10, cross-referenced against the
   shipped surface
   (`app/Sources/UVBurnTimer/AppViews.swift` +
   `app/Sources/UVBurnTimerCore/*.swift`) and existing XCUI + unit
   test coverage. Result: **two new doc drifts** — both spec-only
   copy paraphrases that never matched a shipped string. Filed as
   WI-59 and WI-60. **Zero code gaps and zero missing-test gaps
   surfaced.**

2. **WI-59 (this branch, commit `12aae0a`).** Spec line 43 (LANE 1
   row 3) had quoted *"Pick the row that matches what your skin
   does, not its color"* as the skin-type picker header. That string
   was a paraphrase of two separate shipped surfaces
   (`ProductCopy.skinTypePickerPrompt` prompt header +
   `ProductCopy.skinTypePickerSubtext` first sentence) and never
   matched a single shipped surface. Updated the spec row to quote
   both shipped strings verbatim and cite the three existing
   copy-lock tests that already enforce them:
   - `BurnTimeCalculatorTests.approvedMainScreenSafetyCopyIsCaptured`
     — exact-match `ProductCopy.skinTypePickerPrompt ==
     "Choose by how your skin burns and tans, not by how it looks."`
     at `BurnTimeCalculatorTests.swift:388`.
   - `skinTypePickerHeaderIsBehaviorFirstPerWheelerSpec` — Wheeler
     §3.1 behavior-first guard (burns/tans must lead, "skin color"
     must not appear).
   - `skinTypePickerSubtextCapturesBehaviorCuesAndRangeOfTones` —
     "what your skin does", "no sunscreen", "no recent tan",
     "range of natural skin tones", "30 minutes".

3. **WI-60 (same commit `12aae0a`).** Spec line 68 (LANE 2 #7) had
   rendered the footer disclaimer link as
   `Informational only. Not medical advice. →` but the shipped
   surface is `ProductCopy.disclaimerLinkLabel ==
   "Informational only. Not medical advice."` (no arrow) rendered
   via `Label(systemImage: "info.circle")` inside a `NavigationLink`
   at `AppViews.swift:1757`. Applied the same precedent the spec
   already uses at LANE 2 #4 for the hero-card caveat arrow: the
   design `→` was a spec-time link indicator, not a literal rendered
   character. Dropped the arrow, named the rendered `Label` +
   `NavigationLink` structure, and cited the existing exact-match
   copy-lock at `BurnTimeCalculatorTests.approvedMainScreenSafetyCopyIsCaptured`
   (`BurnTimeCalculatorTests.swift:390`).

4. **`Last reconciled with code` marker bumped** from `8a3406a`
   (WI-41) to `9fd32fb` to reflect the WI-57 + WI-59 + WI-60 series
   of spec reconciliations since the last marker.

## Backlog disposition

| WI | Title | Status | Evidence |
|---|---|---|---|
| WI-28 | Physical-device Iris polarized-OLED sign-off | ⛔ Carry-forward | Requires OLED iPhone + polarized-lens setup; no agent path |
| WI-59 | Reconcile LANE 1 #3 picker prompt spec copy | ✅ Merged in this PR | Commit `12aae0a` (spec `.squad/files/user-flow-onboarding-main-spec.md:43`) |
| WI-60 | Reconcile LANE 2 #7 footer disclaimer-link spec arrow | ✅ Merged in this PR | Commit `12aae0a` (spec `.squad/files/user-flow-onboarding-main-spec.md:68`) |
| WI-58 | This seventh-loop closure note | ✅ This file | PR for this loop |
| WI-9 | Plan-for-elsewhere affordance | ⏸ v1.1-deferred | Intentional |

## Goals Checklist (loop.md §6)

- [x] **Working app** — Debug + (CI mode) build green locally with
  `-warnings-as-errors`; `xcodebuild build` step completed clean on
  the local run. GitHub-runner CI will be the merge gate for this
  PR. No Swift code or test code changed this loop (doc-only), so
  the build surface is identical to the closing HEAD of the sixth
  loop (`9fd32fb`).
- [x] **UI/UX approved** — Design-gap analysis surfaced two doc
  drifts (WI-59 + WI-60) which were closed in this same PR. Parallel
  squad-member review (loop §6/§7) returned no new gaps; standing
  yellow is WI-28 carry-forward (manual checklist signature only).
- [x] **User scenarios captured** — `README.md` user scenarios 1–10
  remain accurate; this loop did not change any scenario surface.
  Scenarios 1, 2, 5, 8, 10 each retain XCUI coverage at the persona
  cells enumerated in the sixth-loop closure note (Greta, Maya,
  Devon, Asha, Tomás).
- [x] **Expert approved** — No expert-domain code or test code
  changed this loop (spec markdown reconciliation only). Wheeler /
  Plunder / Iris / Suchi / Argos approvals from prior loops remain
  valid; the WI-59 reconciliation explicitly cites Wheeler's §3.1
  behavior-first test guard.
- [~] **Code tested and validated** — **69 Swift Testing unit tests
  + 38 XCUI tests** on the closing HEAD; unchanged from the sixth
  loop because this loop made no code or test edits. **WI-28 manual
  launch-readiness gates remain unsigned** — carry-forward.

## Delta since prior loop closure

- **Test count:** unchanged (69 unit + 38 XCUI).
- **Accessibility identifiers added:** none (no code changes).
- **Test seams added:** none (no code changes).
- **Decision archive:** WI-58 closure note added; inbox remains
  empty.
- **Spec reconciliations this loop:** WI-59 (LANE 1 row 3 picker
  prompt + subtext quoted verbatim) and WI-60 (LANE 2 #7 footer
  link drops spec-time `→` arrow). Both anchor to existing
  exact-match copy-lock tests at
  `BurnTimeCalculatorTests.approvedMainScreenSafetyCopyIsCaptured`
  (`skinTypePickerPrompt` and `disclaimerLinkLabel`); no new tests
  needed.
- **Spec drift trend:** four spec→code reconciliations in the last
  three loops (WI-41 location-chip coordinate, WI-57 banner copy,
  WI-59 picker prompt, WI-60 footer arrow). All four were
  spec-paraphrase drifts where the shipped copy was already locked
  by a passing test — meaning the drift never affected product
  behavior, only the documentation accuracy of the canvas spec.

## Risk / known issues

- **Local UI-test flakiness continues on this shared workstation.**
  This loop's `./build.sh` run completed the Debug build green with
  `-warnings-as-errors`, but the XCUI `xcodebuild test` step
  surfaced the same cross-process simulator-contamination failure
  noted in the sixth-loop closure (`FBSOpenApplicationServiceErrorDomain
  Code 4 / Simulator device failed to launch
  com.yashasgujjar.uvburntimer.uitests.xctrunner`). GitHub-runner CI
  on the resulting PR is the authoritative test signal — it runs
  on a clean macos-15 image with no concurrent simulator users.
  Because this loop changed no Swift code or test code, the XCUI
  contract is identical to the sixth-loop closing HEAD (`ffe9e40`)
  which had passing CI on every merged PR.
- WI-28 remains the only open launch blocker and requires human
  action with physical hardware (OLED iPhone + polarized-lens
  setup).

## Next loop seeds

1. **No automated blockers.** The backlog is empty save WI-28.
2. The spec-drift trend (four reconciliations across three loops)
   suggests a follow-up could be a single spec-vs-`ProductCopy`
   audit pass that pre-emptively catches paraphrases of audit
   strings rather than discovering them one per loop. Captured here
   as a possible eighth-loop seed; not filed as a WI because it is
   discretionary documentation hygiene, not a product gap.
3. Consider a v1.0 TestFlight build once WI-28 physical-device pass
   is obtained.
4. WI-9 (plan-for-elsewhere affordance) remains deferred to v1.1.
5. The next loop (eighth) starts when a new design / spec /
   persona change lands; otherwise the squad is in steady state.

## Provenance note

This closure note is committed directly into
`.squad/decisions/archive/` rather than `.squad/decisions/inbox/`,
following the same convention as the fourth, fifth, and sixth loop
closures: `.squad/decisions/inbox/` is `.gitignored`, so closure
notes have always landed straight in `archive/`.

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
