//
//  ChallengeFormViewModel.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.03.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//


import SwiftUI
import Habitica_Models
import ReactiveSwift

private enum ChallengeTaskOp {
    case create(TaskProtocol)
    case update(TaskProtocol)
    case delete(TaskProtocol)
}

private class FormChallengeCategory: NSObject, ChallengeCategoryProtocol {
    var id: String?
    var slug: String?
    var name: String?

    init(slug: String) {
        self.slug = slug
        name = slug
    }
}

class ChallengeFormViewModel: ViewModel {
    private let userRepository = UserRepository()
    private let socialRepository = SocialRepository()
    private let taskRepository = TaskRepository()
    var onDismiss: (() -> Void)?
    var presentTaskForm: ((TaskType, TaskProtocol?) -> Void)?
    
    var editedChallenge: ChallengeProtocol?
    private var cloningChallengeID: String?
    private var originalTasks: [TaskProtocol] = []
    private var originalTaskIDs: Set<String> = []
    var isEditing: Bool { editedChallenge != nil }
    
    @Published var userGemCount = 0
    
    @Published var currentStepIndex: Int? = 0
    @Published var isSaving = false
    let steps = ChallengeFormStep.allCases
    
    @Published var prizeAmount: Int = 1
    @Published var challengeLocation: ChallengeLocation?
    @Published var name: String = ""
    @Published var summary: String = ""
    @Published var description: String = ""
    @Published var challengeTag: String = ""
    @Published var challengeCategories = Set<ChallengeCategory>()

    @Published var habits: [TaskProtocol] = []
    @Published var dailies: [TaskProtocol] = []
    @Published var todos: [TaskProtocol] = []
    @Published var rewards: [TaskProtocol] = []
    
    @Published var challengeLocations: [ChallengeLocation] = [
        ChallengeLocation(id: Constants.TAVERN_ID, name: "Public Challenge List")
    ]
    
    func isComplete(page: Int) -> Bool {
        if page == 0 {
            return prizeAmount >= minGemAmount && prizeAmount <= userGemCount
        } else if page == 1 {
            return !name.isEmpty &&
            !summary.isEmpty &&
            !description.isEmpty
        } else if page == 2 {
            return !challengeTag.isEmpty &&
            (!challengeCategories.isEmpty && challengeCategories.count < 4)
        } else if page == 3 {
            return (habits.count + dailies.count + todos.count + rewards.count) > 0
        }
        return false
    }
    
    var canSave: Bool {
        return (
            isComplete(page: 0) &&
            isComplete(page: 1) &&
            isComplete(page: 2) &&
            isComplete(page: 3)
        )
    }
    
    var isPublicChallenge: Bool {
        return challengeLocation?.id == Constants.TAVERN_ID
    }
    
    var minGemAmount: Int {
        if isPublicChallenge {
            return 1
        } else {
            return 0
        }
    }
    
    override init() {
        super.init()
        challengeLocation = challengeLocations.first
        disposable.add(userRepository.getUser().on(value: {[weak self] user in
            self?.userGemCount = user.gemCount
        })
            .map({ user in
                return user.party?.id
            })
            .filter { $0 != nil }
            .flatMap(.latest, {[weak self] partyID in
                return self?.socialRepository.getGroup(groupID: partyID ?? "") ?? SignalProducer.empty
            }).on(value: { party in
                if let party = party, !self.challengeLocations.contains(where: { $0.id == party.id }) {
                    self.challengeLocations.insert(ChallengeLocation(id: party.id ?? "", name: party.name ?? ""), at: 1)
                }
            }).start())
        disposable.add(userRepository.getGroupPlans()
            .on(value: { plans in
                plans.value.forEach { plan in
                    if !self.challengeLocations.contains(where: { $0.id == plan.id }) {
                        self.challengeLocations.append(ChallengeLocation(id: plan.id ?? "", name: plan.name ?? ""))
                    }
                }
            }).start())
    }

    func dismiss() {
        if let action = onDismiss {
            action()
        }
    }
    
    var hasPreviousStep: Bool {
        return (currentStepIndex ?? 0) > 0
    }
    
    var hasNextStep: Bool {
        return (currentStepIndex ?? 0) < 3
    }
    
    func showPreviousStep() {
        if let index = currentStepIndex {
            if index > 0 {
                currentStepIndex = index - 1
            }
        }
    }
    
    func showNextStep() {
        if let index = currentStepIndex {
            if index < 3 {
                currentStepIndex = index + 1
            }
        }
    }
    
    func categoryTapped(category: ChallengeCategory) {
        withAnimation {
            if challengeCategories.contains(category) {
                challengeCategories.remove(category)
            } else if challengeCategories.count < 3 {
                challengeCategories.insert(category)
            }
        }
    }
    
    func taskListFor(taskType: TaskType) -> [TaskProtocol] {
        switch taskType {
        case .habit:
            return habits
        case .daily:
            return dailies
        case .todo:
            return todos
        case .reward:
            return rewards
        }
    }
    
    func updateTaskListFor(taskType: TaskType, updatedList: [TaskProtocol]) {
        switch taskType {
        case .habit:
            habits = updatedList
        case .daily:
            dailies = updatedList
        case .todo:
            todos = updatedList
        case .reward:
            rewards = updatedList
        }
    }
    
