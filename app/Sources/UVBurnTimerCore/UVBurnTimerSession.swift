import Foundation

public struct UVBurnTimerSession: Equatable, Sendable {
    public var selectedSkinType: FitzpatrickSkinType?
    public var selectedSPF: SPFLevel
    public var acknowledgedDisclaimer: Bool

    public init(
        selectedSkinType: FitzpatrickSkinType? = nil,
        selectedSPF: SPFLevel = .spf30,
        acknowledgedDisclaimer: Bool = false
    ) {
        self.selectedSkinType = selectedSkinType
        self.selectedSPF = selectedSPF
        self.acknowledgedDisclaimer = acknowledgedDisclaimer
    }

    public mutating func requireDisclaimerReattestation() {
        acknowledgedDisclaimer = false
    }
}

public struct SkinTypeOnboardingDraft: Equatable, Sendable {
    public private(set) var pendingSkinType: FitzpatrickSkinType?

    public init(pendingSkinType: FitzpatrickSkinType? = nil) {
        self.pendingSkinType = pendingSkinType
    }

    public var canContinue: Bool {
        pendingSkinType != nil
    }

    public mutating func select(_ skinType: FitzpatrickSkinType) {
        pendingSkinType = skinType
    }

    @discardableResult
    public func commit(to session: inout UVBurnTimerSession) -> Bool {
        guard let pendingSkinType else {
            return false
        }

        session.selectedSkinType = pendingSkinType
        return true
    }
}

public enum UserPreferenceStorage {
    public static let selectedSkinTypeKey = "selectedSkinType"
    public static let selectedSPFKey = "selectedSPF"
    public static let locationRationaleAcknowledgedKey = "locationRationaleAcknowledged"
    public static let disclaimerPolicyVersionKey = "disclaimerPolicyVersion"
    // Increment only with Plunder sign-off when a material policy/methodology change ships.
    public static let currentDisclaimerPolicyVersion = 1
    public static let unsetSkinTypeRawValue = 0

    public static func restoredSession(
        from defaults: UserDefaults = .standard,
        acknowledgedDisclaimer: Bool = false
    ) -> UVBurnTimerSession {
        UVBurnTimerSession(
            selectedSkinType: restoredSkinType(from: defaults),
            selectedSPF: restoredSPF(from: defaults),
            acknowledgedDisclaimer: acknowledgedDisclaimer
        )
    }

    public static func restoredSkinType(from defaults: UserDefaults = .standard) -> FitzpatrickSkinType? {
        guard defaults.object(forKey: selectedSkinTypeKey) != nil else {
            return nil
        }

        return FitzpatrickSkinType(rawValue: defaults.integer(forKey: selectedSkinTypeKey))
    }

    public static func restoredSPF(from defaults: UserDefaults = .standard) -> SPFLevel {
        guard defaults.object(forKey: selectedSPFKey) != nil,
            let spf = SPFLevel(rawValue: defaults.integer(forKey: selectedSPFKey)),
            spf.isSunscreen
        else {
            return .spf30
        }

        return spf
    }

    public static func persist(skinType: FitzpatrickSkinType?, to defaults: UserDefaults = .standard) {
        if let skinType {
            defaults.set(skinType.rawValue, forKey: selectedSkinTypeKey)
        } else {
            defaults.removeObject(forKey: selectedSkinTypeKey)
        }
    }

    public static func persist(spf: SPFLevel, to defaults: UserDefaults = .standard) {
        defaults.set((spf.isSunscreen ? spf : .spf30).rawValue, forKey: selectedSPFKey)
    }

