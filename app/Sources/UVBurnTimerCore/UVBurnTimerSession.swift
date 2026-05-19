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
