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

private class TestSkill: SkillProtocol {
    var key: String?
    var text: String?
    var notes: String?
    var mana: Int
    var level = 1
    var target: String?
    var habitClass: String?
    var value: Float = 0
    var immediateUse = false
    var silent = false

    init(key: String, text: String, mana: Int, target: String = "self") {
        self.key = key
        self.text = text
        self.mana = mana
        self.target = target
    }
}

private class TestSpecialItem: SpecialItemProtocol {
    var key: String?
    var text: String?
    var notes: String?
    var value: Float = 0
    var itemType: String? = "special"
    var isSubscriberItem = false
    var eventStart: Date?
    var eventEnd: Date?
    var target: String? = "user"
    var immediateUse = false
    var silent = false
    var isValid = true
    var isManaged = false

    init(key: String, text: String) {
        self.key = key
        self.text = text
    }
}

class UserRepositoryTests: RepositoryTestCase {

    private var repository: UserRepository!
    private var feedback: RecordingFeedback!
    private let local = UserLocalRepository()
    private var originalPushToken: String?

    override func setUp() {
        super.setUp()
        feedback = RecordingFeedback()
        repository = UserRepository()
        repository.feedback = feedback
        originalPushToken = UserDefaults.standard.string(forKey: "PushNotificationDeviceToken")
    }

    override func tearDown() {
        UserDefaults.standard.set(originalPushToken, forKey: "PushNotificationDeviceToken")
        super.tearDown()
    }

