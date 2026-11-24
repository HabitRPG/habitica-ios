//
//  UserAccountTests.swift
//  HabiticaTests
//
//  UserRepository: logout, inbox, and purchases/subscriptions.
//

import XCTest
import ReactiveSwift
import Habitica_Models
import Habitica_API_Client
import Habitica_Database
@testable import Habitica

class UserAccountTests: RepositoryTestCase {

    private var repository: UserRepository!
    private var feedback: RecordingFeedback!
    private let userLocal = UserLocalRepository()
    // kept alive: repository queries go through [weak self] and a temporary would answer nothing
    private let social = SocialRepository()
    private let friendID = "22222222-3333-4444-5555-666666666666"
    private var savedDefaults: [String: Any]?
    private let defaultsDomain = Bundle.main.bundleIdentifier ?? ""

    override func setUp() {
        super.setUp()
        // logout wipes the app's defaults, so keep a copy to put back
        savedDefaults = UserDefaults.standard.persistentDomain(forName: defaultsDomain)
        feedback = RecordingFeedback()
        repository = UserRepository()
        repository.feedback = feedback
    }

    override func tearDown() {
        UserManager.shared.logoutCompleted()
        UserManager.shared.beginListening()
        if let savedDefaults = savedDefaults {
            UserDefaults.standard.setPersistentDomain(savedDefaults, forName: defaultsDomain)
        }
        super.tearDown()
    }

    // MARK: Logout

    /// Logs out and returns how often the completion ran after `wait` seconds.
    private func logout(waitingUpTo timeout: TimeInterval = 5, thenDrain extra: TimeInterval = 0) -> Int {
        var completions = 0
        let done = expectation(description: "logged out")
        repository.logoutAccount {
            completions += 1
            if completions == 1 {
                done.fulfill()
            }
        }
        wait(for: [done], timeout: timeout)
        drain(extra)
        return completions
    }

    func testLogoutDeregistersPushDevice() throws {
        // regression: the token was read after the defaults holding it had been wiped
        try storeFixtureUser()
        UserDefaults.standard.set("token-1", forKey: "PushNotificationDeviceToken")
        stub("DELETE", "user/push-devices/token-1", data: "[]")
        XCTAssertEqual(logout(), 1)
        XCTAssertEqual(requestedPaths, ["DELETE user/push-devices/token-1"])
    }

    func testLogoutClearsCredentialsAndData() throws {
        try storeFixtureUser()
        XCTAssertEqual(logout(), 1)
        XCTAssertNil(AuthenticationManager.shared.currentUserId)
        XCTAssertNil(AuthenticationManager.shared.currentUserKey)
        XCTAssertFalse(userLocal.hasUserData(id: userID))
    }

