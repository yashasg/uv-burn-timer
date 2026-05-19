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
}

public enum DisclaimerReattestationPolicy {
    public static func shouldPresentOnForeground(
        returnedFromBackground: Bool,
        acknowledgedDisclaimer: Bool
    ) -> Bool {
        returnedFromBackground && acknowledgedDisclaimer
    }
}
