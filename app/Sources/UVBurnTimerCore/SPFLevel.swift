import Foundation

public enum SPFLevel: Int, CaseIterable, Codable, Identifiable, Sendable {
    case unprotectedReference = 1
    case spf15 = 15
    case spf30 = 30
    case spf50 = 50
    case spf70Plus = 70

    public static let allCases: [SPFLevel] = [.spf15, .spf30, .spf50, .spf70Plus]

    public var id: Int { rawValue }

    public var displayName: String {
        switch self {
        case .unprotectedReference: "Unprotected reference"
        case .spf15: "15"
        case .spf30: "30"
        case .spf50: "50"
        case .spf70Plus: "70+"
        }
    }

    public var contextLabel: String {
        switch self {
        case .unprotectedReference: "unprotected reference"
        default: displayName
        }
    }

    public var isSunscreen: Bool {
        self != .unprotectedReference
    }

    public var modelMultiplier: Int {
        switch self {
        case .spf70Plus:
            50
        default:
            rawValue
        }
    }
}
