//
//  ConfigRepositoryTests.swift
//  HabiticaTests
//

import XCTest
import ReactiveSwift
import Habitica_Models
@testable import Habitica

class ConfigRepositoryTests: XCTestCase {

    private var suiteName = ""
    private var defaults: UserDefaults!
    private var notificationCenter: NotificationCenter!
    /// One entry per request the repository sent: whether it ignored the etag, and the pipe to answer it with.
    private var requests: [(ignoreEtag: Bool, input: Signal<[String: JSONValue]?, Never>.Observer)] = []

    override func setUp() {
        super.setUp()
        suiteName = "ConfigRepositoryTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        notificationCenter = NotificationCenter()
        requests = []
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    private func makeRepository() -> ConfigRepository {
        return ConfigRepository(userConfig: defaults, notificationCenter: notificationCenter) {[unowned self] ignoreEtag in
            let (signal, input) = Signal<[String: JSONValue]?, Never>.pipe()
            self.requests.append((ignoreEtag, input))
            return signal
        }
    }

    private func respond(_ index: Int, with config: [String: JSONValue]?) {
        requests[index].input.send(value: config)
        requests[index].input.sendCompleted()
    }

    // MARK: - Decoding

    func testMissingKeyUsesDefault() {
        let repository = makeRepository()
        XCTAssertEqual(repository.value(for: .maxChatLength), 3000)
        XCTAssertEqual(repository.value(for: .supportEmail), "admin@habitica.com")
        XCTAssertNil(repository.value(for: .lastVersionNumber))
        XCTAssertEqual(repository.value(for: .knownIssues), [])
    }

    func testWrongTypeUsesDefault() {
        let repository = makeRepository()
        repository.update(config: [
            "maxChatLength": .string("lots"),
            "hideChallenges": .string("yes"),
            "knownIssues": .bool(true),
            "maintenanceData": .array([])
        ])
        XCTAssertEqual(repository.value(for: .maxChatLength), 3000)
        XCTAssertFalse(repository.value(for: .hideChallenges))
        XCTAssertEqual(repository.value(for: .knownIssues), [])
        XCTAssertEqual(repository.value(for: .maintenanceData), [:])
    }

    func testNativeJSONValues() {
        let repository = makeRepository()
        repository.update(config: [
            "maxChatLength": .int(500),
            "hideChallenges": .bool(true),
            "lastVersionNumber": .string("4.2.0"),
            "lastVersionCode": .int(1234)
        ])
        XCTAssertEqual(repository.value(for: .maxChatLength), 500)
        XCTAssertTrue(repository.value(for: .hideChallenges))
        XCTAssertEqual(repository.value(for: .lastVersionNumber), "4.2.0")
        XCTAssertEqual(repository.value(for: .lastVersionCode), 1234)
    }

    func testStringEncodedValuesFromLegacyConfig() {
        let repository = makeRepository()
        repository.update(config: [
            "maxChatLength": .string("500"),
            "hideChallenges": .string("true"),
            "knownIssues": .string("[{\"title\":\"Sync\",\"text\":\"Broken\"}]"),
            "maintenanceData": .string("{\"title\":\"Down\",\"description\":\"Back soon\"}")
        ])
        XCTAssertEqual(repository.value(for: .maxChatLength), 500)
        XCTAssertTrue(repository.value(for: .hideChallenges))
        XCTAssertEqual(repository.value(for: .knownIssues).first?["title"]?.stringValue, "Sync")
        XCTAssertEqual(repository.value(for: .maintenanceData)["description"]?.stringValue, "Back soon")
    }

    func testNullForOptionalKeyIsNil() {
        let repository = makeRepository()
        repository.update(config: ["lastVersionNumber": .null])
        XCTAssertNil(repository.value(for: .lastVersionNumber))
    }

    func testNullForNonOptionalKeyUsesDefault() {
        let repository = makeRepository()
        repository.update(config: ["maxChatLength": .null, "supportEmail": .null])
        XCTAssertEqual(repository.value(for: .maxChatLength), 3000)
        XCTAssertEqual(repository.value(for: .supportEmail), "admin@habitica.com")
    }

    func testEmptyStringIsKeptForStringKeys() {
        // An empty string is a value, not a missing one: the server can blank a URL on purpose
        let repository = makeRepository()
        repository.update(config: ["supportEmail": .string("")])
        XCTAssertEqual(repository.value(for: .supportEmail), "")
    }

    func testMaintenanceDataToleratesNonStringFields() {
        // The old NSDictionary parsing ignored extra fields; one non-string field must not hide the maintenance screen
        let repository = makeRepository()
        repository.update(config: ["maintenanceData": .object([
            "title": .string("Down"),
            "description": .string("Back soon"),
            "showAppstoreButton": .bool(true),
            "minBuild": .int(12)
        ])])
        let data = repository.value(for: .maintenanceData)
        XCTAssertEqual(data["title"]?.stringValue, "Down")
        XCTAssertEqual(data["description"]?.stringValue, "Back soon")
    }

    func testKnownIssuesTolerateNonStringFields() {
        let repository = makeRepository()
        repository.update(config: ["knownIssues": .array([
            .object(["title": .string("A"), "text": .string("a"), "priority": .int(1)]),
            .object(["title": .string("B"), "text": .null])
        ])])
        let issues = repository.value(for: .knownIssues)
        XCTAssertEqual(issues.compactMap { $0["title"]?.stringValue }, ["A", "B"])
        XCTAssertNil(issues[1]["text"]?.stringValue)
    }

    func testDeveloperFlagForcesDefaults() {
        let repository = makeRepository()
        repository.update(config: ["maxChatLength": .int(1)])
        repository.setDeveloperFlag(true, forKey: ConfigRepository.useDefaultsFlag)
        defer { repository.setDeveloperFlag(false, forKey: ConfigRepository.useDefaultsFlag) }
        #if DEBUG
        XCTAssertEqual(repository.value(for: .maxChatLength), 3000)
        #endif
        XCTAssertFalse(UserDefaults.standard.bool(forKey: ConfigRepository.useDefaultsFlag), "flag must go to the repository's own defaults")
    }

    // MARK: - Persistence

    func testConfigSurvivesRestart() {
        makeRepository().update(config: ["maxChatLength": .int(42)])
        let restarted = makeRepository()
        XCTAssertEqual(restarted.value(for: .maxChatLength), 42)
        XCTAssertNotNil(restarted.lastFetchDate)
    }

    func testCorruptCacheFallsBackToDefaultsAndIgnoresEtag() {
        defaults.set(Data("not json".utf8), forKey: "clientConfig")
        let repository = makeRepository()
        XCTAssertEqual(repository.value(for: .maxChatLength), 3000)
        repository.fetchRemoteConfig(force: false)
        XCTAssertEqual(requests.map(\.ignoreEtag), [true])
    }

    // MARK: - Fetching

    func testEtagIgnoredOnlyWithoutCachedConfig() {
        let repository = makeRepository()
        repository.fetchRemoteConfig(force: false)
        respond(0, with: ["maxChatLength": .int(1)])
        repository.fetchRemoteConfig(force: true)
        XCTAssertEqual(requests.map(\.ignoreEtag), [true, false])
    }

    func testFetchIsThrottledUnlessForced() {
        let repository = makeRepository()
        repository.fetchRemoteConfig(force: false)
        respond(0, with: ["maxChatLength": .int(1)])
        repository.fetchRemoteConfig(force: false)
        XCTAssertEqual(requests.count, 1)
        repository.fetchRemoteConfig(force: true)
        XCTAssertEqual(requests.count, 2)
    }

    func testFailedFetchAlsoThrottles() {
        let repository = makeRepository()
        repository.fetchRemoteConfig(force: false)
        requests[0].input.sendInterrupted()
        repository.fetchRemoteConfig(force: false)
        XCTAssertEqual(requests.count, 1)
    }

    func testConcurrentFetchesAreCoalesced() {
        let repository = makeRepository()
        repository.fetchRemoteConfig(force: false)
        repository.fetchRemoteConfig(force: false)
        repository.fetchRemoteConfig(force: false)
        XCTAssertEqual(requests.count, 1)
        respond(0, with: [:])
        XCTAssertEqual(requests.count, 1, "non-forced calls during a fetch must not queue another")
    }

    func testNotModifiedKeepsCachedConfig() {
        let repository = makeRepository()
        repository.fetchRemoteConfig(force: false)
        respond(0, with: ["maxChatLength": .int(7)])
        let fetchDate = repository.lastFetchDate

        var completed = false
        repository.onFetchCompleted = { completed = true }
        repository.fetchRemoteConfig(force: true)
        respond(1, with: nil) // 304 and errors arrive as nil
        XCTAssertTrue(completed)
        XCTAssertEqual(repository.value(for: .maxChatLength), 7)
        XCTAssertEqual(repository.lastFetchDate, fetchDate)
    }

    func testCompletionRunsOnceForEveryOutcome() {
        let repository = makeRepository()
        var calls = 0
        repository.onFetchCompleted = { calls += 1 }
        XCTAssertFalse(repository.hasFetched)
        repository.fetchRemoteConfig(force: false)
        requests[0].input.sendInterrupted()
        XCTAssertTrue(repository.hasFetched)
        repository.fetchRemoteConfig(force: true)
        respond(1, with: [:])
        XCTAssertEqual(calls, 1, "completion is a one-shot for the launch screen")
    }

    // MARK: - Authentication changes

    func testAuthChangeBeforeFirstFetchDoesNothing() {
        // Launch args set credentials before the network client exists
        _ = makeRepository()
        notificationCenter.post(name: .authenticationChanged, object: nil)
        XCTAssertTrue(requests.isEmpty)
    }

    func testAuthChangeAfterFetchForcesRefetch() {
        let repository = makeRepository()
        repository.fetchRemoteConfig(force: false)
        respond(0, with: [:])
        notificationCenter.post(name: .authenticationChanged, object: nil)
        XCTAssertEqual(requests.count, 2)
    }

    func testAuthChangeDuringFetchRefetchesAfterward() {
        let repository = makeRepository()
        repository.fetchRemoteConfig(force: false)
        notificationCenter.post(name: .authenticationChanged, object: nil)
        XCTAssertEqual(requests.count, 1, "must not overlap the running request")
        respond(0, with: ["hideChallenges": .bool(false)])
        XCTAssertEqual(requests.count, 2, "the running request may carry the old credentials")
        respond(1, with: ["hideChallenges": .bool(true)])
        XCTAssertEqual(requests.count, 2)
        XCTAssertTrue(repository.value(for: .hideChallenges))
    }

    // MARK: - Observing

    func testValuesEmitsCurrentThenChanges() async {
        let repository = makeRepository()
        repository.update(config: ["maxChatLength": .int(1)])
        var iterator = repository.values(for: .maxChatLength).makeAsyncIterator()
        let first = await iterator.next()
        XCTAssertEqual(first, 1)
        repository.update(config: ["maxChatLength": .int(2)])
        let second = await iterator.next()
        XCTAssertEqual(second, 2)
    }

    func testRemovedKeyEmitsDefault() async {
        let repository = makeRepository()
        repository.update(config: ["maxChatLength": .int(1)])
        var iterator = repository.values(for: .maxChatLength).makeAsyncIterator()
        _ = await iterator.next()
        repository.update(config: [:])
        let value = await iterator.next()
        XCTAssertEqual(value, 3000)
    }

    func testUnrelatedChangesDoNotNotify() {
        let repository = makeRepository()
        repository.update(config: ["maxChatLength": .int(1)])
        let notified = expectation(description: "unrelated change notified")
        notified.isInverted = true
        let task = repository.observe(.maxChatLength, includingCurrent: false) { _ in notified.fulfill() }
        repository.update(config: ["maxChatLength": .int(1), "hideChallenges": .bool(true)])
        wait(for: [notified], timeout: 0.3)
        task.cancel()
    }

    func testObserveWithoutCurrentOnlyGetsChanges() {
        let repository = makeRepository()
        repository.update(config: ["maxChatLength": .int(1)])
        var received = [Int]()
        let changed = expectation(description: "changed")
        let task = repository.observe(.maxChatLength, includingCurrent: false) { value in
            received.append(value)
            changed.fulfill()
        }
        repository.update(config: ["maxChatLength": .int(2)])
        wait(for: [changed], timeout: 1)
        XCTAssertEqual(received, [2])
        task.cancel()
    }

    func testCancelledObserverStopsReceiving() async {
        let repository = makeRepository()
        var received = [Int]()
        let task = repository.observe(.maxChatLength) { received.append($0) }
        await Task.yield()
        task.cancel()
        _ = await task.value
        repository.update(config: ["maxChatLength": .int(2)])
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertFalse(received.contains(2))
    }
}