    func testLogoutKeepsDeviceSettingsOnly() {
        UserDefaults.standard.set("dark", forKey: "themeMode")
        UserDefaults.standard.set("/inventory", forKey: "initialScreenURL")
        UserDefaults.standard.set("staging", forKey: "chosenServer")
        UserDefaults.standard.set("private", forKey: "someAccountSetting")
        XCTAssertEqual(logout(), 1)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "themeMode"), "dark")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "initialScreenURL"), "/inventory")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "chosenServer"), "staging")
        XCTAssertNil(UserDefaults.standard.string(forKey: "someAccountSetting"), "the next account must not inherit it")
    }

    func testLogoutFinishesOnceEvenIfServerHangs() throws {
        try storeFixtureUser()
        UserDefaults.standard.set("token-1", forKey: "PushNotificationDeviceToken")
        // answer only after the 3 second safety timeout, so both paths try to finish
        stub("DELETE", "user/push-devices/token-1", data: "[]", delay: 4)
        let start = Date()
        XCTAssertEqual(logout(waitingUpTo: 6, thenDrain: 1.5), 1)
        XCTAssertLessThan(Date().timeIntervalSince(start), 7)
        XCTAssertFalse(userLocal.hasUserData(id: userID))
    }

    func testLogoutWithoutUserJustClearsDatabase() throws {
        try storeFixtureUser()
        AuthenticationManager.shared.currentUserId = nil
        XCTAssertEqual(logout(), 1)
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
        XCTAssertFalse(userLocal.hasUserData(id: userID))
    }

    func testSecondLogoutWhileLoggingOutReturnsRightAway() throws {
        try storeFixtureUser()
        UserManager.shared.prepareForLogout()
        var completed = false
        repository.logoutAccount { completed = true }
        XCTAssertTrue(completed, "no second teardown while one is running")
        XCTAssertTrue(userLocal.hasUserData(id: userID))
        XCTAssertEqual(AuthenticationManager.shared.currentUserId, userID)
    }

    // MARK: Inbox

    private func storedMessages(with user: String) -> [InboxMessageProtocol] {
        return firstValue(social.getMessages(withUserID: user))?.value ?? []
    }

    func testRetrievedMessagesAreStoredPerConversation() {
        stub("GET", "inbox/messages", data: #"[{"id":"m1","uuid":"\#(friendID)","text":"Hi","timestamp":"2024-01-02T00:00:00.000Z"},{"id":"m2","uuid":"\#(friendID)","text":"Hello","timestamp":"2024-01-01T00:00:00.000Z"}]"#)
        firstValue(repository.retrieveInboxMessages(conversationID: friendID, page: 0))
        drain()
        XCTAssertEqual(storedMessages(with: friendID).compactMap(\.text), ["Hi", "Hello"], "newest first")
        XCTAssertEqual(StubURLProtocol.requests.first?.url?.query, "conversation=\(friendID)&page=0")
        XCTAssertTrue(storedMessages(with: "someone-else").isEmpty)
    }

    func testRefetchedMessageKeepsItsTime() throws {
        stub("GET", "inbox/messages", data: #"[{"id":"m1","uuid":"\#(friendID)","text":"Hi","timestamp":"2024-01-02T00:00:00.000Z"}]"#)
        firstValue(repository.retrieveInboxMessages(conversationID: friendID, page: 0))
        drain()
        let original = try XCTUnwrap(storedMessages(with: friendID).first?.timestamp)
        // a later answer without a time must not make the old message look new
        stub("GET", "inbox/messages", data: #"[{"id":"m1","uuid":"\#(friendID)","text":"Hi"}]"#)
        firstValue(repository.retrieveInboxMessages(conversationID: friendID, page: 0))
        drain()
        XCTAssertEqual(storedMessages(with: friendID).first?.timestamp, original)
    }

    func testMessageWithoutTimeIsTreatedAsNew() throws {
        stub("GET", "inbox/messages", data: #"[{"id":"m1","uuid":"\#(friendID)","text":"Hi"}]"#)
        firstValue(repository.retrieveInboxMessages(conversationID: friendID, page: 0))
        drain()
        let time = try XCTUnwrap(storedMessages(with: friendID).first?.timestamp)
        XCTAssertLessThan(abs(time.timeIntervalSinceNow), 5)
    }

    func testRetrievedConversationsAreStored() {
        stub("GET", "inbox/conversations", data: #"[{"uuid":"a","text":"old","timestamp":1000},{"uuid":"b","text":"new","timestamp":2000}]"#)
        firstValue(repository.retrieveInboxConversations())
        drain()
        let threads = firstValue(social.getMessagesThreads())?.value ?? []
        XCTAssertEqual(threads.compactMap(\.text), ["new", "old"])
    }

    func testSendingMessageReloadsConversation() throws {
        stub("POST", "members/send-private-message", data: "{}")
        stub("GET", "inbox/messages", data: #"[{"id":"m1","uuid":"\#(friendID)","text":"Hey"}]"#)
        firstValue(social.post(inboxMessage: "Hey", toUserID: friendID))
        XCTAssertEqual(requestedPaths, ["POST members/send-private-message", "GET inbox/messages"])
        let body = try requestBody()
        XCTAssertEqual(body["message"] as? String, "Hey")
        XCTAssertEqual(body["toUserId"] as? String, friendID)
    }

    func testDeletingMessageRemovesIt() throws {
        stub("GET", "inbox/messages", data: #"[{"id":"m1","uuid":"\#(friendID)","text":"Hi"}]"#)
        firstValue(repository.retrieveInboxMessages(conversationID: friendID, page: 0))
        drain()
        let message = try XCTUnwrap(storedMessages(with: friendID).first)
        stub("DELETE", "inbox/messages/m1", data: "{}")
        firstValue(social.delete(message: message))
        drain()
        XCTAssertTrue(storedMessages(with: friendID).isEmpty)
    }

    func testMarkingInboxSeenResetsUnreadCount() throws {
        let json = try userJSON().replacingOccurrences(of: #""newMessages":0"#, with: #""newMessages":5"#)
        userLocal.save(try JSONDecoder().decode(APIUser.self, from: Data(json.utf8)))
        XCTAssertEqual(userLocal.getUserAsync(userID)?.inbox?.numberNewMessages, 5)
        stub("POST", "user/mark-pms-read", data: "{}")
        firstValue(social.markInboxAsSeen())
        drain()
        XCTAssertEqual(userLocal.getUserAsync(userID)?.inbox?.numberNewMessages, 0)
    }

    // MARK: Purchases and subscriptions

    func testSubscribeSendsReceiptRefetchesAndIgnoresRepeats() throws {
        // one test because the throttle is shared by every UserRepository for 15 seconds
        stub("POST", "iap/ios/subscribe", data: "{}")
        stub("GET", "user", data: try userJSON())
        firstValue(repository.subscribe(sku: "com.habitrpg.ios.habitica.subscription.1month", receipt: "receipt-data"))
        XCTAssertEqual(requestedPaths, ["POST iap/ios/subscribe", "GET user"])
        let body = try requestBody()
        XCTAssertEqual(body["sku"] as? String, "com.habitrpg.ios.habitica.subscription.1month")
        XCTAssertEqual(body["receipt"] as? String, "receipt-data")

        assertEmpty(UserRepository().subscribe(sku: "com.habitrpg.ios.habitica.subscription.1month", receipt: "receipt-data"))
        XCTAssertEqual(StubURLProtocol.requests.count, 2, "a double tap must not subscribe twice")
    }

    func testCancelSubscriptionRefetchesUser() throws {
        stub("GET", "iap/ios/subscribe/cancel", data: "{}")
        stub("GET", "user", data: try userJSON())
        firstValue(repository.cancelSubscription())
        XCTAssertEqual(requestedPaths, ["GET iap/ios/subscribe/cancel", "GET user"])
    }

    func testGemPurchaseResultIsPassedOn() throws {
        stub("POST", "iap/ios/verify", data: "{}")
        let success = firstValue(repository.purchaseGems(receipt: ["receipt": "r"], recipient: friendID))
        XCTAssertEqual(success??.success, true)
        let body = try requestBody()
        XCTAssertEqual((body["transaction"] as? [String: String])?["receipt"], "r")
        XCTAssertEqual((body["gift"] as? [String: String])?["uuid"], friendID)

        stub("POST", "iap/ios/verify", status: 401, data: "null")
        let failure = firstValue(repository.purchaseGems(receipt: ["receipt": "r"]))
        XCTAssertNil(failure ?? nil, "the store flow must learn the purchase was not verified")
        XCTAssertNil(try requestBody(1)["gift"], "own purchases are not gifts")
    }

    func testSendingGems() throws {
        stub("POST", "members/transfer-gems", data: "{}")
        firstValue(repository.sendGems(amount: 12, recipient: friendID))
        let body = try requestBody()
        XCTAssertEqual(body["gemAmount"] as? Int, 12)
        XCTAssertEqual(body["toUserId"] as? String, friendID)
    }

    func testGiftedSubscription() throws {
        stub("POST", "iap/ios/norenew-subscribe", data: "{}")
        firstValue(repository.purchaseNoRenewSubscription(identifier: "com.habitrpg.ios.habitica.norenew.3month", receipt: ["receipt": "r"], recipient: friendID))
        let body = try requestBody()
        XCTAssertEqual(body["sku"] as? String, "com.habitrpg.ios.habitica.norenew.3month")
        XCTAssertEqual((body["gift"] as? [String: String])?["uuid"], friendID)
    }

    func testGroupPlansAreStored() {
        stub("GET", "group-plans", data: #"[{"id":"plan-1","name":"Family"}]"#)
        firstValue(repository.retrieveGroupPlans())
        drain()
        XCTAssertEqual(firstValue(repository.getGroupPlans())?.value.compactMap(\.name), ["Family"])
    }
}
