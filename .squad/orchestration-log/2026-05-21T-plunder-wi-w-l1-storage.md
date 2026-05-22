# Plunder Ratification — WI-w L1 Storage-Disclosure Sentence

**Date:** 2026-05-21
**Author:** Plunder (Legal & Compliance) — agent-mediated; coordinator drove
**Subject:** `ProductCopy.disclaimerStorageLine` (new constant) + DisclaimerCover render + test contract
**Status:** ✅ Internal-Plunder gate CLOSED on ship. ⏸ External counsel E13 gate stays open as confirm-before-App-Store-submit.

---

## §1 — Wording (committed verbatim)

```
Your skin type and SPF are saved on this device only so the app can remember them between launches; the app never sends them off-device. You can clear them anytime in Settings.
```

**Word count:** 32 (≤40 floor). **Sentences:** 2.

### Key deltas Plunder required vs. coordinator's first draft

- **Added:** purpose clause "so the app can remember them between launches" — required by GDPR Art.9(2)(a) consent specificity (EDPB Guidelines 05/2020 §3.2; Art.29 WP259/rev.01). Special-category data consent must name the purpose at the moment of acknowledgment.
- **Retained:** active-voice "saved on this device only" (matches K-8 "Clear saved location" button verb; "saved" reads cleaner than "stored" at first-touch).
- **Retained:** "never sends them off-device" complement (plain-language sibling of `aboutPrivacy`'s "never transmitted off-device").
- **Retained:** Art.17 erasure visibility via "clear them anytime in Settings" (matches the two destructive buttons users will see seconds later: "Clear saved location" + "Clear stored skin type").
- **Excluded:** location (governed by the iOS prompt + Settings, not by L1 acknowledgment, since at L1 time the location prompt has not yet fired).

---

## §2 — Architectural placement (APPROVED)

1. **New constant** `ProductCopy.disclaimerStorageLine` — NOT appended to `disclaimerBody`.
   - **Audit-lane separation:** `disclaimerBody` carries the FDA SaMD / EU MDR Article 2(1) "intended purpose" floor. Mixing GDPR storage-disclosure prose into the FDA-pre-approved substring set would (a) break `requiredSafetyDisclaimerCopyIsCaptured`, (b) muddy the audit boundary, (c) raise the bar for future targeted edits to either lane.
2. **Render** as `Text(ProductCopy.disclaimerStorageLine).font(.body).accessibilityIdentifier("DisclaimerStorageLine")` immediately after `Text(ProductCopy.disclaimerBody)` in `DisclaimerCover` (`AppViews.swift:1135`), placed **before** the see-About `Button` so consent-relevant prose stays grouped with `disclaimerBody`.
3. **Add `disclaimerStorageLine` to `ProductCopy.auditCopySurfaces`** so the banned-clinical-claim guard, monetization-drift guard, and any future audit guards apply automatically.

---

## §3 — Required test contract

A new `@Test` in `BurnTimeCalculatorTests.swift` MUST assert:

### 3.1 Exact-match identity (case-sensitive)
```swift
#expect(ProductCopy.disclaimerStorageLine ==
    "Your skin type and SPF are saved on this device only so the app can remember them between launches; the app never sends them off-device. You can clear them anytime in Settings.")
```

### 3.2 Seven derived substring pins (case-insensitive)
- `"skin type"` — names persisted data #1
- `"spf"` — names persisted data #2
- `"this device only"` — scope (Art.5(1)(f) integrity)
- `"remember"` — purpose (Art.9(2)(a) specificity)
- `"off-device"` — never-transmitted complement
- `"settings"` — erasure path visibility (Art.17)
- `"clear"` — matches K-8 button verb

### 3.3 Audit-surface membership
```swift
#expect(ProductCopy.auditCopySurfaces.contains(ProductCopy.disclaimerStorageLine))
```

### 3.4 UI-render assertion
Either (a) XCUI assertion that `DisclaimerStorageLine` identifier is visible on the cover (preferred — survives across iOS 17/18+), or (b) source-text guard that `Text(ProductCopy.disclaimerStorageLine)` + `accessibilityIdentifier("DisclaimerStorageLine")` appear in `AppViews.swift`. Coordinator chose (a) via a new XCUI smoke test on `DisclaimerCover`.

### 3.5 Negative assertions (lane-separation guards)
```swift
#expect(!ProductCopy.disclaimerBody.contains(ProductCopy.disclaimerStorageLine))
#expect(!ProductCopy.disclaimerStorageLine.localizedCaseInsensitiveContains("medical advice"))
```

---

## §4 — E13 status post-shipping

| Gate | Status | Authority |
|---|---|---|
| §4.1(a) See stored value in ≤1 tap from result surface | ✅ K-3/K-4 chip on result surface | Plunder |
| §4.1(b) Change stored value in ≤1 tap | ✅ Chip tap reopens picker | Plunder |
| §4.1(c) Delete stored value from Settings | ✅ K-8 "Clear stored skin type" button | Plunder |
| §4.1(d) **Know the value is stored** (Art.13 fair-processing) | ✅ NEW — `disclaimerStorageLine` at L1 + existing `aboutPrivacy` + `cacheRetentionLine` | Plunder |
| **P-3 (L1 sentence)** | ✅ **CLOSED** | Plunder (this ratification) |
| **E13 (EU counsel confirm "explicit consent" reading)** | ⏸ **CARRY-FORWARD** | Yashas / EU counsel — confirm-before-App-Store-submit |
| **E14 (DPIA scope)** | ⏸ unchanged | Yashas / EU counsel |
| **E15 (FTC HBNR 2024)** | ⏸ unchanged | Yashas / US counsel |

---

## §5 — Net signal to the team

- ✅ K-3/K-4/K-8 may continue on the v1 release branch with this sentence merged.
- ⏸ Before App Store submit (any market), Yashas books EU counsel time on E13/E14, US counsel on E15. Known-and-tracked carry-forward, not a new risk.
- 🚫 Do NOT ship K-3/K-4/K-8 to any production-equivalent surface (TestFlight external, regional pre-release, etc.) without this `disclaimerStorageLine` constant + test contract in place. The L1 sentence is the consent-specificity surface; shipping K-3/K-4/K-8 without it leaves Art.9(2)(a) open in spirit.

---

## §6 — Commit-trailer contract

Commits landing this work must carry:

```
Plunder ratification: see .squad/orchestration-log/2026-05-21T-plunder-wi-w-l1-storage.md
```

— plus the standard `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>` trailer.
