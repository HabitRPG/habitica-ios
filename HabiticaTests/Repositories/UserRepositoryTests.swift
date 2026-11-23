//
//  UserRepositoryTests.swift
//  HabiticaTests
//

import XCTest
import ReactiveSwift
import Habitica_Models
import Habitica_API_Client
import Habitica_Database
@testable import Habitica

class UserRepositoryTests: RepositoryTestCase {

    private var repository: UserRepository!
    private let local = UserLocalRepository()
    private var originalPushToken: String?

    override func setUp() {
        super.setUp()
        repository = UserRepository()
        originalPushToken = UserDefaults.standard.string(forKey: "PushNotificationDeviceToken")
    }

    override func tearDown() {
        UserDefaults.standard.set(originalPushToken, forKey: "PushNotificationDeviceToken")
        super.tearDown()
    }

    /// The fixture user, owned by the test user ID.
    private func userJSON() throws -> String {
        return try fixture("user").replacingOccurrences(of: "\"MOCK\"", with: "\"\(userID)\"")
    }

    private func storeUser() throws {
        let user = try JSONDecoder().decode(APIUser.self, from: Data(try userJSON().utf8))
        local.save(user)
        XCTAssertTrue(repository.hasUserData())
    }

    private var storedUser: UserProtocol? {
        return local.getUserAsync(userID)
    }

    // MARK: Fetching

    func testRetrieveUserSavesIt() throws {
        XCTAssertFalse(repository.hasUserData())
        stub("GET", "user", data: try userJSON())
        let user = firstValue(repository.retrieveUser(withTasks: false))
        XCTAssertEqual(user??.id, userID)
        drain()
        XCTAssertTrue(repository.hasUserData())
        XCTAssertEqual(storedUser?.balance, 20.75)
    }

