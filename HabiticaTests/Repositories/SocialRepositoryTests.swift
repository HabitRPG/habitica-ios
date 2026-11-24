//
//  SocialRepositoryTests.swift
//  HabiticaTests
//

import XCTest
import ReactiveSwift
import Habitica_Models
import Habitica_Database
import Habitica_API_Client
@testable import Habitica

class SocialRepositoryTests: RepositoryTestCase {

    private var repository: SocialRepository!
    private var feedback: RecordingFeedback!
    private let local = SocialLocalRepository()

    override func setUp() {
        super.setUp()
        feedback = RecordingFeedback()
        repository = SocialRepository()
        repository.feedback = feedback
    }

    private func run<T>(_ signal: Signal<T, Never>, requests: Int = 1) {
        let disposable = signal.observeValues { _ in }
        waitForRequests(requests)
        drain()
        disposable?.dispose()
    }

    private func isGroupMember(_ groupID: String) -> Bool? {
        return firstValue(repository.isUserGuildMember(groupID: groupID))
    }

    private func isChallengeMember(_ challengeID: String) -> Bool {
        let membership = firstValue(local.getChallengeMembership(userID: userID, challengeID: challengeID))
        return (membership ?? nil) != nil
    }

    // MARK: Groups

    func testJoinGroup() {
        stub("POST", "groups/guild-1/join", data: #"{"_id":"guild-1","type":"guild","name":"Guild"}"#)
        firstValue(repository.joinGroup(groupID: "guild-1", isParty: false))
        drain()
        XCTAssertEqual(isGroupMember("guild-1"), true)
        XCTAssertEqual(feedback.toastTexts, [L10n.Guilds.joinedGuild])
        XCTAssertEqual(feedback.haptics, [.selection])
    }

    func testJoinPartyUsesPartyWording() {
        stub("POST", "groups/party-1/join", data: #"{"_id":"party-1","type":"party"}"#)
        firstValue(repository.joinGroup(groupID: "party-1", isParty: true))
        XCTAssertEqual(feedback.toastTexts, [L10n.Guilds.joinedParty])
    }

    func testRefusedJoinChangesNothing() {
        stub("POST", "groups/guild-1/join", status: 401, data: "null")
        run(repository.joinGroup(groupID: "guild-1", isParty: false))
        XCTAssertEqual(isGroupMember("guild-1"), false)
        XCTAssertTrue(feedback.toasts.isEmpty)
    }

    func testLeaveGroup() {
        stub("POST", "groups/guild-1/join", data: #"{"_id":"guild-1","type":"guild"}"#)
        stub("POST", "groups/guild-1/leave", data: "{}")
        firstValue(repository.joinGroup(groupID: "guild-1", isParty: false))
        firstValue(repository.leaveGroup(groupID: "guild-1", leaveChallenges: true, isParty: false))
        drain()
        XCTAssertEqual(isGroupMember("guild-1"), false)
        XCTAssertEqual(feedback.toastTexts.last, L10n.Guilds.leftGuild)
        XCTAssertEqual(try requestBody(1)["keepChallenges"] as? String, "leave-challenges")
    }

    func testRefusedLeaveKeepsMembership() {
        stub("POST", "groups/guild-1/join", data: #"{"_id":"guild-1","type":"guild"}"#)
        stub("POST", "groups/guild-1/leave", status: 401, data: "null")
        firstValue(repository.joinGroup(groupID: "guild-1", isParty: false))
        run(repository.leaveGroup(groupID: "guild-1", leaveChallenges: false, isParty: false), requests: 2)
        XCTAssertEqual(isGroupMember("guild-1"), true)
        XCTAssertEqual(feedback.toastTexts, [L10n.Guilds.joinedGuild])
    }

    func testFailedInviteBuzzesOnly() {
        // the server's message is shown by the global network error handler, not by the repository
        stubRaw("POST", "groups/party-1/invite", status: 400, body: #"{"success":false,"error":"BadRequest","message":"Already invited"}"#)
        run(repository.invite(toGroup: "party-1", members: ["usernames": ["friend"]]))
        XCTAssertTrue(feedback.toasts.isEmpty)
        XCTAssertEqual(feedback.haptics, [.error])
    }

    func testSuccessfulInviteOnlyBuzzes() {
        stub("POST", "groups/party-1/invite", data: "[]")
        run(repository.invite(toGroup: "party-1", members: ["usernames": ["friend"]]))
        XCTAssertTrue(feedback.toasts.isEmpty)
        XCTAssertEqual(feedback.haptics, [.success])
    }

    // MARK: Challenges

    func testJoinChallengeIsOptimistic() {
        stub("POST", "challenges/c1/join", data: #"{"id":"c1","name":"Challenge"}"#, delay: 1)
        let disposable = repository.joinChallenge(challengeID: "c1").observeValues { _ in }
        XCTAssertTrue(isChallengeMember("c1"), "the UI updates before the server answers")
        waitForRequests(1)
        drain(1.5)
        disposable?.dispose()
        XCTAssertTrue(isChallengeMember("c1"))
        XCTAssertEqual(feedback.toastTexts, [L10n.joinedChallenge])
    }

    func testRefusedJoinChallengeIsRolledBack() {
        // regression: the optimistic join was never undone when the server refused
        stub("POST", "challenges/c1/join", status: 401, data: "null")
        run(repository.joinChallenge(challengeID: "c1"))
        XCTAssertFalse(isChallengeMember("c1"))
        XCTAssertTrue(feedback.toasts.isEmpty)
    }

    func testLeaveChallenge() {
        local.joinChallenge(userID: userID, challengeID: "c1", challenge: nil)
        stub("POST", "challenges/c1/leave", data: "{}")
        firstValue(repository.leaveChallenge(challengeID: "c1", keepTasks: true))
        drain()
        XCTAssertFalse(isChallengeMember("c1"))
        XCTAssertEqual(feedback.toastTexts, [L10n.leftChallenge])
        XCTAssertEqual(try requestBody()["keep"] as? String, "keep-all")
    }

    func testRefusedLeaveChallengeIsRolledBack() {
        local.joinChallenge(userID: userID, challengeID: "c1", challenge: nil)
        stub("POST", "challenges/c1/leave", status: 401, data: "null", delay: 1)
        let disposable = repository.leaveChallenge(challengeID: "c1", keepTasks: false).observeValues { _ in }
        XCTAssertFalse(isChallengeMember("c1"), "the UI updates before the server answers")
        waitForRequests(1)
        drain(1.5)
        disposable?.dispose()
        XCTAssertTrue(isChallengeMember("c1"))
        XCTAssertTrue(feedback.toasts.isEmpty)
    }

    func testCreatedChallengeIsSavedWithLeaderAndGroup() throws {
        // the server answers without leader and group; they are filled from the request and the current user
        stub("POST", "challenges", status: 201, data: #"{"id":"new-c","name":"Mine"}"#)
        let challenge = local.getNewChallenge()
        challenge.name = "Mine"
        challenge.groupID = "party-1"
        let expectation = expectation(description: "created")
        var created: ChallengeProtocol?
        repository.createChallenge(challenge: challenge).take(first: 1).observeResult { result in
            created = try? result.get()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(created?.id, "new-c")
        drain()
        let stored = try XCTUnwrap(firstValue(local.getChallenge(challengeID: "new-c")) ?? nil)
        XCTAssertEqual(stored.leaderID, userID)
        XCTAssertEqual(stored.groupID, "party-1")
    }

    func testRejectedChallengeCreationFails() {
        stub("POST", "challenges", status: 400, data: "null")
        let expectation = expectation(description: "failed")
        repository.createChallenge(challenge: local.getNewChallenge()).observeFailed { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 5)
    }

    // MARK: Group and challenge caching

    func testRetrievedGuildsBecomeMemberships() {
        stub("GET", "groups", data: #"[{"_id":"g1","type":"guild","name":"One"},{"_id":"g2","type":"guild","name":"Two"}]"#)
        firstValue(repository.retrieveGroups("guilds"))
        drain()
        XCTAssertEqual(isGroupMember("g1"), true)
        XCTAssertEqual(isGroupMember("g2"), true)
        XCTAssertEqual(StubURLProtocol.requests.first?.url?.query, "type=guilds")
    }

    func testRetrievedPublicGroupsAreNotMemberships() {
        stub("GET", "groups", data: #"[{"_id":"g1","type":"guild","name":"One"}]"#)
        firstValue(repository.retrieveGroups("publicGuilds"))
        drain()
        XCTAssertEqual(isGroupMember("g1"), false)
    }

    func testGroupGoneOnServerIsRemovedLocally() throws {
        stub("GET", "groups/g1", data: #"{"_id":"g1","type":"guild","name":"One"}"#)
        firstValue(repository.retrieveGroup(groupID: "g1"))
        drain()
        XCTAssertNotNil(firstValue(repository.getGroup(groupID: "g1")) ?? nil)

        stub("GET", "groups/g1", status: 404, data: "null")
        let disposable = repository.retrieveGroup(groupID: "g1").observeValues { _ in }
        waitForRequests(2)
        drain()
        disposable?.dispose()
        XCTAssertNil(firstValue(repository.getGroup(groupID: "g1")) ?? nil)
    }

    func testServerErrorKeepsCachedGroup() {
        stub("GET", "groups/g1", data: #"{"_id":"g1","type":"guild","name":"One"}"#)
        firstValue(repository.retrieveGroup(groupID: "g1"))
        stub("GET", "groups/g1", status: 500, data: "null")
        let disposable = repository.retrieveGroup(groupID: "g1").observeValues { _ in }
        waitForRequests(2)
        drain()
        disposable?.dispose()
        XCTAssertNotNil(firstValue(repository.getGroup(groupID: "g1")) ?? nil, "a temporary outage must not drop the guild")
    }

    func testGetGroupFetchesOnlyWhenMissing() {
        stub("GET", "groups/g1", data: #"{"_id":"g1","type":"guild","name":"One"}"#)
        let fetched = firstValue(repository.getGroup(groupID: "g1", retrieveIfNotFound: true))
        XCTAssertEqual(fetched??.name, "One")
        drain()
        firstValue(repository.getGroup(groupID: "g1", retrieveIfNotFound: true))
        XCTAssertEqual(requestedPaths, ["GET groups/g1"])
    }

    private var storedChallengeIDs: Set<String> {
        return Set(firstValue(repository.getChallenges(predicate: nil))?.value.compactMap(\.id) ?? [])
    }

    func testFirstChallengePageReplacesCache() {
        stub("GET", "challenges/user", data: #"[{"id":"c1","name":"One"}]"#)
        firstValue(repository.retrieveChallenges(page: 0, memberOnly: false))
        stub("GET", "challenges/user", data: #"[{"id":"c2","name":"Two"}]"#)
        firstValue(repository.retrieveChallenges(page: 1, memberOnly: false))
        drain()
        XCTAssertEqual(storedChallengeIDs, ["c1", "c2"], "later pages add to the list")

        stub("GET", "challenges/user", data: #"[{"id":"c3","name":"Three"}]"#)
        firstValue(repository.retrieveChallenges(page: 0, memberOnly: true))
        drain()
        XCTAssertEqual(storedChallengeIDs, ["c3"], "a fresh first page starts over")
        XCTAssertEqual(StubURLProtocol.requests.last?.url?.query, "page=0&member=true")
    }

    func testFirstPageCanKeepCache() {
        stub("GET", "challenges/user", data: #"[{"id":"c1","name":"One"}]"#)
        firstValue(repository.retrieveChallenges(page: 0, memberOnly: false))
        stub("GET", "challenges/user", data: #"[{"id":"c2","name":"Two"}]"#)
        firstValue(repository.retrieveChallenges(page: 0, memberOnly: false, clearCache: false))
        drain()
        XCTAssertEqual(storedChallengeIDs, ["c1", "c2"])
    }

    // MARK: Chat

    private func postMessage(_ text: String = "Hello", groupID: String = "g1") throws -> ChatMessageProtocol {
        stub("POST", "groups/\(groupID)/chat", data: #"{"id":"m1","text":"\#(text)","timestamp":0,"flagCount":0}"#)
        firstValue(repository.post(chatMessage: text, toGroup: groupID))
        drain()
        return try XCTUnwrap(firstValue(repository.getChatMessages(groupID: groupID))?.value.first)
    }

    func testPostedMessageIsStoredWithCurrentTime() throws {
        let message = try postMessage()
        XCTAssertEqual(message.text, "Hello")
        // the server's timestamp is replaced so the message sorts as just sent
        XCTAssertLessThan(abs(message.timestamp?.timeIntervalSinceNow ?? 1000), 5)
        XCTAssertEqual(try requestBody()["message"] as? String, "Hello")
    }

    func testDeletedMessageIsRemovedLocally() throws {
        let message = try postMessage()
        stub("DELETE", "groups/g1/chat/m1", data: "{}")
        firstValue(repository.delete(groupID: "g1", chatMessage: message))
        drain()
        XCTAssertEqual(firstValue(repository.getChatMessages(groupID: "g1"))?.value.count, 0)
    }

    func testFlaggingPartyMessageWithoutGroupIDUsesParty() throws {
        let message = try postMessage()
        stub("POST", "groups/party/chat/m1/flag", data: "{}")
        firstValue(repository.flag(groupID: "", chatMessage: message, reason: "spam"))
        XCTAssertEqual(requestedPaths.last, "POST groups/party/chat/m1/flag")
        XCTAssertEqual(try requestBody(StubURLProtocol.requests.count - 1)["comment"] as? String, "spam")
    }

    // MARK: Members

    private let friendID = "22222222-3333-4444-5555-666666666666"

    func testRetrievedMemberIsCached() {
        stub("GET", "members/\(friendID)", data: #"{"_id":"\#(friendID)","profile":{"name":"Friend"}}"#)
        firstValue(repository.retrieveMember(userID: friendID))
        drain()
        let member = firstValue(repository.getMember(userID: friendID)) ?? nil
        XCTAssertEqual(member?.profile?.name, "Friend")
    }

    func testMemberLookupByUsername() {
        // anything that isn't a UUID is treated as a username
        stub("GET", "members/username/friend", data: #"{"_id":"\#(friendID)","profile":{"name":"Friend"}}"#)
        let member = firstValue(repository.retrieveMember(userID: "friend"))
        XCTAssertEqual(member??.id, friendID)
    }

    func testHallMembersAreNotCached() {
        // hall entries carry admin-only fields and must not overwrite the regular member
        stub("GET", "hall/heroes/\(friendID)", data: #"{"_id":"\#(friendID)","profile":{"name":"Hero"}}"#)
        firstValue(repository.retrieveMember(userID: friendID, fromHall: true))
        drain()
        XCTAssertNil(firstValue(repository.getMember(userID: friendID)) ?? nil)
    }

    func testFailedUsernameSearchReturnsEmptyList() {
        stub("GET", "members/find/fri", status: 500, data: "null")
        let disposable = repository.findUsernames("fri", context: nil, id: nil).observeValues { _ in }
        waitForRequests(1)
        disposable?.dispose()
        stub("GET", "members/find/fri", data: "null")
        XCTAssertEqual(firstValue(repository.findUsernames("fri", context: nil, id: nil))?.count, 0)
    }

    // MARK: Quests

    /// The fixture user, with an open quest invitation.
    private func storeInvitedUser() throws {
        let json = try userJSON().replacingOccurrences(of: #""RSVPNeeded":false"#, with: #""RSVPNeeded":true"#)
        UserLocalRepository().save(try JSONDecoder().decode(APIUser.self, from: Data(json.utf8)))
        XCTAssertEqual(rsvpNeeded, true)
    }

    private var rsvpNeeded: Bool? {
        return UserLocalRepository().getUserAsync(userID)?.party?.quest?.rsvpNeeded
    }

    func testAcceptingQuestHidesInvitationAtOnce() throws {
        try storeInvitedUser()
        stub("POST", "groups/party-1/quests/accept", data: #"{"key":"dilatory","active":false}"#, delay: 1)
        let disposable = repository.acceptQuestInvitation(groupID: "party-1").observeValues { _ in }
        XCTAssertEqual(rsvpNeeded, false, "the invitation disappears before the server answers")
        waitForRequests(1)
        drain(1.5)
        disposable?.dispose()
        XCTAssertEqual(rsvpNeeded, false)
        XCTAssertEqual(feedback.haptics, [.selection])
    }

    func testFailedQuestAnswerBringsInvitationBack() throws {
        // regression: a failed accept or reject left the invitation hidden until the next full sync
        try storeInvitedUser()
        stub("POST", "groups/party-1/quests/accept", status: 401, data: "null", delay: 1)
        let accept = repository.acceptQuestInvitation(groupID: "party-1").observeValues { _ in }
        waitForRequests(1)
        drain(1.5)
        accept?.dispose()
        XCTAssertEqual(rsvpNeeded, true)

        stub("POST", "groups/party-1/quests/reject", status: 500, data: "null")
        let reject = repository.rejectQuestInvitation(groupID: "party-1").observeValues { _ in }
        waitForRequests(2)
        drain()
        reject?.dispose()
        XCTAssertEqual(rsvpNeeded, true)
    }

    func testRejectingQuestHidesInvitation() throws {
        try storeInvitedUser()
        stub("POST", "groups/party-1/quests/reject", data: #"{"key":"dilatory","active":false}"#)
        firstValue(repository.rejectQuestInvitation(groupID: "party-1"))
        drain()
        XCTAssertEqual(rsvpNeeded, false)
    }

    func testStartingOrAbortingQuestReloadsParty() {
        stub("POST", "groups/party-1/quests/force-start", data: #"{"key":"dilatory","active":true}"#)
        stub("POST", "groups/party-1/quests/abort", data: #"{"active":false}"#)
        stub("GET", "groups/party-1", data: #"{"_id":"party-1","type":"party","name":"Party"}"#)
        firstValue(repository.forceStartQuest(groupID: "party-1"))
        firstValue(repository.abortQuest(groupID: "party-1"))
        XCTAssertEqual(requestedPaths, ["POST groups/party-1/quests/force-start", "GET groups/party-1",
                                        "POST groups/party-1/quests/abort", "GET groups/party-1"])
    }

    func testLeavingQuestReloadsParty() {
        stub("POST", "groups/party-1/quests/leave", data: "{}")
        stub("GET", "groups/party-1", data: #"{"_id":"party-1","type":"party","name":"Party"}"#)
        let party = firstValue(repository.leaveQuest(groupID: "party-1"))
        XCTAssertEqual(party??.name, "Party")
    }

    func testFailedQuestStartDoesNotReload() {
        stub("POST", "groups/party-1/quests/force-start", status: 401, data: "null")
        let disposable = repository.forceStartQuest(groupID: "party-1").observeValues { _ in }
        waitForRequests(1)
        drain()
        disposable?.dispose()
        XCTAssertEqual(requestedPaths, ["POST groups/party-1/quests/force-start"])
    }

    func testCancellingQuestInvitation() {
        stub("POST", "groups/party-1/quests/cancel", data: #"{"active":false}"#)
        firstValue(repository.cancelQuestInvitation(groupID: "party-1"))
        XCTAssertEqual(requestedPaths, ["POST groups/party-1/quests/cancel"])
    }
}
