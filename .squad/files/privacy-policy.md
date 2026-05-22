# UV Burn Timer — Privacy Policy (App Store submission stub)

> **Status:** Draft stub (WI-plunder-m1, Loop-11). This file is the source
> of truth for the privacy policy text. The App Store submission requires
> the same content to be hosted at a stable public URL (e.g.,
> `https://yashasg.github.io/uv-burn-timer/privacy/`); hosting setup is a
> Plunder + repository-owner action that cannot be performed by an
> automated agent. The substring-pin guard in
> `BurnTimeCalculatorTests.swift` (Group EH) locks the load-bearing
> sentences in this stub against accidental drift.

**Effective date:** {LAUNCH_DATE_TBD}
**Last updated:** 2026-05-21
**App:** UV Burn Timer (iOS)
**Developer:** Yashas Gujjar (sole developer; no shared data controllers)
**Contact:** `{CONTACT_EMAIL_TBD}` (developer; replies within 5 business days)

---

## 1. Summary (plain English)

UV Burn Timer is informational only and not medical advice. The app
does **not** create accounts, does **not** show ads, does **not** include
analytics, crash-reporting SDKs, or any third-party tracking, and does
**not** sell or share any data. The only data that leaves your device is
your rounded approximate location (two decimal places), sent to Apple
Weather so the app can fetch a UV index.

## 2. Data we collect, store, and transmit

| Category | Where it lives | When it leaves the device | Why |
|---|---|---|---|
| Fitzpatrick skin type (I–VI) | UserDefaults on device only | Never | Lets the app remember your selection between launches and feeds the burn-time model. |
| SPF selection (0 / 15 / 30 / 50 / 70+) | UserDefaults on device only | Never | Same as above. |
| Last rounded approximate location (two decimal places) | UserDefaults on device only | Each time you tap Use my location / Recalculate: sent to Apple Weather to fetch the UV index | Required to look up the current UV index. The two-decimal rounding intentionally degrades the precision to ~1.1 km so the coordinate cannot identify a precise address. |
| 10-day UV forecast snapshot (`forecast-snapshot.json`) | App Caches directory on device only | Never | Caches the WeatherKit 10-day/hourly UV forecast so the app can display UV data without a network request on every launch. Cleared automatically when the forecast expires or when you tap Clear saved location. iOS may also evict this file from the Caches directory under storage pressure. |
| Disclaimer-version acknowledgment (the version of the informational disclaimer you acknowledged) | UserDefaults on device only (integer key `disclaimerPolicyVersion`) | Never | So we do not re-prompt you with the informational disclaimer every cold launch. If the disclaimer materially changes, this value bumps and the cover re-fires. |
| UV index values, burn-time estimates | In-memory only | Never | Recomputed on each launch from the inputs above. |

## 3. Data we do NOT collect

- No name, email, phone, account, or any identifier you can sign in with.
- No advertising identifier (IDFA), no Vendor identifier exposure beyond
  iOS's standard sandbox.
- No analytics SDKs (no Firebase, Amplitude, Mixpanel, Segment, etc.).
- No crash-reporting SDKs (no Crashlytics, Sentry, Bugsnag, etc.).
- No third-party trackers, no advertising networks, no attribution SDKs.
- No purchases (no in-app purchase, subscription, or tip-jar — the app is
  a one-time paid download).
- No background location, no continuous location tracking, no health
  data, no contacts, no calendar, no photos, no camera, no microphone.

## 4. Apple Weather (data we transmit)

When you tap **Use my location** or **Recalculate**:

1. iOS may surface a location permission prompt the first time. If you
   grant permission, the app receives a coordinate from CoreLocation.
2. The app rounds the coordinate to two decimal places (~1.1 km
   precision) and sends only the rounded coordinate to Apple Weather via
   Apple's WeatherKit service.
3. Apple Weather returns the current UV index and forecast for that
   rounded coordinate.

