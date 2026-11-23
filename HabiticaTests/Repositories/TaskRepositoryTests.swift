//
//  TaskRepositoryTests.swift
//  HabiticaTests
//

import XCTest
import ReactiveSwift
import Habitica_Models
import Habitica_Database
@testable import Habitica

class TaskRepositoryTests: RepositoryTestCase {

    private var repository: TaskRepository!
    private let local = TaskLocalRepository()

    override func setUp() {
        super.setUp()
        repository = TaskRepository()
    }

    private func makeTask(id: String, type: String = "todo", text: String = "Task", order: Int = 0, completed: Bool = false) -> TaskProtocol {
        let task = repository.getNewTask()
        task.id = id
        task.type = type
        task.text = text
        task.order = order
        task.completed = completed
        return task
    }

    private func storedTaskIDs(type: TaskType) -> [String] {
        return firstValue(repository.getTasks(type: type))?.value.compactMap(\.id) ?? []
    }

    // MARK: Local queries

    func testTodoQueryHidesCompletedTodos() {
        repository.save(task: makeTask(id: "open", type: "todo"))
        repository.save(task: makeTask(id: "done", type: "todo", completed: true))
        repository.save(task: makeTask(id: "daily", type: "daily"))
        XCTAssertEqual(storedTaskIDs(type: .todo), ["open"])
        XCTAssertEqual(storedTaskIDs(type: .daily), ["daily"])
    }

    func testQueriesOnlyReturnCurrentUsersTasks() {
        local.save(userID: "someone-else", task: makeTask(id: "foreign"))
        repository.save(task: makeTask(id: "mine"))
        XCTAssertEqual(storedTaskIDs(type: .todo), ["mine"])
    }

    func testTasksAreSortedByOrder() {
        repository.save(task: makeTask(id: "b", order: 2))
        repository.save(task: makeTask(id: "a", order: 1))
        repository.save(task: makeTask(id: "c", order: 3))
        XCTAssertEqual(storedTaskIDs(type: .todo), ["a", "b", "c"])
    }

    func testChallengeTaskQueryHandlesQuotesInID() {
        // regression: the ID was pasted into the predicate format and a quote crashed it
        let task = makeTask(id: "challenge-task")
        task.challengeID = "it's"
        repository.save(task: task)
        let results = firstValue(repository.getChallengeTasks(id: "it's"))
        XCTAssertEqual(results?.value.compactMap(\.id), ["challenge-task"])
    }

    // MARK: Creating

