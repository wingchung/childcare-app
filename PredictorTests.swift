import XCTest
@testable import NestlingCore

final class PredictorTests: XCTestCase {
    private let utc = TimeZone(secondsFromGMT: 0)!
    private var calendar: Calendar { var value = Calendar(identifier: .gregorian); value.timeZone = utc; return value }
    private func date(_ string: String) -> Date { ISO8601DateFormatter().date(from: string)! }

    func testShortNapBringsNextWindowEarlier() {
        let now = date("2026-10-10T12:00:00Z")
        let profile = BabyProfile(name: "Ari", birthdate: date("2026-04-10T12:00:00Z"))
        let event = CareEvent(kind: .sleep, occurredAt: date("2026-10-10T09:00:00Z"), durationMinutes: 30, detail: "Nap", note: "")
        let estimate = RestPredictor.estimate(events: [event], profile: profile, now: now, calendar: calendar)
        XCTAssertEqual(estimate?.wakeWindowMinutes, 130)
        XCTAssertEqual(estimate?.suggestedTime, date("2026-10-10T11:40:00Z"))
        XCTAssertTrue(estimate?.reason.contains("short") == true)
    }

    func testNoSleepHasNoEstimate() {
        XCTAssertNil(RestPredictor.estimate(events: [], profile: nil, now: date("2026-10-10T12:00:00Z"), calendar: calendar))
    }

    func testAgeBandBoundaries() {
        XCTAssertEqual(RestPredictor.baselineWakeMinutes(ageInMonths: 2), 75)
        XCTAssertEqual(RestPredictor.baselineWakeMinutes(ageInMonths: 6), 150)
        XCTAssertEqual(RestPredictor.baselineWakeMinutes(ageInMonths: 18), 285)
    }
}