Apple Weather data is subject to Apple's own privacy policy and
attribution requirements. UV Burn Timer always displays
**Source: Apple Weather** adjacent to the rendered UV index value, and
the About sheet contains a link to Apple's
[Weather Data & Map Data attribution](https://weatherkit.apple.com/legal-attribution.html).

## 5. Children's privacy

The app is informational only and is not directed at children. It is
intended for adults who are choosing their own sun exposure. It does
not knowingly collect any data from children. The disclaimer copy
("For children, consult a pediatrician.") is intentionally rendered to
discourage child-targeted use.

## 6. Your rights and choices

- **Access:** all data the app stores about you lives on your device.
  Open the app's Settings sheet to view your current skin type, SPF, and
  saved coordinate.
- **Clear:** in the Settings sheet, tap **Clear stored skin type**,
  **Clear stored SPF**, and **Clear saved location** to delete those
  values from your device. The disclaimer-version acknowledgment is
  cleared automatically when you delete the app from your device (iOS
  removes the app's UserDefaults on uninstall).
- **Revoke location:** open iOS Settings → UV Burn Timer → Location and
  set it to **Never** or **While Using the App**.
- **Delete the app:** uninstalling the app removes every value stored
  on this device. There is no off-device deletion request to file
  because the app stores nothing off-device.

## 7. Legal bases (EU / EEA / UK)

For users in the EU, EEA, UK, or other GDPR-equivalent jurisdictions:

| Processing | Legal basis |
|---|---|
| Storing skin type, SPF, last rounded coordinate, disclaimer-version ack | Art.6(1)(b) — performance of the informational service you requested. |
| Sending rounded coordinate to Apple Weather | Art.6(1)(b) — same. |
| (No special-category data processing) | We do not process special-category data (Art.9). Photosensitivity and medication conditions are addressed in the L1 disclaimer as an informational warning; the app does not ask whether you have any condition and stores no answer. |

## 8. Children (COPPA, US)

The app does not knowingly collect personal information from children
under 13. If you believe a child has used the app, the disclaimer +
device-only storage architecture means no off-device data exists to
delete; uninstalling the app removes everything.

## 9. Data retention

- On-device values persist until you clear them in Settings, uninstall
  the app, or reset the device.
- Off-device: nothing is retained off-device by the developer. Apple
  Weather's own retention is governed by Apple's privacy policy.

## 10. International transfers

Coordinates are sent to Apple Weather. Apple may process the request in
its global infrastructure. The developer has no other off-device data
transfers.

## 11. Security

Coordinates leave the device only via Apple's first-party WeatherKit
SDK over HTTPS. The app uses no third-party network endpoints. All
on-device values live in iOS's standard sandbox UserDefaults.

## 12. Changes to this policy

If we materially change this policy, the `disclaimerPolicyVersion`
integer bumps and the in-app disclaimer cover re-fires on the next
cold launch so you can re-read the updated text before using the app
again. The "Last updated" date at the top of this file reflects the
most recent material change.

## 13. Contact

For privacy questions: `{CONTACT_EMAIL_TBD}`.

For App Store / EU representative information: see the App Store
listing's "Developer Information" section.

## 14. References

- iOS app: see `app/Sources/UVBurnTimer/UVBurnTimerApp.swift`
  (`@AppStorage` + `disclaimerPolicyVersionKey`).
- In-app copy: `ProductCopy.aboutPrivacy`, `ProductCopy.cacheRetentionLine`,
  `ProductCopy.disclaimerStorageLine`, `ProductCopy.locationPrivacyLine`.
- Audit lane: `BurnTimeCalculatorTests.swift` Group CC (Loop-11 WI-iris-c),
  Group EH (Loop-11 WI-plunder-m1).

---

## Automation status (WI-21-style — Plunder L01)

This stub carries **two load-bearing placeholders** that an automated
agent or CI runner **cannot fill in**:

- `{LAUNCH_DATE_TBD}` — the App Store launch date that goes in the
  **Effective date** header (§1). The launch date is a business
  decision the repo owner makes at App Store submission time. An
  automated guess (e.g. "today" or a hardcoded future date) would
  publish a policy with the wrong effective date.
- `{CONTACT_EMAIL_TBD}` — the developer privacy-contact email that
  appears in §1 and §13. The address is the repo owner's
  personal/business email; no automated agent has the right to invent
  one. Faking the address would violate GDPR Art.12 transparency
  ("provide a means of contact") and App Store §5.1.1.4 ("provide
  clear and accessible information about your privacy practices").

### Why this gate is manual, not automated

Both placeholders mark **information the repo owner is the only
authoritative source for**. Unlike the in-app `ProductCopy` constants
(which an automated agent can synchronise via the pre-existing
substring guards in `BurnTimeCalculatorTests.swift` Group EH), these
two values come from outside the codebase — the repo owner's App
Store Connect account and email address.

A blank or unfilled placeholder is treated as **submission blocker**:
shipping the App Store URL with literal `{LAUNCH_DATE_TBD}` or
`{CONTACT_EMAIL_TBD}` would violate App Store §5.1.1.4 + GDPR
Art.12 + UK ICO transparency guidance. The hosted policy URL must
be filled before the App Store submission goes to review.

### Owner for the manual fill

- **Plunder** (Legal & Compliance) drafts the replacement values and
  countersigns the final policy.
- **Repo owner** supplies the real launch date + contact email and
  commits the redacted-into-real replacement before App Store
  submission.

### Triggering event

- The first App Store submission. From that point forward, every
  policy update (substantive content change in §1–§13) bumps the
  `disclaimerPolicyVersion` integer, refreshes the **Last updated**
  date, and re-presents the in-app disclaimer cover on cold launch
  (per §12).

### Until both TBDs are filled

The contract test
`test_S6_privacyPolicyTBDsCarryAutomationStatusBlock` (in
`BurnTimeCalculatorTests.swift`) keeps the placeholders visible by
asserting the literal markers remain present alongside this block.
That guard fails CI if a future agent silently replaces them with
fake values; the next build cycle whose owner has the real launch
date + email must fill the placeholders before the policy URL goes
live, then update the test (or remove the contract) in the same MR.

A blank `Automation status` block — or a quietly replaced TBD with
no companion test update — is treated as **fail** by the
goals-checklist sign-off in `loop.md` §6 Goal 5.

---

*This stub satisfies Plunder M1 (Loop-11 carryover). Hosting at a stable
public URL is a follow-on Plunder + repo-owner action — the substring
guards in Group EH below will keep the hosted copy in sync with the
in-app `ProductCopy` constants.*

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
