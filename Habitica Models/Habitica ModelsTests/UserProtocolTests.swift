//
//  UserProtocolTests.swift
//  Habitica ModelsTests
//

import XCTest
@testable import Habitica_Models

private class TestPermissions: PermissionsProtocol {
    var fullAccess = false
    var moderator = false
    var userSupport = false
    var isValid = true
    var isManaged = false
}

private class TestContributor: ContributorProtocol {
    var level = 0
    var admin = false
    var text: String?
    var contributions: String?
}

class UserProtocolTests: XCTestCase {

    private var user: TestUser!
    private var stats: TestStats!
    private var flags: TestFlags!
    private var preferences: TestPreferences!

    override func setUp() {
        super.setUp()
        user = TestUser()
        stats = TestStats()
        flags = TestFlags()
        preferences = TestPreferences()
        user.stats = stats
        user.flags = flags
        user.preferences = preferences
    }

    func testGemCount() {
        for (balance, gems) in [(Float(0), 0), (0.25, 1), (0.5, 2), (2.75, 11), (1000, 4000)] {
            user.balance = balance
            XCTAssertEqual(user.gemCount, gems, "balance \(balance)")
        }
    }

    func testGemCountTruncatesPartialGems() {
        user.balance = 0.2
        XCTAssertEqual(user.gemCount, 0)
    }

    // MARK: Class selection

    func testBelowLevel10CannotUseSkillsOrChooseClass() {
        stats.level = 9
        XCTAssertFalse(user.canUseSkills)
        XCTAssertFalse(user.needsToChooseClass)
        XCTAssertFalse(user.canChooseClassForFree)
    }

    func testLevel10WithoutClassNeedsToChoose() {
        stats.level = 10
        flags.classSelected = false
        XCTAssertFalse(user.canUseSkills)
        XCTAssertTrue(user.needsToChooseClass)
        XCTAssertTrue(user.canChooseClassForFree)
    }

    func testLevel10WithClassCanUseSkills() {
        stats.level = 10
        flags.classSelected = true
        XCTAssertTrue(user.canUseSkills)
        XCTAssertFalse(user.needsToChooseClass)
        XCTAssertFalse(user.canChooseClassForFree)
    }

    func testDisabledClassesBlockSkillsButAllowFreeChoice() {
        stats.level = 50
        flags.classSelected = true
        preferences.disableClasses = true
        XCTAssertFalse(user.canUseSkills)
        XCTAssertFalse(user.needsToChooseClass)
        XCTAssertTrue(user.canChooseClassForFree)
    }

    func testMissingStatsCountsAsLevelZero() {
        user.stats = nil
        flags.classSelected = true
        XCTAssertFalse(user.canUseSkills)
        XCTAssertFalse(user.needsToChooseClass)
    }

    func testMissingFlagsDoesNotForceClassChoice() {
        // with no flags loaded we can't tell, so don't nag the user
        stats.level = 20
        user.flags = nil
        XCTAssertFalse(user.needsToChooseClass)
        XCTAssertTrue(user.canUseSkills)
    }

    // MARK: Roles

    func testModeratorNeedsContributorLevel8() {
        XCTAssertFalse(user.isModerator)
        let contributor = TestContributor()
        user.contributor = contributor
        contributor.level = 7
        XCTAssertFalse(user.isModerator)
        contributor.level = 8
        XCTAssertTrue(user.isModerator)
        contributor.level = 9
        XCTAssertTrue(user.isModerator)
    }

    func testPermissions() {
        XCTAssertFalse(user.hasPermission(.moderator))
        XCTAssertFalse(user.hasPermission(.userSupport))

        let permissions = TestPermissions()
        user.permissions = permissions
        permissions.moderator = true
        XCTAssertTrue(user.hasPermission(.moderator))
        XCTAssertFalse(user.hasPermission(.userSupport))

        permissions.moderator = false
        permissions.userSupport = true
        XCTAssertFalse(user.hasPermission(.moderator))
        XCTAssertTrue(user.hasPermission(.userSupport))
    }

    func testFullAccessGrantsEveryPermission() {
        let permissions = TestPermissions()
        permissions.fullAccess = true
        user.permissions = permissions
        XCTAssertTrue(user.hasPermission(.moderator))
        XCTAssertTrue(user.hasPermission(.userSupport))
    }

    func testNotSubscribedWithoutPurchaseData() {
        XCTAssertFalse(user.isSubscribed)
        XCTAssertNil(user.username)
    }
}
