//
//  DateExtensionsTests.swift
//  HabiticaTests
//

import XCTest
@testable import Habitica

class DateExtensionsTests: XCTestCase {

    // half a second of slack so the time between building the date and formatting it can't drop a unit
    private func inFuture(days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
        let interval = TimeInterval(((days * 24 + hours) * 60 + minutes) * 60 + seconds) + 0.5
        return Date().addingTimeInterval(interval)
    }

    func testWithBuildsMidnightInGivenTimezone() {
        let utc = TimeZone(identifier: "UTC")!
        let date = Date.with(year: 2024, month: 2, day: 29, timezone: utc)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 2)
        XCTAssertEqual(components.day, 29)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
    }

    func testWithDefaultsToCurrentTimezone() {
        let date = Date.with(year: 2020, month: 6, day: 15)
        XCTAssertEqual(Calendar.current.component(.hour, from: date), 0)
        XCTAssertEqual(Calendar.current.component(.day, from: date), 15)
    }

    func testWithRollsOverInvalidDays() {
        // Calendar normalizes Feb 30 rather than failing
        let utc = TimeZone(identifier: "UTC")!
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc
        let date = Date.with(year: 2023, month: 2, day: 30, timezone: utc)
        XCTAssertEqual(calendar.component(.month, from: date), 3)
    }

    // MARK: getShortRemainingString

    func testShortRemainingUnderAnHourShowsSeconds() {
        XCTAssertEqual(inFuture(minutes: 5, seconds: 30).getShortRemainingString(), "5m 30s")
        XCTAssertEqual(inFuture(seconds: 10).getShortRemainingString(), "0m 10s")
    }

    func testShortRemainingWithHoursHidesSeconds() {
        XCTAssertEqual(inFuture(hours: 2, minutes: 5, seconds: 30).getShortRemainingString(), "2h 5m")
    }

    func testShortRemainingWithDays() {
        XCTAssertEqual(inFuture(days: 3, hours: 1, minutes: 1).getShortRemainingString(), "3d 1h 1m")
        // zero hours are skipped, but seconds stay hidden while days remain
        XCTAssertEqual(inFuture(days: 2, minutes: 10, seconds: 5).getShortRemainingString(), "2d 10m")
    }

    func testShortRemainingForPastDateIsZero() {
        // regression: rendered "-5m -30s"
        XCTAssertEqual(Date().addingTimeInterval(-330).getShortRemainingString(), "0m 0s")
        XCTAssertEqual(Date(timeIntervalSince1970: 0).getShortRemainingString(), "0m 0s")
    }

    // MARK: getImpreciseRemainingString

    func testImpreciseRemainingDays() {
        XCTAssertEqual(inFuture(days: 1, hours: 5).getImpreciseRemainingString(), L10n._1Day)
        XCTAssertEqual(inFuture(days: 3).getImpreciseRemainingString(), L10n.xDays(3))
    }

    func testImpreciseRemainingHours() {
        XCTAssertEqual(inFuture(hours: 1, minutes: 59).getImpreciseRemainingString(), L10n._1Hour)
        XCTAssertEqual(inFuture(hours: 5).getImpreciseRemainingString(), L10n.xHours(5))
    }

    func testImpreciseRemainingMinutes() {
        // regression: minutes were read from the day component, so this said "1 minute"
        XCTAssertEqual(inFuture(minutes: 30).getImpreciseRemainingString(), L10n.xMinutes(30))
        XCTAssertEqual(inFuture(minutes: 1, seconds: 30).getImpreciseRemainingString(), L10n._1Minute)
    }

    func testImpreciseRemainingUnderAMinuteOrPast() {
        XCTAssertEqual(inFuture(seconds: 20).getImpreciseRemainingString(), L10n._1Minute)
        XCTAssertEqual(Date().addingTimeInterval(-3600).getImpreciseRemainingString(), L10n._1Minute)
    }
}
