//
//  TaskScoringTests.swift
//  HabiticaTests
//
//  TaskRepository.score: what changes locally and what the player is shown.
//

import XCTest
import ReactiveSwift
import Habitica_Models
import Habitica_API_Client
import Habitica_Database
@testable import Habitica

class TaskScoringTests: RepositoryTestCase {

    private var repository: TaskRepository!
    private var feedback: RecordingFeedback!
    private let local = TaskLocalRepository()

    override func setUp() {
        super.setUp()
        feedback = RecordingFeedback()
        repository = TaskRepository()
        repository.feedback = feedback
        // the app's UserManager rewrites the shared status whenever the stored user changes
        repository.questStatus = { [unowned self] in self.questStatus }
    }

    private var questStatus = UserQuestStatus.noQuest

    /// A user with round stats so the expected differences are exact.
    private func storeUser(level: Int = 16) throws {
        try storeFixtureUser()
        let stats = #"{"hp":50,"maxHealth":50,"mp":10,"exp":54,"toNextLevel":360,"gp":100,"lvl":\#(level)}"#
        UserLocalRepository().save(userID, stats: try JSONDecoder().decode(APIStats.self, from: Data(stats.utf8)))
    }

    private func storeTask(id: String = "t1", type: String = "habit", text: String = "Task", value: Float = 0) -> TaskProtocol {
        let task = repository.getNewTask()
        task.id = id
        task.type = type
        task.text = text
        task.value = value
        repository.save(task: task)
        return local.getEditableTask(id: id)!
    }

    @discardableResult
    private func score(_ task: TaskProtocol, direction: TaskScoringDirection = .up, response: String) -> TaskResponseProtocol? {
        stub("POST", "tasks/\(task.id ?? "")/score/\(direction.rawValue)", data: response)
        let result = firstValue(repository.score(task: task, direction: direction))
        drain()
        return result ?? nil
    }

    // MARK: Stats toast

