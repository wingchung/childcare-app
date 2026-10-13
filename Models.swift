import Foundation

enum EventKind: String, Codable, CaseIterable, Identifiable {
    case feed, sleep, diaper

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var symbol: String {
        switch self {
        case .feed: "drop.fill"
        case .sleep: "moon.stars.fill"
        case .diaper: "sparkles"
        }
    }
}

struct BabyProfile: Codable, Equatable {
    var name: String
    var birthdate: Date
}

struct CareEvent: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var kind: EventKind
    var occurredAt: Date
    var durationMinutes: Int?
    var detail: String
    var note: String
}

struct RestEstimate: Equatable {
    let suggestedTime: Date
    let wakeWindowMinutes: Int
    let confidence: String
    let reason: String
}
