# Plunder — EU / EEA Pre-Submit Counsel Checklist

> **Status:** Draft (WI-plunder-m4, Loop-11). This checklist is the
> pre-flight gate for EU / EEA / UK App Store submission. Every row must
> be GREEN before tapping the EU submission button. Plunder owns the
> sign-off; the repository owner co-signs. An automated agent cannot
> sign rows that require physical evidence (App Store Connect
> screenshots, EU Representative agreement copies, etc.).
>
> Related artifacts:
> - `.squad/files/privacy-policy.md` — the hosted-URL stub (WI-plunder-m1).
> - `.squad/files/iris-launch-readiness-checklist.md` — the polarized-
>   OLED outdoor-readability gate (shipped artifact).
> - `.squad/decisions/archive/plunder-citation-framework.md` — Plunder's
>   C1–C10 floor + E1–E13 enhancements.

---

## Why this gate exists

UV Burn Timer ships globally including the EU, EEA, and UK. While the
app's data architecture is intentionally minimal (no accounts, no
analytics, no off-device data beyond a rounded coordinate sent to Apple
Weather), the EU submission still requires explicit pre-submission
review of GDPR special-category-data avoidance, MDR borderline-
classification avoidance, EU Representative designation (Art.27),
localized privacy policy hosting, and AppStoreConnect EU-specific
metadata. This file lists the 10 things that must be verified before
the EU submission can proceed.

---

## Checklist (Plunder owns)

### E1 — GDPR special-category data avoidance

- [ ] **Architectural:** the app does not process Art.9 special-category
  data (no health questionnaire, no medication-status toggle, no
  photosensitivity question with persisted answer).
- [ ] **Source proof:** Group CC + GD tests in
  `BurnTimeCalculatorTests.swift` lock the Pattern-B L1 cover wording
  ("photosensitizing medications or sun-sensitive conditions") as
  *informational*, not as a question whose answer is collected.
- [ ] **Plunder sign:** \_\_\_\_\_\_\_ (initials) on \_\_\_\_-\_\_\_\_\_\_-\_\_

### E2 — Medical-device borderline (EU MDR 2017/745) avoidance

- [ ] The app makes no claim to diagnose, prevent, monitor, or treat a
  medical condition. The C1–C10 floor (Plunder citation framework)
  forbids all the surface phrasings that would shift the app into
  Annex VIII Rule 11 software-medical-device territory.
- [ ] `productCopyAvoidsBannedClinicalClaims` test
  (`BurnTimeCalculatorTests.swift`) is green and lists "prevents",
  "burn-free", "medical-grade", "dermatologist-approved" as banned.
- [ ] About / Settings copy is reviewed for borderline phrases per
  EU MDR Manual on Borderline and Classification Issues.
- [ ] **Plunder sign:** \_\_\_\_\_\_\_

### E3 — Hosted Privacy Policy URL (Plunder M1)

- [ ] The Privacy Policy at `.squad/files/privacy-policy.md` is
  published at a stable public URL (e.g., GitHub Pages).
- [ ] The hosted URL is entered in App Store Connect → Privacy
  Policy URL.
- [ ] The hosted content matches the on-device `ProductCopy.aboutPrivacy`
  + `cacheRetentionLine` + `disclaimerStorageLine` substrings (Group EH
  pins this).
- [ ] An EU-language translation (German, French, Spanish, Italian)
  is hosted at sibling URLs if the App Store listing localizes any of
  those locales.
- [ ] **Plunder sign:** \_\_\_\_\_\_\_

### E4 — EU Representative designation (GDPR Art.27)

- [ ] If the app is offered in the EU and the developer is not
  established in the EU, an Art.27 EU Representative is designated
  in writing and the Representative's contact information is
  reachable from the Privacy Policy.
- [ ] If the EU Representative requirement is invoked, the
  Privacy Policy's "Contact" section (§13) is updated to name the
  Representative.
- [ ] **Plunder sign:** \_\_\_\_\_\_\_

