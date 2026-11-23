//
//  ContentRepositoryTests.swift
//  HabiticaTests
//

import XCTest
import ReactiveSwift
import Habitica_Models
@testable import Habitica

class ContentRepositoryTests: RepositoryTestCase {

    private let keys = ["lastContentFetch", "lastContentFetchVersion", "lastContentAppLanguageCode", "lastWorldStateFetch"]
    private var savedDefaults: [String: Any] = [:]
    private var repository: ContentRepository!

    private var buildNumber: String? { Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String }
    private var languageCode: String { LanguageHandler.getAppLanguage().code }

    override func setUp() {
        super.setUp()
        savedDefaults = [:]
        for key in keys {
            savedDefaults[key] = UserDefaults.standard.object(forKey: key)
            UserDefaults.standard.removeObject(forKey: key)
        }
        repository = ContentRepository()
    }

    override func tearDown() {
        for key in keys {
            UserDefaults.standard.set(savedDefaults[key], forKey: key)
        }
        super.tearDown()
    }

    private func markContentFetched(ago seconds: TimeInterval = 0, version: String? = nil, language: String? = nil) {
        UserDefaults.standard.set(Date().addingTimeInterval(-seconds), forKey: "lastContentFetch")
        UserDefaults.standard.set(version ?? buildNumber, forKey: "lastContentFetchVersion")
        UserDefaults.standard.set(language ?? languageCode, forKey: "lastContentAppLanguageCode")
    }

    private func assertFetches(_ signal: Signal<ContentProtocol?, Never>, file: StaticString = #filePath, line: UInt = #line) {
        let disposable = signal.observeValues { _ in }
        waitForRequests(1, file: file, line: line)
        disposable?.dispose()
        XCTAssertEqual(requestedPaths, ["GET content"], file: file, line: line)
    }

    // MARK: Content

    func testFetchesWhenNeverFetched() {
        assertFetches(repository.retrieveContent())
        XCTAssertEqual(StubURLProtocol.requests.first?.url?.query, "language=\(languageCode)")
    }

    func testSkipsFreshContent() {
        markContentFetched(ago: 60)
        assertEmpty(repository.retrieveContent())
        drain()
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testForceIgnoresCache() {
        markContentFetched()
        assertFetches(repository.retrieveContent(force: true))
    }

    func testRefetchesAfterAnHour() {
        markContentFetched(ago: 3601)
        assertFetches(repository.retrieveContent())
    }

    func testRefetchesWhenLanguageChanged() {
        markContentFetched(language: "xx")
        assertFetches(repository.retrieveContent())
    }

    func testRefetchesAfterAppUpdate() {
        markContentFetched(version: "0")
        assertFetches(repository.retrieveContent())
    }

    func testSuccessfulFetchUpdatesCacheMarkers() throws {
        stub("GET", "content", data: "{}")
        firstValue(repository.retrieveContent())
        drain()
        let fetched = try XCTUnwrap(UserDefaults.standard.object(forKey: "lastContentFetch") as? Date)
        XCTAssertLessThan(abs(fetched.timeIntervalSinceNow), 5)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "lastContentFetchVersion"), buildNumber)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "lastContentAppLanguageCode"), languageCode)
    }

    func testFailedFetchDoesNotMarkContentFresh() {
        stub("GET", "content", status: 500, data: "null")
        assertFetches(repository.retrieveContent())
        drain()
        XCTAssertNil(UserDefaults.standard.object(forKey: "lastContentFetch"), "next launch must retry")
    }

    // MARK: World state

    func testWorldStateCachedForTenMinutes() {
        UserDefaults.standard.set(Date().addingTimeInterval(-599), forKey: "lastWorldStateFetch")
        assertEmpty(repository.retrieveWorldState())
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)

        UserDefaults.standard.set(Date().addingTimeInterval(-601), forKey: "lastWorldStateFetch")
        let disposable = repository.retrieveWorldState().observeValues { _ in }
        waitForRequests(1)
        disposable?.dispose()
        XCTAssertEqual(requestedPaths, ["GET world-state"])
    }

    func testWorldStateForceIgnoresCache() {
        UserDefaults.standard.set(Date(), forKey: "lastWorldStateFetch")
        let disposable = repository.retrieveWorldState(force: true).observeValues { _ in }
        waitForRequests(1)
        disposable?.dispose()
    }
}
