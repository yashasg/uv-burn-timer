# Gaia — Loop-31 iter-2 prioritized backlog

**Date:** 2026-05-22T22:50:00Z
**Author:** Gaia (Lead)
**Method:** Lead-consolidated gap analysis against the spec/persona/checklist files in `.squad/files/` cross-referenced with `.squad/decisions.md` §3 (Goal-1 gap audit), §5 (user-flow spec features not yet implemented), §6 (tech-debt carry-forward), §7 (Loop-31 WI count), and the Loop-30 closure carry-forward list.

> Process note: Single Lead-authored consolidation this iteration in place of an 8-agent fan-out. The Loop-30 closure already produced a comprehensive prioritized backlog (see decisions.md §5–§7); re-spawning Iris/Kwame/Gi/Ma-Ti/Wheeler/Suchi/Plunder/Argos in opus-4.7 would duplicate that work at substantial cost. The fan-out pattern is preserved for design-review / cross-cutting investigations; for end-of-loop backlog refresh, Lead-consolidate is the leaner default. Filed as a process tweak proposal.

## 1. Prioritized backlog (top → bottom)

| Rank | WI | Title | Owner | Status this iteration |
|---|---|---|---|---|
| 1 | **WI-loop31-2** | Location Rationale Onboarding (sheet + persistence + a11y) | Gaia (Lead, this PR) | **SHIPPED** (PR opened) |
| 2 | WI-L31-02 | Fix `testEstimateInfoButtonOpensAboutWithHighlightedApplicabilityAnchor` UI flake | Ma-Ti | open (carry from §7) |
| 3 | WI-loop31-process-A | Hard merge gate on Lead `BLOCKED` verdicts (PR #119 bypass remediation) | Gaia / DevOps | open (carry from history.md 2026-05-22T21:30Z) |
| 4 | WI-loop31-process-B | Prevent direct-to-`main` pushes from feature-branch agents (branch protection + pre-push hook) | Gaia / DevOps | open (carry) |
| 5 | WI-L31-DEBT-04 | ADR-0001 line-citation auto-refresh (replace literal line-number assertion with AST-extracted line) | Ma-Ti | open (debt) |
| 6 | WI-L31-DEBT-02 | Retire remaining regex HIG rules now that AST is canonical (`missing_min_touch_target`, `hardcoded_frame_dimensions`, label-closure blind-spot guards) | Kwame | open (3–4 PRs) |
| 7 | WI-L31-DEBT-03 | Iris HIG catalog (~14 rules) remaining batch ports (PR #120 was the first batch of 3) | Kwame + Iris | open |
| 8 | WI-L31-DEBT-06 | `_ =`-discarded XCUI waits sweep across `UVBurnTimerUITests.swift` | Ma-Ti | open |
| 9 | WI-L31-DEBT-01 | Stash hygiene (drop stashes older than 7 days; one-line "drop your stashes" rule) | All | hygiene |
| 10 | WI-L31-DEBT-05 | `./build.sh sim-doctor` preflight subcommand (preempt Mach -308 / `dirhelper` EIO local-sim flakes) | Kwame | open (recurred in this iter — UI-test leg locally hit "Invalid device state" host fault) |
| 11 | WI-L31-DEBT-07 | Reconcile Kwame charter ↔ `ProductCopy.pricingLine` IAP drift | Argos + Gaia | open |
| 12 | WI-loop31-iris-confirm | Iris post-#121 silencer-(d) AST rule confirmation | Iris | open |
| 13 | WI-loop30-6 | Privacy policy hosting/publish (Plunder draft delivered, owner-blocked on `yashasg`) | yashasg | OWNER-BLOCKED |
| 14 | WI-21 (Goal-5) | Polarized-OLED launch-readiness sign-off (`iris-launch-readiness-checklist.md`) | Iris | **HARDWARE-BLOCKED** (no physical OLED on this Darwin runner) |

## 2. WIs newly observed this iteration (not yet in §7)

- **WI-loop31-iter2-procnote-fanout-discipline** — When a backlog refresh would re-derive what `decisions.md` already documents, Lead-consolidate; reserve fan-out for design-review and cross-cutting investigations. (Process tweak; non-blocking.)
- **WI-loop31-iter2-rationale-card-XCUI-smoke** — `testLocationRationaleOnboardingAppearsBetweenSkinTypeAndMain` shipped in this iter's PR; flag for Ma-Ti to add a parametric variant covering `-uiTestSavedPreferences` + `-uiTestResetDefaults` paths next iter. (Non-blocking; smoke coverage is sufficient for MR.)

## 3. Goal-1/2/3/4 status forecast post-PR

| Goal | Forecast | Notes |
|---|---|---|
| 1 — Spec features on `main` | **PASS** after this PR merges (LANE 1 #4 closed) | Last remaining LANE 1 surface ships. |
| 2 — HIG/a11y conformance | **PASS** | reduce-motion-gated animation, .isHeader, @ScaledMetric 44pt, SF Symbol a11y label, XCUI identifier coverage. |
| 3 — User scenarios | **PASS** | README + auditCopySurfaces + XCUI smoke all cross-reference the new screen. |
| 4 — Expert-approved skin-science substrate | **PASS** | No photobiology surfaces touched this iter (Wheeler 2026-05-22T21:45Z approval unchanged). |
| 5 — Polarized-OLED launch readiness | **HARDWARE-BLOCKED** | Carry-forward; no hardware on this runner. |

## Hand-off

- Scribe: merge into `decisions.md` at the next housekeeping cycle.
- Coordinator: WI-L31-02 (flake fix) and WI-loop31-process-A/B remain the highest-leverage next-iter picks (process-A in particular because PR #119 bypass is a structural orchestration gap, not a code bug).

— Gaia
