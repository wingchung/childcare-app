import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var profile: BabyProfile?
    @Published private(set) var events: [CareEvent] = []

    private let storageKey = "nestling.local.v1"

    init() { load() }

    func saveProfile(name: String, birthdate: Date) {
        profile = BabyProfile(name: name.trimmingCharacters(in: .whitespacesAndNewlines), birthdate: birthdate)
        persist()
    }

    func add(kind: EventKind, occurredAt: Date, durationMinutes: Int?, detail: String, note: String) {
        events.append(CareEvent(kind: kind, occurredAt: occurredAt, durationMinutes: durationMinutes, detail: detail, note: note))
        persist()
    }

    func addSampleDay() {
        if profile == nil { profile = BabyProfile(name: "Ari", birthdate: Calendar.current.date(byAdding: .month, value: -6, to: .now) ?? .now) }
        events = [
            CareEvent(kind: .diaper, occurredAt: .now.addingTimeInterval(-14_400), durationMinutes: nil, detail: "Wet", note: ""),
            CareEvent(kind: .sleep, occurredAt: .now.addingTimeInterval(-10_200), durationMinutes: 45, detail: "Nap", note: ""),
            CareEvent(kind: .feed, occurredAt: .now.addingTimeInterval(-3_000), durationMinutes: nil, detail: "Bottle", note: "")
        ]
        persist()
    }

    func reset() { profile = nil; events = []; UserDefaults.standard.removeObject(forKey: storageKey) }

    private struct SavedState: Codable { var profile: BabyProfile?; var events: [CareEvent] }
    private func persist() {
        guard let data = try? JSONEncoder().encode(SavedState(profile: profile, events: events)) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey), let saved = try? JSONDecoder().decode(SavedState.self, from: data) else { return }
        profile = saved.profile; events = saved.events
    }
}
