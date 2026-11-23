//
//  ConfigDrivenUITests.swift
//  HabiticaTests
//
//  Screens read ConfigRepository.shared, so these tests push configs into it and check the UI reacts.
//

import XCTest
import Habitica_Models
@testable import Habitica

class ConfigDrivenUITests: XCTestCase {

    private let repository = ConfigRepository.shared

    override func setUp() {
        super.setUp()
        // The host app's launch fetch would otherwise overwrite our config mid-test
        let deadline = Date().addingTimeInterval(10)
        while !repository.hasFetched && Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        }
    }

    override func tearDown() {
        repository.update(config: [:])
        super.tearDown()
    }

    private func waitUntil(_ description: String, timeout: TimeInterval = 2, _ condition: @escaping () -> Bool) {
        let predicate = NSPredicate { _, _ in condition() }
        wait(for: [XCTNSPredicateExpectation(predicate: predicate, object: nil)], timeout: timeout)
        XCTAssertTrue(condition(), description)
    }

    private func challengesItem() -> MenuItem? {
        return MenuItem.allItems.first { $0.key == .challenges }
    }

    // MARK: - Main menu

    func testMainMenuHidesChallengesWhenConfigChanges() {
        let menu = MainMenuViewController(style: .grouped)
        menu.loadViewIfNeeded()

        repository.update(config: ["hideChallenges": .bool(true)])
        waitUntil("challenges hidden") { self.challengesItem()?.isHidden == true }

        repository.update(config: ["hideChallenges": .bool(false)])
        waitUntil("challenges shown again") { self.challengesItem()?.isHidden == false }
        withExtendedLifetime(menu) {}
    }

    func testMainMenuShowsSubscriptionBannerWhenConfigChanges() {
        let menu = MainMenuViewController(style: .grouped)
        menu.loadViewIfNeeded()

        repository.update(config: ["showSubscriptionBanner": .bool(true)])
        waitUntil("banner shown") { menu.tableView.tableFooterView is SubscriptionPromoView }

        repository.update(config: ["showSubscriptionBanner": .bool(false)])
        waitUntil("banner removed") { !(menu.tableView.tableFooterView is SubscriptionPromoView) }
    }

    func testDeallocatedMainMenuStopsObserving() {
        weak var weakMenu: MainMenuViewController?
        autoreleasepool {
            let menu = MainMenuViewController(style: .grouped)
            menu.loadViewIfNeeded()
            weakMenu = menu
        }
        waitUntil("menu deallocated") { weakMenu == nil }
        // Would crash or leak if a config task still held the controller
        repository.update(config: ["hideChallenges": .bool(true), "showSubscriptionBanner": .bool(true)])
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))
    }

    // MARK: - Report a bug

    private func knownIssueTitles(_ controller: ReportBugViewController) -> [String?] {
        return controller.knownIssuesStackView.arrangedSubviews.map { row in
            (row as? UIStackView)?.arrangedSubviews.compactMap { $0 as? UILabel }.first?.text
        }
    }

    func testReportBugListsKnownIssuesAndUpdates() {
        repository.update(config: ["knownIssues": .array([
            .object(["title": .string("Sync"), "text": .string("Sync is slow")]),
            .object(["title": .string("Login"), "text": .string("Login fails"), "priority": .int(1)])
        ])])
        let controller = StoryboardScene.Support.reportBugViewController.instantiate()
        controller.loadViewIfNeeded()
        waitUntil("initial issues shown") { self.knownIssueTitles(controller) == ["Sync", "Login"] }

        repository.update(config: ["knownIssues": .string("[{\"title\":\"Crash\",\"text\":\"On launch\"}]")])
        waitUntil("updated issues shown") { self.knownIssueTitles(controller) == ["Crash"] }

        repository.update(config: [:])
        waitUntil("issues cleared") { controller.knownIssuesStackView.arrangedSubviews.isEmpty }
    }

    // MARK: - Maintenance

    private func maintenanceScreen() -> MaintenanceViewController? {
        return UIWindow.findViewController()
    }

    func testMaintenanceScreenFollowsConfig() throws {
        let delegate = try XCTUnwrap(UIApplication.shared.delegate as? HabiticaAppDelegate)
        XCTAssertFalse(delegate.handleMaintenanceScreen())

        repository.update(config: ["maintenanceData": .object([
            "title": .string("Down"),
            "description": .string("Back soon"),
            "showAppstoreButton": .bool(false)
        ])])
        waitUntil("maintenance shown", timeout: 5) { self.maintenanceScreen() != nil }

        repository.update(config: [:])
        waitUntil("maintenance dismissed", timeout: 5) { self.maintenanceScreen() == nil }
    }

    func testIncompleteMaintenanceDataShowsNothing() throws {
        let delegate = try XCTUnwrap(UIApplication.shared.delegate as? HabiticaAppDelegate)
        repository.update(config: ["maintenanceData": .object(["title": .string("Down")])])
        XCTAssertFalse(delegate.handleMaintenanceScreen())
    }
}