    func testCreateTaskSavesLocallyBeforeServerAnswers() {
        let task = makeTask(id: "new-task", text: "Local")
        task.isNewTask = true
        task.isSynced = false
        stub("POST", "tasks/user", data: #"{"_id":"new-task","type":"todo","text":"Local"}"#)
        let disposable = repository.createTask(task).observeValues { _ in }
        let stored = local.getEditableTask(id: "new-task")
        XCTAssertEqual(stored?.text, "Local")
        XCTAssertEqual(stored?.isSyncing, true)
        waitForRequests(1)
        drain()
        disposable?.dispose()
    }

    func testFailedSyncOfDeletedTaskDoesNotCrash() {
        // regression: the error handler wrote isSyncing to the deleted Realm object
        stub("POST", "tasks/user", status: 500, data: "null")
        let task = makeTask(id: "doomed")
        task.isNewTask = true
        let disposable = repository.createTask(task).observeValues { _ in }
        local.deleteTask(task)
        waitForRequests(1)
        drain()
        disposable?.dispose()
        XCTAssertNil(local.getEditableTask(id: "doomed"))
    }

    func testCreateTaskStoresServerVersion() throws {
        stub("POST", "tasks/user", data: #"{"_id":"new-task","type":"todo","text":"From server"}"#)
        let task = makeTask(id: "new-task", text: "Local")
        task.isNewTask = true
        task.isSynced = false
        let returned = firstValue(repository.createTask(task))
        XCTAssertEqual(returned??.text, "From server")

        let stored = try XCTUnwrap(local.getEditableTask(id: "new-task"))
        XCTAssertEqual(stored.text, "From server")
        XCTAssertFalse(stored.isNewTask)
        XCTAssertTrue(stored.isSynced)
        XCTAssertFalse(stored.isSyncing)

        XCTAssertEqual(requestedPaths, ["POST tasks/user"])
        XCTAssertEqual(try requestBody()["text"] as? String, "Local")
    }

    func testFailedCreateKeepsTaskButStopsSyncing() throws {
        stub("POST", "tasks/user", status: 500, data: "null")
        let task = makeTask(id: "new-task")
        task.isNewTask = true
        task.isSynced = false
        let disposable = repository.createTask(task).observeValues { _ in }
        waitForRequests(1)
        drain()
        disposable?.dispose()
        let stored = try XCTUnwrap(local.getEditableTask(id: "new-task"))
        XCTAssertFalse(stored.isSyncing, "spinner must stop so the user can retry")
        XCTAssertFalse(stored.isSynced)
    }

    // MARK: Updating

    func testUpdateKeepsLocalOrder() throws {
        let task = makeTask(id: "t1", text: "Old", order: 7)
        repository.save(task: task)
        stub("PUT", "tasks/t1", data: #"{"_id":"t1","type":"todo","text":"New","order":0}"#)
        let editable = try XCTUnwrap(local.getEditableTask(id: "t1"))
        editable.text = "New"
        firstValue(repository.updateTask(editable))
        let stored = try XCTUnwrap(local.getEditableTask(id: "t1"))
        XCTAssertEqual(stored.text, "New")
        XCTAssertEqual(stored.order, 7)
    }

    func testSyncTaskCreatesNewTasksAndUpdatesExistingOnes() {
        stub("POST", "tasks/user", data: #"{"_id":"a","type":"todo"}"#)
        stub("PUT", "tasks/b", data: #"{"_id":"b","type":"todo"}"#)
        let newTask = makeTask(id: "a")
        newTask.isNewTask = true
        firstValue(repository.syncTask(newTask))
        let existing = makeTask(id: "b")
        existing.isNewTask = false
        firstValue(repository.syncTask(existing))
        XCTAssertEqual(requestedPaths, ["POST tasks/user", "PUT tasks/b"])
    }

    // MARK: Deleting

    func testDeleteRemovesTaskAfterServerConfirms() {
        repository.save(task: makeTask(id: "t1"))
        stub("DELETE", "tasks/t1", data: "{}")
        let task = local.getEditableTask(id: "t1")!
        firstValue(repository.deleteTask(task))
        drain()
        XCTAssertNil(local.getEditableTask(id: "t1"))
    }

    func testFailedDeleteKeepsTask() {
        repository.save(task: makeTask(id: "t1"))
        stub("DELETE", "tasks/t1", status: 500, data: "null")
        let task = local.getEditableTask(id: "t1")!
        let disposable = repository.deleteTask(task).observeValues { _ in }
        waitForRequests(1)
        drain()
        disposable?.dispose()
        XCTAssertNotNil(local.getEditableTask(id: "t1"))
    }

    func testDeletingInvalidTaskDoesNothing() {
        let task = PreviewTask()
        task.id = "gone"
        task.isValid = false
        assertEmpty(repository.deleteTask(task))
        drain()
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testScoringInvalidTaskDoesNothing() {
        let task = PreviewTask()
        task.id = "gone"
        task.isValid = false
        assertEmpty(repository.score(task: task, direction: .up))
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    // MARK: Tags

    func testCreateTagReplacesLocalIDWithServerID() {
        stub("POST", "tags", data: #"{"id":"server-tag","name":"Work"}"#)
        let tag = repository.getNewTag(id: "local-tag")
        tag.text = "Work"
        tag.order = 3
        firstValue(repository.createTag(tag))
        drain()
        XCTAssertNil(local.getEditableTag(id: "local-tag"))
        let stored = local.getEditableTag(id: "server-tag")
        XCTAssertEqual(stored?.text, "Work")
        XCTAssertEqual(stored?.order, 3)
    }

    func testRejectedTagIsRemovedLocally() {
        // regression: only network failures removed the optimistic tag, server errors left it behind
        stub("POST", "tags", status: 400, data: "null")
        let tag = repository.getNewTag(id: "local-tag")
        tag.text = "Bad"
        let disposable = repository.createTag(tag).observeValues { _ in }
        XCTAssertNotNil(local.getEditableTag(id: "local-tag"))
        waitForRequests(1)
        drain()
        disposable?.dispose()
        XCTAssertNil(local.getEditableTag(id: "local-tag"))
    }

    func testDeleteTagRemovesLocallyRightAway() {
        let tag = repository.getNewTag(id: "tag")
        tag.text = "Old"
        local.save(userID: userID, tag: tag)
        _ = repository.deleteTag(tag)
        XCTAssertNil(local.getEditableTag(id: "tag"))
    }

    // MARK: Ordering

    func testMoveTaskAppliesServerOrder() {
        repository.save(task: makeTask(id: "a", order: 0))
        repository.save(task: makeTask(id: "b", order: 1))
        repository.save(task: makeTask(id: "c", order: 2))
        stub("POST", "tasks/c/move/to/0", data: #"["c","a","b"]"#)
        let task = local.getEditableTask(id: "c")!
        firstValue(repository.moveTask(task, toPosition: 0))
        drain()
        XCTAssertEqual(storedTaskIDs(type: .todo), ["c", "a", "b"])
    }

    func testFixTaskOrderMovesLocally() {
        repository.save(task: makeTask(id: "a", order: 0))
        repository.save(task: makeTask(id: "b", order: 1))
        repository.save(task: makeTask(id: "c", order: 2))
        repository.fixTaskOrder(movedTask: local.getEditableTask(id: "a")!, toPosition: 2)
        XCTAssertEqual(storedTaskIDs(type: .todo), ["b", "c", "a"])
        repository.fixTaskOrder(movedTask: local.getEditableTask(id: "a")!, toPosition: 0)
        XCTAssertEqual(storedTaskIDs(type: .todo), ["a", "b", "c"])
    }

    // MARK: Retrieving

    func testRetrieveTasksSavesThem() {
        stub("GET", "tasks/user", data: #"[{"_id":"server","type":"todo","text":"Remote"}]"#)
        firstValue(repository.retrieveTasks())
        drain()
        XCTAssertEqual(storedTaskIDs(type: .todo), ["server"])
    }

    func testRetrieveTasksForOtherDayDoesNotOverwriteLocalTasks() {
        // a preview of another day must not replace today's list
        repository.save(task: makeTask(id: "today"))
        stub("GET", "tasks/user", data: #"[{"_id":"tomorrow","type":"todo"}]"#)
        firstValue(repository.retrieveTasks(dueOnDay: Date().addingTimeInterval(86400)))
        drain()
        XCTAssertEqual(storedTaskIDs(type: .todo), ["today"])
    }

    func testUnlinkWithRemoveDeletesTaskLocally() {
        let task = makeTask(id: "linked")
        task.challengeID = "challenge"
        repository.save(task: task)
        stub("POST", "tasks/unlink-one/linked", data: "{}")
        // the follow-up task fetch is left unanswered (404) so only the explicit delete can remove the task
        let disposable = repository.unlinkOneTask(task: local.getEditableTask(id: "linked")!, keepOption: "remove").observeValues { _ in }
        waitForRequests(2)
        drain()
        disposable?.dispose()
        XCTAssertNil(local.getEditableTask(id: "linked"))
        XCTAssertEqual(requestedPaths.first, "POST tasks/unlink-one/linked")
    }
}
