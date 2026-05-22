import XCTest

@testable import UVBurnTimerCore

/// WI-loop31-2 — Location Rationale Onboarding.
///
/// LANE 1 #4 of `.squad/files/user-flow-onboarding-main-spec.md` requires a
/// privacy-rationale sheet that explains why the app needs location BEFORE
/// the OS-level `CLLocationManager.requestWhenInUseAuthorization()` prompt
/// fires. This test file pins the Core-layer contracts that back that sheet:
///
///   1. `LocationPromptGate.acknowledgeRationale()` — idempotent setter so
///      the SwiftUI view layer can record acknowledgement without abusing
///      the dual-purpose `allowSystemPromptOrAcknowledgeRationale()`.
///   2. `UserPreferenceStorage.restoredLocationPromptGate(from:)` — restores
///      the gate from UserDefaults so a force-quit between rationale and the
///      OS prompt does not re-present the sheet.
///   3. `UserPreferenceStorage.persist(locationPromptGate:to:)` — writes the
///      acknowledgement flag through to UserDefaults under the existing
///      `locationRationaleAcknowledgedKey` (so the GDPR Art.17 erasure
///      path in `clearStoredPreferences` keeps working unchanged).
///   4. `ProductCopy.locationRationale*` — four strings (title, body, CTA,
///      VoiceOver hint) are non-empty, spec-aligned (privacy-first
///      language consistent with `locationPrivacyLine` and the privacy
///      policy stance: rounded coordinates → Apple Weather, no off-device
///      transmission), and enrolled in `auditCopySurfaces`.
final class LocationRationaleOnboardingTests: XCTestCase {

    // MARK: - LocationPromptGate.acknowledgeRationale()

    func test_acknowledgeRationale_flipsFlagFromFalseToTrue() {
        var gate = LocationPromptGate(hasAcknowledgedRationale: false)
        gate.acknowledgeRationale()
        XCTAssertTrue(gate.hasAcknowledgedRationale)
    }

    func test_acknowledgeRationale_isIdempotent() {
        var gate = LocationPromptGate(hasAcknowledgedRationale: true)
        gate.acknowledgeRationale()
        gate.acknowledgeRationale()
        XCTAssertTrue(gate.hasAcknowledgedRationale)
    }

    func test_allowSystemPromptOrAcknowledgeRationale_afterExplicitAck_allowsImmediately() {
        // Pre-condition: when the rationale sheet has acknowledged the gate
        // ahead of any "Use my location" tap, the next call to
        // `allowSystemPromptOrAcknowledgeRationale()` must return `true`
        // so the call site dispatches the OS prompt without a second
        // gating cycle.
        var gate = LocationPromptGate(hasAcknowledgedRationale: false)
        gate.acknowledgeRationale()
        XCTAssertTrue(gate.allowSystemPromptOrAcknowledgeRationale())
    }

    // MARK: - UserPreferenceStorage persistence

    func test_restoredLocationPromptGate_emptyDefaults_returnsUnacknowledged() {
        let defaults = ephemeralDefaults()
        let gate = UserPreferenceStorage.restoredLocationPromptGate(from: defaults)
        XCTAssertFalse(gate.hasAcknowledgedRationale)
    }

    func test_restoredLocationPromptGate_acknowledgedKeySet_returnsAcknowledged() {
        let defaults = ephemeralDefaults()
        defaults.set(true, forKey: UserPreferenceStorage.locationRationaleAcknowledgedKey)
        let gate = UserPreferenceStorage.restoredLocationPromptGate(from: defaults)
        XCTAssertTrue(gate.hasAcknowledgedRationale)
    }

    func test_persistLocationPromptGate_acknowledged_writesKey() {
        let defaults = ephemeralDefaults()
        let gate = LocationPromptGate(hasAcknowledgedRationale: true)
        UserPreferenceStorage.persist(locationPromptGate: gate, to: defaults)
        XCTAssertTrue(defaults.bool(forKey: UserPreferenceStorage.locationRationaleAcknowledgedKey))
    }

    func test_persistLocationPromptGate_unacknowledged_clearsKey() {
        let defaults = ephemeralDefaults()
        defaults.set(true, forKey: UserPreferenceStorage.locationRationaleAcknowledgedKey)
        let gate = LocationPromptGate(hasAcknowledgedRationale: false)
        UserPreferenceStorage.persist(locationPromptGate: gate, to: defaults)
        // Either the key is removed or the stored value is false — both
        // satisfy the "unacked → no false-positive on restore" contract.
        XCTAssertFalse(defaults.bool(forKey: UserPreferenceStorage.locationRationaleAcknowledgedKey))
    }

