import Foundation

public enum SPFLevel: Int, CaseIterable, Codable, Identifiable, Sendable {
    case none = 1
    case spf15 = 15
    case spf30 = 30
    case spf50 = 50
    case spf70Plus = 70

    public var id: Int { rawValue }

    public var displayName: String {
        switch self {
        case .none: "None"
        case .spf15: "15"
        case .spf30: "30"
        case .spf50: "50"
        case .spf70Plus: "70+"
        }
    }

    public var contextLabel: String {
        switch self {
        case .none: "none"
        default: displayName
        }
    }
}
