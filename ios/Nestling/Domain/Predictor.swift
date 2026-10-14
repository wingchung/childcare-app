import Foundation

enum RestPredictor {
    static func ageInMonths(birthdate: Date, now: Date = .now, calendar: Calendar = .current) -> Int {
        max(0, calendar.dateComponents([.month], from: birthdate, to: now).month ?? 0)
    }

    static func baselineWakeMinutes(ageInMonths: Int) -> Int {
        switch ageInMonths {
        case ..<3: 75
        case 3..<6: 120
        case 6..<9: 150
        case 9..<13: 190
        case 13..<18: 230
        default: 285
        }
    }

    static func estimate(events: [CareEvent], profile: BabyProfile?, now: Date = .now, calendar: Calendar = .current) -> RestEstimate? {
        guard let lastSleep = events
            .filter({ $0.kind == .sleep && $0.occurredAt <= now })
            .sorted(by: { $0.occurredAt > $1.occurredAt })
            .first else { return nil }

        let duration = max(0, lastSleep.durationMinutes ?? 0)
        let wakeAt = calendar.date(byAdding: .minute, value: duration, to: lastSleep.occurredAt) ?? lastSleep.occurredAt
        let months = profile.map { ageInMonths(birthdate: $0.birthdate, now: now, calendar: calendar) } ?? 4
        var window = baselineWakeMinutes(ageInMonths: months)
        let shortNap = duration > 0 && duration < 35
        if shortNap { window = max(45, window - 20) }
        let suggested = calendar.date(byAdding: .minute, value: window, to: wakeAt) ?? wakeAt
        let sleepCount = events.filter { $0.kind == .sleep && now.timeIntervalSince($0.occurredAt) < 86_400 }.count
        let afterSleep = duration > 0 ? "after a \(duration)-minute sleep" : "after the last recorded sleep"
        let adjustment = shortNap ? " It is slightly earlier because the nap was short." : ""

        return RestEstimate(
            suggestedTime: suggested,
            wakeWindowMinutes: window,
            confidence: sleepCount >= 3 ? "More context" : "Early estimate",
            reason: "This estimate uses a typical \(window)-minute awake window for this age \(afterSleep).\(adjustment)"
        )
    }
}
