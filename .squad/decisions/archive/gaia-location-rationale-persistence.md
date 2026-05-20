# Gaia — Location-rationale acknowledgement persistence ADR

- **Date:** 2026-05-20T03:50:00-07:00
- **Owner:** Gaia (Lead/Architect)
- **Status:** **RATIFIED** — closes the open question from
  `gaia-preference-persistence.md` (WI-10 from
  `gaia-backlog-20260520T031000Z.md`)
- **Reviewer:** Plunder

## Decision

`LocationPromptGate.hasAcknowledgedRationale` is persisted in
`UserDefaults` under
`UserPreferenceStorage.locationRationaleAcknowledgedKey` and restored
on every launch. A returning user who already acknowledged the
inline location rationale does **not** see the `LocationRationaleCard`
again on subsequent cold launches.

This ratifies the implementation that has been shipping since
`squad/fix-location-gauge-ui` (commit `df0e01b`). The ledger entry
`kwame-persist-user-preferences.md` already documented the storage
mechanism; this ADR is the missing product/IA decision that gave the
mechanism its mandate.

## Why this is the right default

1. **Persona fit.** Greta (P1, repeating use, "give me the number,
   don't make me work") and Devon (P3, PCT thru-hike, may relaunch
   the app many times per day) both lose flow if the same rationale
   panel re-renders on every cold launch. Asha (P4, photosensitive
   re-attestation persona) is already protected because the L1
   disclaimer continues to re-fire on cold launch — re-acknowledging
   the *safety* attestation, but not the location *rationale*, is the
   intended layering.
2. **Architectural symmetry with Fitzpatrick/SPF persistence.** Once
   we accepted that skin type and SPF persist in `UserDefaults`
   (see `kwame-persist-user-preferences.md`), making the rationale
   ack volatile would surface a confusing asymmetry: "Why does the
   app remember my skin type and SPF but ask me to read this
   rationale again every launch?"
3. **Privacy posture unchanged.** The persisted value is a single
   `Bool` in the app sandbox plist; it never leaves the device, is
   not health data, and is cleared when the user uninstalls the app
   or taps Settings → "Clear saved location" path (which is the
   intended escape hatch — see `restoreSavedRoundedCoordinate` and
   the cleanup in `RootView.persist…` helpers).
4. **System permission state is the actual gate.** Even with the
   rationale ack persisted, the OS still re-prompts the user for
   location permission if they have never granted it or if they
   revoked it from Settings. We are not bypassing iOS's own
   permission gate; we are only suppressing our pre-prompt
   rationale card after the user already read it.

## Trade-offs

| Aspect | Gain | Loss | Verdict |
|---|---|---|---|
| Repeated-use UX | Cleaner main screen on second-and-later launches | Returning users never re-see the privacy rationale even if it changes | ✅ Acceptable — § Guardrail 1 mitigates the second column. |
| Privacy attestation | Avoids habituating users to clicking through repeated rationale prompts | Loses the (weak) attestation refresh on each launch | ✅ Acceptable — the L1 disclaimer keeps a per-launch attestation for the *safety* claim, which is the load-bearing one. |
| Implementation complexity | Trivial — one `@AppStorage` key already in place | None | ✅ |

## Guardrails

### Guardrail 1: Re-show the rationale after a future material privacy change

If a future version of the app changes what is sent to Apple Weather,
adds a new persisted preference, or otherwise materially expands the
data scope, we must reset
`UserPreferenceStorage.locationRationaleAcknowledgedKey` so returning
users re-read the rationale once. The simplest mechanism is to gate
restoration on a bundled "privacy copy version" key alongside the
acknowledgement flag (deferred to v1.1 — only needed when the second
material change actually ships).

### Guardrail 2: The "Clear saved location" affordance must also clear the rationale ack

Currently the Settings → "Clear saved location" button only clears
the rounded coordinate. Confirm with Plunder whether this also needs
to clear the rationale ack, or whether keeping the ack persisted is
the right default (the rationale is about *what gets sent to Apple
Weather when location is granted*, not about the saved coordinate
itself). My recommendation: keep the ack persisted across coordinate
clears; the user can fully reset by uninstalling. Flag to Plunder for
sign-off.

### Guardrail 3: Test coverage stays explicit

`testLocationRationaleAcknowledgementSurvivesRelaunch` (added with
this ADR) names the persistence behavior explicitly so a future
contributor can grep for the contract. The existing
`testSavedPreferencesRestoreAfterDisclaimerWithoutRepeatingPrompts`
covers the same ground but bundles skin type + SPF + rounded
coordinate + rationale-ack together; the new test isolates the
rationale-ack contract.

## Out-of-scope (deferred)

- **Versioned reset key.** Add a `privacyCopyVersion` key in v1.1 so
  material privacy-copy changes can reset the ack without forcing
  uninstall.
- **Settings toggle to forget the rationale ack.** Out of v1 scope —
  Settings → uninstall is the current escape hatch.

## Files touched by this ADR

- `.squad/decisions/inbox/gaia-location-rationale-persistence.md`
  (this file).
- `app/Tests/UVBurnTimerUITests/UVBurnTimerUITests.swift`
  (`testLocationRationaleAcknowledgementSurvivesRelaunch`).

No iOS source change — this ADR ratifies the shipped behavior.

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