    private func getUpdatedChallenge() -> ChallengeProtocol {
        let challenge: ChallengeProtocol
        if let editedChallenge = editedChallenge {
            challenge = socialRepository.getEditableChallenge(id: editedChallenge.id ?? "") ?? socialRepository.getNewChallenge()
        } else {
            challenge = socialRepository.getNewChallenge()
        }
        challenge.name = name
        challenge.shortName = challengeTag
        challenge.summary = summary
        challenge.notes = description
        challenge.prize = prizeAmount
        challenge.groupID = challengeLocation?.id
        challenge.tasksOrder["habits"] = habits.map { $0.id ?? "" }
        challenge.tasksOrder["dailies"] = dailies.map { $0.id ?? "" }
        challenge.tasksOrder["todos"] = todos.map { $0.id ?? "" }
        challenge.tasksOrder["rewards"] = rewards.map { $0.id ?? "" }
        challenge.categories = challengeCategories.map { FormChallengeCategory(slug: $0.rawValue) }
        return challenge
    }

    func configureForEditing(_ challenge: ChallengeProtocol) {
        editedChallenge = challenge
        prefillMetadata(from: challenge)
        loadChallengeTasks(challengeID: challenge.id ?? "")
    }

    func configureForCloning(_ challenge: ChallengeProtocol) {
        cloningChallengeID = challenge.id
        prefillMetadata(from: challenge)
        loadChallengeTasks(challengeID: challenge.id ?? "")
    }

    private func prefillMetadata(from challenge: ChallengeProtocol) {
        name = challenge.name ?? ""
        summary = challenge.summary ?? ""
        description = challenge.notes ?? ""
        challengeTag = challenge.shortName ?? ""
        prizeAmount = challenge.prize
        if let groupID = challenge.groupID {
            if let existing = challengeLocations.first(where: { $0.id == groupID }) {
                challengeLocation = existing
            } else {
                let location = ChallengeLocation(id: groupID, name: challenge.groupName ?? "")
                challengeLocations.append(location)
                challengeLocation = location
            }
        }
        challengeCategories = Set(challenge.categories.compactMap { ChallengeCategory(rawValue: $0.slug ?? "") })
    }

    private func loadChallengeTasks(challengeID: String) {
        disposable.add(socialRepository.getChallengeTasks(challengeID: challengeID).take(first: 1).startWithResult { [weak self] result in
            guard let self = self, case .success(let (tasks, _)) = result else { return }
            self.habits = tasks.filter { $0.type == TaskType.habit }
            self.dailies = tasks.filter { $0.type == TaskType.daily }
            self.todos = tasks.filter { $0.type == TaskType.todo }
            self.rewards = tasks.filter { $0.type == TaskType.reward }
            self.originalTasks = tasks
            self.originalTaskIDs = Set(tasks.compactMap { $0.id })
        })
    }

    private func taskOps(allTasks: [TaskProtocol]) -> [ChallengeTaskOp] {
        let currentIDs = Set(allTasks.compactMap { $0.id })
        var ops: [ChallengeTaskOp] = []
        for task in allTasks {
            if let id = task.id, originalTaskIDs.contains(id) {
                ops.append(.update(task))
            } else {
                ops.append(.create(task))
            }
        }
        for task in originalTasks where !(task.id.map { currentIDs.contains($0) } ?? false) {
            ops.append(.delete(task))
        }
        return ops
    }

    private func performTaskOp(_ op: ChallengeTaskOp, challengeID: String) -> Signal<TaskProtocol?, Never> {
        switch op {
        case .create(let task):
            return taskRepository.createChallengeTask(challengeID: challengeID, task: task)
        case .update(let task):
            return taskRepository.updateTask(task)
        case .delete(let task):
            return taskRepository.deleteTask(task).map { (_) -> TaskProtocol? in nil }
        }
    }
    
    func save() {
        if isSaving {
            return
        }
        isSaving = true
        var allTasks = habits
        allTasks.append(contentsOf: dailies)
        allTasks.append(contentsOf: todos)
        allTasks.append(contentsOf: rewards)
        let call: Signal<TaskProtocol?, Error>
        if editedChallenge != nil {
            let challengeID = editedChallenge?.id ?? ""
            let ops = taskOps(allTasks: allTasks)
            call = socialRepository.updateChallenge(challenge: getUpdatedChallenge())
                .flatMap(.latest) { _ in
                    return SignalProducer(ops)
                }.flatMap(.latest, { op in
                    self.performTaskOp(op, challengeID: challengeID)
                })
        } else if let cloningChallengeID = cloningChallengeID {
            call = socialRepository.cloneChallenge(challengeID: cloningChallengeID, challenge: getUpdatedChallenge())
                .map { (_) -> TaskProtocol? in nil }
        } else {
            call = socialRepository.createChallenge(challenge: getUpdatedChallenge())
                .flatMap(.latest) { challenge in
                    return SignalProducer(allTasks.map { task in
                        return (challenge?.id ?? "", task)
                    })
                }.flatMap(.latest, { challengeID, task in
                    self.taskRepository.createChallengeTask(challengeID: challengeID, task: task)
                })
        }
        call
            .observeResult({ result in
                switch result {
                case .success:
                    self.dismiss()
                case .failure:
                    self.isSaving = false
                }
            })
    }
}