    func testRetrieveUserWithTasksWaitsForBoth() throws {
        stub("GET", "user", data: try userJSON())
        stub("GET", "tasks/user", data: #"[{"_id":"t1","type":"todo"}]"#)
        let user = firstValue(repository.retrieveUser(withTasks: true))
        XCTAssertEqual(user??.id, userID)
        XCTAssertEqual(Set(requestedPaths), ["GET user", "GET tasks/user"])
    }

    func testHasUserDataWithoutLoggedInUser() {
        AuthenticationManager.shared.currentUserId = nil
        XCTAssertFalse(repository.hasUserData())
    }

    func testAllocateSavesNewStats() throws {
        try storeUser()
        stub("POST", "user/allocate", data: #"{"str":42,"int":1,"con":2,"per":3,"lvl":50}"#)
        firstValue(repository.allocate(attributePoint: "str"))
        drain()
        XCTAssertEqual(storedUser?.stats?.strength, 42)
        XCTAssertEqual(StubURLProtocol.requests.first?.url?.query, "stat=str")
    }

    func testSleepTogglesLocalState() throws {
        try storeUser()
        let wasSleeping = storedUser?.preferences?.sleep ?? false
        stub("POST", "user/sleep", data: "true")
        firstValue(repository.sleep())
        drain()
        XCTAssertEqual(storedUser?.preferences?.sleep, !wasSleeping)
    }

    // MARK: Authentication

    func testLoginStoresCredentials() throws {
        stub("POST", "user/auth/local/login", data: #"{"id":"new-user","apiToken":"new-key","newUser":false}"#)
        let disposable = repository.login(username: "name", password: "secret").observeValues { _ in }
        waitForRequests(1)
        drain()
        disposable?.dispose()
        XCTAssertEqual(AuthenticationManager.shared.currentUserId, "new-user")
        XCTAssertEqual(AuthenticationManager.shared.currentUserKey, "new-key")
        let body = try requestBody()
        XCTAssertEqual(body["username"] as? String, "name")
        XCTAssertEqual(body["password"] as? String, "secret")
    }

    func testLoginWithEmptyCredentialsKeepsExistingOnes() {
        stub("POST", "user/auth/local/login", data: #"{"id":"","apiToken":""}"#)
        let disposable = repository.login(username: "name", password: "secret").observeValues { _ in }
        waitForRequests(1)
        drain()
        disposable?.dispose()
        XCTAssertEqual(AuthenticationManager.shared.currentUserId, userID)
        XCTAssertEqual(AuthenticationManager.shared.currentUserKey, apiKey)
    }

    func testFailedLoginEmitsNilAndKeepsCredentials() {
        stub("POST", "user/auth/local/login", status: 401, data: "null")
        let response = firstValue(repository.login(username: "name", password: "wrong"))
        XCTAssertNotNil(response, "the UI needs a value to stop its spinner")
        XCTAssertNil(response!)
        XCTAssertEqual(AuthenticationManager.shared.currentUserId, userID)
    }

    func testSocialLoginForUnknownAccountReportsNewUser() {
        stub("POST", "user/auth/social", status: 404, data: "null")
        let response = firstValue(repository.login(userID: "", network: "google", accessToken: "token", allowRegister: false))
        XCTAssertEqual(response??.newUser, true)
        XCTAssertEqual(AuthenticationManager.shared.currentUserId, userID)
    }

    // MARK: Throttling

    func testSelectClassIgnoresDoubleTap() {
        // a failing class change avoids the confirmation sheet; the throttle is what's under test
        stub("POST", "user/change-class", status: 500, data: "null")
        let first = repository.selectClass(.warrior).observeValues { _ in }
        assertEmpty(repository.selectClass(.warrior))
        waitForRequests(1)
        drain()
        first?.dispose()
        XCTAssertEqual(requestedPaths.filter { $0.hasPrefix("POST") }, ["POST user/change-class"])
    }

    func testDisableClassesIgnoresDoubleTap() {
        stub("POST", "user/disable-classes", data: "{}")
        let first = repository.disableClassSystem().observeValues { _ in }
        assertEmpty(repository.disableClassSystem())
        waitForRequests(1)
        first?.dispose()
    }

    // MARK: Push devices

    private func user(pushDevices: String) throws -> UserProtocol {
        return try JSONDecoder().decode(APIUser.self, from: Data(#"{"id":"u","pushDevices":\#(pushDevices)}"#.utf8))
    }

    func testPushDeviceRegistersUnknownToken() throws {
        UserDefaults.standard.set("token-1", forKey: "PushNotificationDeviceToken")
        stub("POST", "user/push-devices", data: "[]")
        firstValue(repository.registerPushDevice(user: try user(pushDevices: "[]")))
        XCTAssertEqual(requestedPaths, ["POST user/push-devices"])
        XCTAssertEqual(try requestBody()["regId"] as? String, "token-1")
    }

    func testPushDeviceSkipsKnownToken() throws {
        UserDefaults.standard.set("token-1", forKey: "PushNotificationDeviceToken")
        assertEmpty(repository.registerPushDevice(user: try user(pushDevices: #"[{"regId":"token-1","type":"ios"}]"#)))
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testPushDeviceWithoutTokenDoesNothing() throws {
        UserDefaults.standard.removeObject(forKey: "PushNotificationDeviceToken")
        assertEmpty(repository.registerPushDevice(user: try user(pushDevices: "[]")))
        assertEmpty(repository.deregisterPushDevice())
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testPushDeviceRegistrationIsThrottled() throws {
        UserDefaults.standard.set("token-1", forKey: "PushNotificationDeviceToken")
        stub("POST", "user/push-devices", data: "[]")
        firstValue(repository.registerPushDevice(user: try user(pushDevices: "[]")))
        assertEmpty(repository.registerPushDevice(user: try user(pushDevices: "[]")))
        XCTAssertEqual(StubURLProtocol.requests.count, 1)
    }

    // MARK: Notifications

    private func notificationCount() -> Int {
        return firstValue(repository.getNotifications())?.value.count ?? -1
    }

    func testReadingInviteNotificationOnlyDeletesLocally() {
        let invite = repository.createNotification(id: "party-invite-123", type: .groupInvite)
        local.save(userID: userID, notifications: [invite])
        XCTAssertEqual(notificationCount(), 1)
        let stored = firstValue(repository.getNotifications())!.value[0]
        assertEmpty(repository.readNotification(notification: stored))
        XCTAssertEqual(notificationCount(), 0)
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testReadingNotificationAsksServer() {
        let notification = repository.createNotification(id: "abc", type: .newStuff)
        local.save(userID: userID, notifications: [notification])
        stub("POST", "notifications/abc/read", data: "[]")
        let stored = firstValue(repository.getNotifications())!.value[0]
        firstValue(repository.readNotification(notification: stored))
        XCTAssertEqual(requestedPaths, ["POST notifications/abc/read"])
    }
}