    func testScoreShowsStatChanges() throws {
        try storeUser()
        score(storeTask(), response: #"{"hp":48,"mp":11,"exp":60,"gp":103,"lvl":16,"delta":1}"#)
        XCTAssertEqual(feedback.scoreChanges, [ScoreChange(health: -2, mana: 1, experience: 6, gold: 3, questDamage: 0)])
        XCTAssertEqual(feedback.haptics, [.tap])
        XCTAssertEqual(feedback.levelUps, 0)
    }

    func testOppositeChangesStillShowToast() throws {
        // regression: the changes were summed, so -2 health and +2 gold added up to "nothing changed"
        try storeUser()
        score(storeTask(), response: #"{"hp":48,"mp":10,"exp":54,"gp":102,"lvl":16}"#)
        XCTAssertEqual(feedback.scoreChanges, [ScoreChange(health: -2, mana: 0, experience: 0, gold: 2, questDamage: 0)])
    }

    func testNoChangeShowsNoToast() throws {
        try storeUser()
        score(storeTask(), response: #"{"hp":50,"mp":10,"exp":54,"gp":100,"lvl":16}"#)
        XCTAssertTrue(feedback.scoreChanges.isEmpty)
    }

    func testPendingApprovalShowsNothingAndKeepsTask() throws {
        // group tasks needing approval come back without a level
        try storeUser()
        let task = storeTask(value: 0)
        score(task, response: #"{"delta":1}"#)
        XCTAssertTrue(feedback.scoreChanges.isEmpty)
        XCTAssertEqual(local.getEditableTask(id: "t1")?.value, 0)
    }

    // MARK: Level up

    func testLevelUpShowsSheetAndCountsExperienceOverTheLevel() throws {
        try storeUser(level: 16)
        score(storeTask(), response: #"{"hp":50,"mp":10,"exp":10,"gp":103,"lvl":17}"#)
        XCTAssertEqual(feedback.levelUps, 1)
        // 306 to finish the old level plus 10 into the new one
        XCTAssertEqual(feedback.scoreChanges.first?.experience, 316)
        waitForRequests(2)
        XCTAssertTrue(requestedPaths.contains("GET user"), "the new level's target is only in the full user")
    }

    // MARK: Local updates

    func testHabitScoreUpdatesTaskAndStats() throws {
        try storeUser()
        let task = storeTask(value: 1)
        score(task, response: #"{"hp":50,"mp":10,"exp":60,"gp":103,"lvl":16,"delta":1.5}"#)
        let stored = try XCTUnwrap(local.getEditableTask(id: "t1"))
        XCTAssertEqual(stored.value, 2.5)
        XCTAssertEqual(stored.counterUp, 1)
        XCTAssertEqual(UserLocalRepository().getUserAsync(userID)?.stats?.gold, 103)
    }

    func testDailyScoreCompletesAndCountsStreak() throws {
        try storeUser()
        let daily = storeTask(id: "d1", type: "daily")
        score(daily, response: #"{"hp":50,"mp":10,"exp":60,"gp":103,"lvl":16,"delta":1}"#)
        let stored = try XCTUnwrap(local.getEditableTask(id: "d1"))
        XCTAssertTrue(stored.completed)
        XCTAssertEqual(stored.streak, 1)
    }

    func testDailyScoredDownNeverHasNegativeStreak() throws {
        try storeUser()
        let daily = storeTask(id: "d1", type: "daily")
        score(daily, direction: .down, response: #"{"hp":50,"mp":10,"exp":54,"gp":100,"lvl":16,"delta":-1}"#)
        let stored = try XCTUnwrap(local.getEditableTask(id: "d1"))
        XCTAssertFalse(stored.completed)
        XCTAssertEqual(stored.streak, 0)
    }

    // MARK: Rewards, drops and quests

    func testBuyingRewardShowsRewardToastInsteadOfStats() throws {
        try storeUser()
        let reward = storeTask(id: "r1", type: "reward", text: "Treat", value: 25)
        score(reward, response: #"{"hp":50,"mp":10,"exp":54,"gp":75,"lvl":16}"#)
        XCTAssertEqual(feedback.toastTexts, [L10n.buyReward("Treat", "25")])
        XCTAssertTrue(feedback.scoreChanges.isEmpty)
        XCTAssertEqual(local.getEditableTask(id: "r1")?.value, 25, "a reward's price is not its score")
    }

    func testDropIsAnnounced() throws {
        try storeUser()
        score(storeTask(), response: #"{"hp":50,"mp":10,"exp":60,"gp":103,"lvl":16,"_tmp":{"drop":{"key":"Wolf","dialog":"You found a Wolf Egg!"}}}"#)
        XCTAssertEqual(feedback.toastTexts, ["You found a Wolf Egg!"])
    }

    func testDropWithoutDialogNamesTheItem() throws {
        try storeUser()
        score(storeTask(), response: #"{"hp":50,"mp":10,"exp":60,"gp":103,"lvl":16,"_tmp":{"drop":{"key":"Wolf"}}}"#)
        XCTAssertEqual(feedback.toastTexts, ["You found a Wolf"])
    }

    func testQuestDamageOnlyShownOnBossQuests() throws {
        try storeUser()
        let response = #"{"hp":50,"mp":10,"exp":60,"gp":103,"lvl":16,"_tmp":{"quest":{"progressDelta":4.5}}}"#
        score(storeTask(id: "a"), response: response)
        XCTAssertEqual(feedback.scoreChanges.last?.questDamage, 0)

        questStatus = .questBoss
        score(storeTask(id: "b"), response: response)
        XCTAssertEqual(feedback.scoreChanges.last?.questDamage, 4.5)
    }

    func testCollectedQuestItemsAreCounted() throws {
        try storeUser()
        questStatus = .questCollect
        score(storeTask(id: "a"), response: #"{"hp":50,"mp":10,"exp":60,"gp":103,"lvl":16,"_tmp":{"quest":{"collection":1}}}"#)
        score(storeTask(id: "b"), response: #"{"hp":50,"mp":10,"exp":60,"gp":103,"lvl":16,"_tmp":{"quest":{"collection":3}}}"#)
        XCTAssertEqual(feedback.toastTexts, [L10n.oneQuestItemFound, L10n.questItemsFound(3)])
    }

    func testCollectedItemsIgnoredOutsideCollectQuests() throws {
        try storeUser()
        score(storeTask(), response: #"{"hp":50,"mp":10,"exp":60,"gp":103,"lvl":16,"_tmp":{"quest":{"collection":3}}}"#)
        XCTAssertTrue(feedback.toasts.isEmpty)
    }

    func testFailedScoreShowsOnlyTapFeedback() throws {
        try storeUser()
        let task = storeTask()
        stub("POST", "tasks/t1/score/up", status: 401, data: "null")
        let disposable = repository.score(task: task, direction: .up).observeValues { _ in }
        waitForRequests(1)
        drain()
        disposable?.dispose()
        XCTAssertEqual(feedback.haptics, [.tap])
        XCTAssertTrue(feedback.nothingShown)
        XCTAssertEqual(local.getEditableTask(id: "t1")?.counterUp, 0)
    }

    // MARK: Checklists

    func testScoringChecklistItemStoresReturnedTask() throws {
        let task = storeTask(id: "todo", type: "todo")
        let item = repository.getNewChecklistItem()
        item.id = "item"
        stub("POST", "tasks/todo/checklist/item/score", data: #"{"_id":"todo","type":"todo","text":"Updated","checklist":[{"id":"item","text":"Step","completed":true}]}"#)
        firstValue(repository.score(checklistItem: item, task: task))
        drain()
        let stored = try XCTUnwrap(local.getEditableTask(id: "todo"))
        XCTAssertEqual(stored.text, "Updated")
        XCTAssertEqual(stored.checklist.first?.completed, true)
    }
}