    func test_persistThenRestoreRoundTrip_preservesAcknowledged() {
        let defaults = ephemeralDefaults()
        var gate = LocationPromptGate(hasAcknowledgedRationale: false)
        gate.acknowledgeRationale()
        UserPreferenceStorage.persist(locationPromptGate: gate, to: defaults)
        let restored = UserPreferenceStorage.restoredLocationPromptGate(from: defaults)
        XCTAssertEqual(gate, restored)
    }

    func test_clearStoredPreferences_alsoClearsLocationRationaleGate() {
        // GDPR Art.17 erasure-path completeness — the existing centralised
        // erasure entry point must keep clearing this key so a Settings →
        // "Clear everything" action genuinely resets onboarding state.
        let defaults = ephemeralDefaults()
        defaults.set(true, forKey: UserPreferenceStorage.locationRationaleAcknowledgedKey)
        UserPreferenceStorage.clearStoredPreferences(from: defaults)
        let restored = UserPreferenceStorage.restoredLocationPromptGate(from: defaults)
        XCTAssertFalse(restored.hasAcknowledgedRationale)
    }

    // MARK: - Gating semantics (no re-present after ack)

    func test_gatingSemantics_afterAcknowledgement_doesNotRepresent() {
        // Simulates two cold launches with the same UserDefaults backing.
        let defaults = ephemeralDefaults()

        // Cold launch 1 — first time. Rationale sheet must be presented.
        var firstGate = UserPreferenceStorage.restoredLocationPromptGate(from: defaults)
        XCTAssertFalse(firstGate.hasAcknowledgedRationale, "First launch must require rationale.")

        // User taps the sheet's Continue button.
        firstGate.acknowledgeRationale()
        UserPreferenceStorage.persist(locationPromptGate: firstGate, to: defaults)

        // Cold launch 2 — same device. Rationale must NOT be re-presented.
        let secondGate = UserPreferenceStorage.restoredLocationPromptGate(from: defaults)
        XCTAssertTrue(secondGate.hasAcknowledgedRationale, "Sheet must be suppressed after acknowledgement.")
    }

    // MARK: - ProductCopy strings

    func test_locationRationaleCopy_allFourStringsAreNonEmpty() {
        XCTAssertFalse(ProductCopy.locationRationaleTitle.isEmpty)
        XCTAssertFalse(ProductCopy.locationRationaleBody.isEmpty)
        XCTAssertFalse(ProductCopy.locationRationaleContinueLabel.isEmpty)
        XCTAssertFalse(ProductCopy.locationRationaleAccessibilityHint.isEmpty)
    }

    func test_locationRationaleBody_namesAppleWeatherAndPrivacyFloor() {
        // Spec-alignment: the body MUST tell the user (a) we send a rounded
        // coordinate to Apple Weather for UV data, and (b) we do not
        // transmit a place name or maintain accounts. Mirrors
        // `locationPrivacyLine` and the privacy policy stance.
        let body = ProductCopy.locationRationaleBody
        XCTAssertTrue(body.contains("Apple Weather"), "Body must name the WeatherKit service.")
        XCTAssertTrue(
            body.localizedCaseInsensitiveContains("rounded"),
            "Body must disclose coordinate rounding for privacy."
        )
    }

    func test_locationRationaleContinueLabel_isShortActionVerb() {
        // HIG-aligned: continue button must be a short imperative ≤ 24
        // chars so it fits a single line on iPhone SE under AX5.
        let label = ProductCopy.locationRationaleContinueLabel
        XCTAssertLessThanOrEqual(label.count, 24, "Continue label must stay short for AX5 reflow.")
    }

    func test_locationRationaleStrings_enrolledInAuditCopySurfaces() {
        let surfaces = ProductCopy.auditCopySurfaces
        XCTAssertTrue(surfaces.contains(ProductCopy.locationRationaleTitle))
        XCTAssertTrue(surfaces.contains(ProductCopy.locationRationaleBody))
        XCTAssertTrue(surfaces.contains(ProductCopy.locationRationaleContinueLabel))
        XCTAssertTrue(surfaces.contains(ProductCopy.locationRationaleAccessibilityHint))
    }

    // MARK: - Helpers

    private func ephemeralDefaults() -> UserDefaults {
        let suite = "LocationRationaleOnboardingTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }
}