    private func storeUser() throws {
        try storeFixtureUser()
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

    // MARK: Skills and items

    func testUsingSkillShowsCostAndSavesResult() throws {
        try storeUser()
        stub("POST", "user/class/cast/fireball", data: #"{"user":{"stats":{"mp":20}}}"#)
        let response = firstValue(repository.useSkill(skill: TestSkill(key: "fireball", text: "Burst of Flames", mana: 10, target: "task"), targetId: "t1"))
        XCTAssertNotNil(response ?? nil)
        XCTAssertEqual(feedback.skillsUsed.map(\.name), ["Burst of Flames"])
        XCTAssertEqual(feedback.skillsUsed.map(\.mana), [10])
        XCTAssertEqual(feedback.haptics, [.success])
        XCTAssertTrue(feedback.questDamage.isEmpty, "no quest progress in the response")
        XCTAssertEqual(StubURLProtocol.requests.first?.url?.query, "targetType=task&targetId=t1")
    }

    func testSkillQuestDamageIsTheProgressGained() throws {
        // the fixture user has 360.35 boss damage pending
        try storeUser()
        stub("POST", "user/class/cast/fireball", data: #"{"user":{"party":{"quest":{"progress":{"up":400.35}}}}}"#)
        firstValue(repository.useSkill(skill: TestSkill(key: "fireball", text: "Burst of Flames", mana: 10)))
        XCTAssertEqual(feedback.questDamage.count, 1)
        XCTAssertEqual(feedback.questDamage.first ?? 0, 40, accuracy: 0.01)
    }

    func testFailedSkillShowsNothing() throws {
        try storeUser()
        stub("POST", "user/class/cast/fireball", status: 401, data: "null")
        let disposable = repository.useSkill(skill: TestSkill(key: "fireball", text: "Burst of Flames", mana: 10)).observeValues { _ in }
        waitForRequests(1)
        drain()
        disposable?.dispose()
        XCTAssertTrue(feedback.nothingShown)
        XCTAssertTrue(feedback.haptics.isEmpty)
    }

    func testTransformationItemOnSelfUsesItemAndRefetches() throws {
        try storeUser()
        stub("POST", "user/class/cast/seafoam", data: "{}")
        // the refetch stays unanswered so it can't restore the fixture's item count
        let disposable = repository.useTransformationItem(item: TestSpecialItem(key: "seafoam", text: "Seafoam"), targetId: userID).observeValues { _ in }
        waitForRequests(2)
        drain()
        disposable?.dispose()
        XCTAssertEqual(feedback.toastTexts, [L10n.Skills.usedTransformationItem("Seafoam")])
        XCTAssertTrue(requestedPaths.contains("GET user"), "using it on yourself changes your own avatar")
        let seafoam = storedUser?.items?.ownedSpecialItems.first { $0.key == "seafoam" }
        XCTAssertEqual(seafoam?.numberOwned, 1, "the fixture user had 2")
    }

    func testTransformationItemOnOthersDoesNotRefetch() throws {
        try storeUser()
        stub("POST", "user/class/cast/seafoam", data: "{}")
        let disposable = repository.useTransformationItem(item: TestSpecialItem(key: "seafoam", text: "Seafoam"), targetId: "friend").observeValues { _ in }
        waitForRequests(1)
        drain()
        disposable?.dispose()
        XCTAssertEqual(requestedPaths, ["POST user/class/cast/seafoam"])
        XCTAssertEqual(feedback.toastTexts, [L10n.Skills.usedTransformationItem("Seafoam")])
    }

    // MARK: Account

    func testPasswordChangeStoresNewTokenAndConfirms() {
        stub("PUT", "user/auth/update-password", data: #"{"id":"\#(userID)","apiToken":"rotated-key"}"#)
        firstValue(repository.updatePassword(newPassword: "new", password: "old", confirmPassword: "new"))
        XCTAssertEqual(AuthenticationManager.shared.currentUserKey, "rotated-key")
        XCTAssertEqual(feedback.toastTexts, [L10n.Settings.updatedPassword])
    }

    func testFailedPasswordChangeKeepsToken() {
        stub("PUT", "user/auth/update-password", status: 400, data: "null")
        let disposable = repository.updatePassword(newPassword: "new", password: "wrong", confirmPassword: "new").observeValues { _ in }
        waitForRequests(1)
        drain()
        disposable?.dispose()
        XCTAssertEqual(AuthenticationManager.shared.currentUserKey, apiKey)
        XCTAssertTrue(feedback.toasts.isEmpty)
    }

    func testRevivingNamesTheGearThatBroke() throws {
        try storeUser()
        let gear = #"{"gear":{"flat":{"headAccessory_special_blackHeadband":{"key":"headAccessory_special_blackHeadband","text":"Black Headband","type":"headAccessory"}}}}"#
        ContentLocalRepository().save(try JSONDecoder().decode(APIContent.self, from: Data(gear.utf8)))
        stub("POST", "user/revive", data: #"{"gear":{"owned":{"headAccessory_special_blackHeadband":false,"headAccessory_special_blueHeadband":true}}}"#)
        stub("GET", "user", data: try userJSON())
        let disposable = repository.revive().observeValues { _ in }
        waitForRequests(2)
        drain()
        disposable?.dispose()
        XCTAssertEqual(feedback.brokenItems, ["Black Headband"])
    }

    func testRevivingWithoutLosingGearShowsNothing() throws {
        try storeUser()
        stub("POST", "user/revive", data: #"{"gear":{"owned":{"headAccessory_special_blueHeadband":true}}}"#)
        let disposable = repository.revive().observeValues { _ in }
        waitForRequests(2)
        drain()
        disposable?.dispose()
        XCTAssertTrue(feedback.brokenItems.isEmpty)
    }

    func testRerollConfirmsAndRefetches() {
        stub("POST", "user/reroll", data: "{}")
        let disposable = repository.reroll().observeValues { _ in }
        waitForRequests(2)
        disposable?.dispose()
        XCTAssertEqual(feedback.toastTexts, [L10n.purchased("Fortify Potion")])
        XCTAssertTrue(requestedPaths.contains("GET user"))
    }

    func testRebirthSavesReturnedUser() throws {
        try storeUser()
        stub("POST", "user/rebirth", data: #"{"id":"\#(userID)","balance":3}"#)
        let disposable = repository.rebirth().observeValues { _ in }
        waitForRequests(2)
        drain()
        disposable?.dispose()
        XCTAssertEqual(storedUser?.balance, 3)
    }

    // MARK: Class selection

    func testSelectingClassShowsConfirmation() {
        stub("POST", "user/change-class", data: "{}")
        let disposable = repository.selectClass(.rogue).observeValues { _ in }
        waitForRequests(1)
        drain()
        disposable?.dispose()
        XCTAssertEqual(feedback.selectedClasses, [.rogue])
        XCTAssertEqual(StubURLProtocol.requests.first?.url?.query, "class=rogue")
    }

    func testFailedOrClearedClassSelectionShowsNothing() {
        stub("POST", "user/change-class", status: 401, data: "null")
        let failed = repository.selectClass(.rogue).observeValues { _ in }
        waitForRequests(1)
        drain()
        failed?.dispose()
        repository.lastClassSelection = nil
        stub("POST", "user/change-class", data: "{}")
        let cleared = repository.selectClass(nil).observeValues { _ in }
        waitForRequests(2)
        drain()
        cleared?.dispose()
        XCTAssertTrue(feedback.selectedClasses.isEmpty)
    }
}