    public static func clearStoredPreferences(from defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: selectedSkinTypeKey)
        defaults.removeObject(forKey: selectedSPFKey)
        defaults.removeObject(forKey: locationRationaleAcknowledgedKey)
        defaults.removeObject(forKey: disclaimerPolicyVersionKey)
        // WI-bundleR / Kwame L13-3 (Loop-13) — GDPR Art.17 erasure-path
        // completeness. The L1 storage-disclosure sentence advertises the
        // last rounded coordinate as a persisted item; the legacy UV
        // snapshot key from the pre-Pattern-B era is also still cleared
        // by the UI-test reset path (see UVBurnTimerApp.swift:28-29).
        // Centralizing both removals here makes `clearStoredPreferences`
        // a single source of truth for any future erasure entry point
        // (Settings → "Clear everything", future "Reset app" Shortcut,
        // automation harness, etc.).
        defaults.removeObject(forKey: lastRoundedCoordinateKey)
        defaults.removeObject(forKey: legacyUVSnapshotKey)
    }

    /// WI-bundleR / Kwame L13-3 — `@AppStorage` raw keys owned by
    /// `RootView` (AppViews.swift). Lifted into `UserPreferenceStorage`
    /// so `clearStoredPreferences` is the single GDPR Art.17 entry
    /// point and tests can pin the constant ↔ AppStorage drift.
    public static let lastRoundedCoordinateKey = "lastRoundedCoordinate"
    public static let legacyUVSnapshotKey = "lastUVSnapshot"

    /// K-2 / G-D1..G-D4 contract: evaluate whether L1 DisclaimerCover should be shown.
    ///
    /// - Returns `true` on first install or when `currentVersion` exceeds the stored version.
    /// - Returns `false` and silently migrates existing users (writes `currentVersion`) when
    ///   an existing-user signal is present but no policyVersion key has been written yet.
    ///
    /// Side effect: writes `currentVersion` to `disclaimerPolicyVersionKey` on the migration path.
    ///
    /// **Kwame-L12-H1 fix (Group II1):** the existing-user heuristic must require a *genuine*
    /// Fitzpatrick raw value, not just the existence of `selectedSkinTypeKey` on disk. RootView's
    /// `@AppStorage`-backed `persistedSkinTypeRawValue` writes the `unsetSkinTypeRawValue` (0)
    /// sentinel through to `UserDefaults` the first time `handleAppear()` fires — which happens
    /// while L1 is still on screen and unacknowledged. If we counted that sentinel as
    /// existing-user evidence, a force-quit before the user taps "I understand" would silently
    /// suppress L1 on the next launch and breach the Plunder C6 / Asha "L1 must fire once on
    /// first launch" contract.
    public static func shouldShowDisclaimerCover(
        defaults: UserDefaults,
        currentVersion: Int
    ) -> Bool {
        let storedVersion = defaults.integer(forKey: disclaimerPolicyVersionKey)
        // storedVersion == 0 means the key was never written (integer default is 0).

        // Genuine pick = the on-disk rawValue maps to a real FitzpatrickSkinType
        // (excluding the unsetSkinTypeRawValue sentinel and any out-of-range corruption).
        let hasGenuinelyPickedSkinType: Bool = {
            guard defaults.object(forKey: selectedSkinTypeKey) != nil else { return false }
            let rawValue = defaults.integer(forKey: selectedSkinTypeKey)
            guard rawValue != unsetSkinTypeRawValue else { return false }
            return FitzpatrickSkinType(rawValue: rawValue) != nil
        }()

        let isExistingUser =
            hasGenuinelyPickedSkinType
            || defaults.bool(forKey: locationRationaleAcknowledgedKey)

        if storedVersion == 0 && isExistingUser {
            // Migration: existing user upgrading from the @State-only era.
            // They've seen L1 on every prior cold launch — do NOT re-fire.
            defaults.set(currentVersion, forKey: disclaimerPolicyVersionKey)
            return false
        } else if storedVersion < currentVersion {
            // First install (storedVersion == 0, isExistingUser == false)
            // OR shipped policy version bumped above stored version.
            return true
        } else {
            return false
        }
    }
}

public enum DisclaimerReattestationPolicy {
    public static func shouldPresentOnForeground(
        returnedFromBackground: Bool,
        acknowledgedDisclaimer: Bool,
        estimateWindowElapsed: Bool
    ) -> Bool {
        returnedFromBackground && acknowledgedDisclaimer && estimateWindowElapsed
    }
}

public struct ForegroundReattestationTracker: Equatable, Sendable {
    private var hasEnteredBackground: Bool

    public init(hasEnteredBackground: Bool = false) {
        self.hasEnteredBackground = hasEnteredBackground
    }

    public mutating func recordBackgroundEntry() {
        hasEnteredBackground = true
    }

    public mutating func shouldPresentOnForeground(
        acknowledgedDisclaimer: Bool,
        estimateWindowElapsed: Bool
    ) -> Bool {
        let shouldPresent = DisclaimerReattestationPolicy.shouldPresentOnForeground(
            returnedFromBackground: hasEnteredBackground,
            acknowledgedDisclaimer: acknowledgedDisclaimer,
            estimateWindowElapsed: estimateWindowElapsed
        )
        hasEnteredBackground = false
        return shouldPresent
    }
}