### E5 — App Store Connect EU metadata

- [ ] App Privacy nutrition labels are filled in:
  - Data Not Collected (for everything except location).
  - Coarse Location — Data Not Linked to You, Not Used for Tracking,
    Purpose: App Functionality (UV lookup).
- [ ] App Tracking Transparency: no ATT prompt needed (the app does
  not track in the AppTrackingTransparency sense).
- [ ] Age rating: 4+ with no clinical claim.
- [ ] App Description does not exceed any health-claim line; verbs
  like "diagnose", "treat", "prevent" are absent from EU description
  translations.
- [ ] **Plunder sign:** \_\_\_\_\_\_\_

### E6 — Cookies / SDK disclosure (PECR / ePrivacy Directive)

- [ ] No tracking cookies (the app has no web view, no shared
  WebKit storage, no cookies of any kind).
- [ ] No third-party SDKs that would trigger PECR consent — confirmed
  by `appSourcesAvoidProhibitedIntegrations` test which forbids
  Firebase / Crashlytics / Sentry / Mixpanel / Segment / Amplitude /
  GoogleMobileAds.
- [ ] **Plunder sign:** \_\_\_\_\_\_\_

### E7 — Data-export / erasure pathway (GDPR Art.15, Art.17)

- [ ] Privacy Policy §6 names the on-device pathway: Settings →
  Clear stored skin type / Clear saved location + uninstall.
- [ ] No off-device data exists to export or erase; Policy makes
  this explicit.
- [ ] **Plunder sign:** \_\_\_\_\_\_\_

### E8 — Apple Weather attribution (localized)

- [ ] The "Source: Apple Weather" line + "Apple Weather data sources"
  link in About render at AX5 Dynamic Type in every supported EU
  localization.
- [ ] WeatherKit attribution legal URL
  (`https://weatherkit.apple.com/legal-attribution.html`) is reachable
  and Apple-hosted (not localized by us).
- [ ] WI-plunder-m2 source-text adjacency guard (Group EG in
  `BurnTimeCalculatorTests.swift`) is green: every `UVIndexCard` and
  `UVIndexPlaceholderCard` body renders `sourceLine` adjacent to
  `WeatherAttributionView` with no other view between them.
- [ ] **Plunder sign:** \_\_\_\_\_\_\_

### E9 — Apple ID / Sign in with Apple not required

- [ ] The app does not require Apple ID sign-in; no Sign in with Apple
  button is exposed. Per Apple Guideline 4.8 (passthrough of
  third-party identity) this is moot; documented here for
  completeness.
- [ ] **Plunder sign:** \_\_\_\_\_\_\_

### E10 — Risk-of-harm review

- [ ] The L1 cover renders before any UV computation per the Pattern-B
  policyVersion gate (Group GD).
- [ ] The L4 About surface (`AboutView`) cites NIH MedlinePlus and
  Apple Weather and discloses the model's wider uncertainty for
  Fitzpatrick IV–VI (Loop-11 WI-wheeler-oo / Group EE5).
- [ ] The "For children, consult a pediatrician" L1 disclaimer is
  always shown in the L1 cover (not gated behind any opt-in).
- [ ] **Plunder sign:** \_\_\_\_\_\_\_

---

## Counsel cadence

- Run this checklist **before every EU TestFlight submission** that
  ships any UI copy or data-flow change.
- Run this checklist **before App Store EU submission** including
  every metadata update.
- Filed sign-offs (with date + initials) are committed back to this
  file under the relevant rows.

## Automation status

This checklist's sign-off blocks **cannot be completed by an automated
agent or CI**. They require:
- a Plunder reviewer with the cited regulatory texts open,
- a repository owner with access to App Store Connect,
- in some cases (E4) an EU Representative agreement copy.

A blank sign-off block is treated as a fail; the next build cycle whose
owner has access to these inputs MUST execute the procedure and commit
the filled-in blocks.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
