//
//  TaskProtocolTests.swift
//  Habitica ModelsTests
//

import XCTest
@testable import Habitica_Models

private class TestAssignment: AssignedDetailsProtocol {
    var assignedUserID: String?
    var assignedDate: Date?
    var assignedUsername: String?
    var assigningUsername: String?
    var completed: Bool
    var isValid = true
    var isManaged = false

    init(_ userID: String, completed: Bool = false) {
        assignedUserID = userID
        self.completed = completed
    }
}

class TaskProtocolTests: XCTestCase {

    private var task: PreviewTask!

    override func setUp() {
        super.setUp()
        task = PreviewTask()
    }

    func testTypeAsEnum() {
        task.type = "daily"
        XCTAssertEqual(task.typeAsEnum, .daily)
        task.type = "Daily"
        XCTAssertNil(task.typeAsEnum)
        task.type = nil
        XCTAssertNil(task.typeAsEnum)
    }

    func testEditability() {
        XCTAssertTrue(task.isEditable)
        task.challengeID = "challenge"
        XCTAssertTrue(task.isChallengeTask)
        XCTAssertFalse(task.isEditable)
        task.challengeID = nil
        task.groupID = "group"
        XCTAssertTrue(task.isGroupTask)
        XCTAssertFalse(task.isEditable)
    }

    func testEmptyChallengeIDStillCountsAsChallenge() {
        // only nil means "no challenge"; documents current behavior
        task.challengeID = ""
        XCTAssertTrue(task.isChallengeTask)
    }

    // MARK: dueOn

    func testDueOnMatchesSameDayOnly() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let due = Date(timeIntervalSince1970: 1_700_000_000) // 2023-11-14 22:13 UTC
        task.nextDue = [due]
        XCTAssertTrue(task.dueOn(date: due.addingTimeInterval(-22 * 3600), calendar: calendar))
        XCTAssertTrue(task.dueOn(date: due.addingTimeInterval(3600), calendar: calendar))
        XCTAssertFalse(task.dueOn(date: due.addingTimeInterval(2 * 3600), calendar: calendar))
    }

    func testDueOnDependsOnCalendarTimezone() throws {
        let due = Date(timeIntervalSince1970: 1_700_000_000) // 22:13 UTC, next day in Tokyo
        task.nextDue = [due]
        let laterUTC = due.addingTimeInterval(3 * 3600) // next day in both
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = .gmt
        var tokyo = Calendar(identifier: .gregorian)
        tokyo.timeZone = try XCTUnwrap(TimeZone(identifier: "Asia/Tokyo"))
        XCTAssertFalse(task.dueOn(date: laterUTC, calendar: utc))
        XCTAssertTrue(task.dueOn(date: laterUTC, calendar: tokyo))
    }

    func testDueOnWithNoDates() {
        XCTAssertFalse(task.dueOn(date: Date()))
    }

    // MARK: Completion

    func testPersonalTaskCompletion() {
        task.complete(forUser: "me", completed: true)
        XCTAssertTrue(task.completed)
        XCTAssertTrue(task.completed(by: "someone else"))
        task.complete(forUser: nil, completed: false)
        XCTAssertFalse(task.completed)
    }

    func testGroupTaskCompletionIsPerUser() {
        task.groupID = "group"
        task.groupAssignedDetails = [TestAssignment("a"), TestAssignment("b")]
        task.complete(forUser: "a", completed: true)
        XCTAssertTrue(task.completed(by: "a"))
        XCTAssertFalse(task.completed(by: "b"))
        XCTAssertFalse(task.completed, "task stays open until every assignee is done")

        task.complete(forUser: "b", completed: true)
        XCTAssertTrue(task.completed)
    }

    func testUncompletingOneAssigneeReopensOnlyWhenAllAgree() {
        task.groupID = "group"
        task.completed = true
        task.groupAssignedDetails = [TestAssignment("a", completed: true), TestAssignment("b", completed: true)]
        task.complete(forUser: "a", completed: false)
        XCTAssertFalse(task.completed(by: "a"))
        XCTAssertTrue(task.completed, "b is still done")
        task.complete(forUser: "b", completed: false)
        XCTAssertFalse(task.completed)
    }

    func testUnassignedUserFallsBackToTaskState() {
        task.groupID = "group"
        task.groupAssignedDetails = [TestAssignment("a")]
        task.completed = true
        XCTAssertTrue(task.completed(by: "stranger"))
        XCTAssertTrue(task.completed(by: nil))
    }

    func testUnassignedUserCannotChangeOtherAssignments() {
        task.groupID = "group"
        task.groupAssignedDetails = [TestAssignment("a")]
        task.complete(forUser: "stranger", completed: true)
        XCTAssertFalse(task.completed(by: "a"))
        XCTAssertFalse(task.completed)
    }

    func testGroupTaskWithoutAssignmentsCompletesDirectly() {
        task.groupID = "group"
        task.complete(forUser: "a", completed: true)
        XCTAssertTrue(task.completed)
    }
}
