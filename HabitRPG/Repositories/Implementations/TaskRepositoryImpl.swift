//
//  TaskRepository.swift
//  Habitica
//
//  Created by Phillip Thelen on 14.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Habitica_Models
import Habitica_API_Client
import Habitica_Database

class TaskRepository: BaseRepository<TaskLocalRepository>, TaskRepositoryProtocol {
    
    func retrieveTasks(dueOnDay: Date? = nil) -> Signal<[TaskProtocol]?, Never> {
        let call = RetrieveTasksCall(dueOnDay: dueOnDay)
        call.fire()
        return call.arraySignal.on(value: {[weak self] tasks in
            if let tasks = tasks, dueOnDay == nil {
                self?.localRepository.save(userID: self?.currentUserId, tasks: tasks)
            }
        })
    }
    
    func retrieveCompletedTodos() -> Signal<[TaskProtocol]?, Never> {
        let call = RetrieveTasksCall(type: "completedTodos")
        call.fire()
        return call.arraySignal.on(value: {[weak self] tasks in
            if let tasks = tasks {
                self?.localRepository.save(userID: self?.currentUserId, tasks: tasks, removeCompletedTodos: true)
            }
        })
    }
    
    func clearCompletedTodos() -> Signal<[TaskProtocol]?, Never> {
        let call = ClearCompletedTodosCall()
        call.fire()
        return call.arraySignal
    }
    
    func getTasks(predicate: NSPredicate, sortKey: String = "order") -> SignalProducer<ReactiveResults<[TaskProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (userID) in
            return self?.localRepository.getTasks(userID: userID, predicate: predicate, sortKey: sortKey) ?? SignalProducer.empty
        })
    }
    
    func getTasks(type: TaskType) -> SignalProducer<ReactiveResults<[TaskProtocol]>, ReactiveSwiftRealmError> {
        var predicate = NSPredicate(format: "type == %@", type.rawValue)
        if type == .todo {
            predicate = NSPredicate(format: "type == 'todo' && completed == false")
        }
        return getTasks(predicate: predicate)
    }
    
    func getDueTasks() -> SignalProducer<ReactiveResults<[TaskProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (userID) in
            return self?.localRepository.getTasks(userID: userID,
                                                  predicate: NSPredicate(format: "(type == 'daily' && isDue == true) || (type == 'todo' && completed == false)"),
                                                  sortKey: "order") ?? SignalProducer.empty
        })
    }
    
    func getTags() -> SignalProducer<ReactiveResults<[TagProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getTags()
    }
    
    func save(_ tasks: [TaskProtocol], order: [String: [String]]) {
        localRepository.save(userID: self.currentUserId, tasks: tasks, order: order)
    }
    
    func save(task: TaskProtocol) {
        localRepository.save(userID: self.currentUserId, task: task)
    }
    
    func score(task: TaskProtocol, direction: TaskScoringDirection) -> Signal<TaskResponseProtocol?, Never> {
        let call = ScoreTaskCall(task: task, direction: direction)
        call.fire()
        return call.objectSignal.withLatest(from: localRepository.getUserStats(id: AuthenticationManager.shared.currentUserId ?? "")
            .flatMapError({ (_) in
            return SignalProducer.empty
        })).on(value: {[weak self] (taskResponse, stats) in
            guard let response = taskResponse else {
                return
            }
            
            let healthDiff = (response.health ?? 0) - stats.health
            let magicDiff = (response.magic ?? 0) - stats.mana
            let expDiff = (response.experience ?? 0) - stats.experience
            let goldDiff = (response.gold ?? 0) - stats.gold
            let questDamage = (response.temp?.quest?.progressDelta ?? 0)
            if task.type == "reward" {
                ToastManager.show(text: L10n.buyReward(task.text ?? "", task.value), color: .green)
            } else if let taskId = task.id {
                self?.localRepository.update(taskId: taskId, stats: stats, direction: direction, response: response)
                if healthDiff + magicDiff + goldDiff + questDamage == 0 {
                    return
                }
                
                let toastView = ToastView(healthDiff: healthDiff,
                                          magicDiff: magicDiff,
                                          expDiff: expDiff,
                                          goldDiff: goldDiff,
                                          questDamage: questDamage,
                                          background: healthDiff >= 0 ? .green : .red)
                ToastManager.show(toast: toastView)
            }
            
            if #available(iOS 10, *) {
                UIImpactFeedbackGenerator.oneShotImpactOccurred(.light)
            }
            
            if let drop = response.temp?.drop {
                var dialog = drop.dialog
                if dialog == nil {
                    dialog = "You found a \(drop.key ?? "")"
                }
                ToastManager.show(text: dialog ?? "", color: .gray)
            }
        }).map({ (response, _) in
            return response
        })
    }
    
    func score(checklistItem: ChecklistItemProtocol, task: TaskProtocol) -> Signal<TaskProtocol?, Never> {
        let call = ScoreChecklistItem(item: checklistItem, task: task)
        call.fire()
        return call.objectSignal.on(value: {[weak self] task in
                if let task = task {
                    self?.localRepository.save(userID: self?.currentUserId, task: task)
                }
            })
    }
    
    func getNewTask() -> TaskProtocol {
        return localRepository.getNewTask()
    }
    
    func getNewTag(id: String? = nil) -> TagProtocol {
        return localRepository.getNewTag(id: id)
    }
    
    func getNewChecklistItem() -> ChecklistItemProtocol {
        return localRepository.getNewChecklistItem()
    }
    
    func getNewReminder() -> ReminderProtocol {
        return localRepository.getNewReminder()
    }
    
    func getEditableTask(id: String) -> TaskProtocol? {
        return localRepository.getEditableTask(id: id)
    }
    
    func getEditableTag(id: String) -> TagProtocol? {
        return localRepository.getEditableTag(id: id)
    }
    
    func createTask(_ task: TaskProtocol) -> Signal<TaskProtocol?, Never> {
        localRepository.save(userID: currentUserId, task: task)
        localRepository.setTaskSyncing(userID: currentUserId, task: task, isSyncing: true)
        let call = CreateTaskCall(task: task)
        call.fire()
        return call.objectSignal.on(value: {[weak self]returnedTask in
            if let returnedTask = returnedTask {
                self?.localRepository.save(userID: self?.currentUserId, task: returnedTask)
            }
        })
    }
    
    func createTasks(_ tasks: [TaskProtocol]) -> Signal<[TaskProtocol]?, Never> {
        let call = CreateTasksCall(tasks: tasks)
        call.fire()
        return call.arraySignal
    }
    
    func updateTask(_ task: TaskProtocol) -> Signal<TaskProtocol?, Never> {
        localRepository.save(userID: currentUserId, task: task)
        localRepository.setTaskSyncing(userID: currentUserId, task: task, isSyncing: true)
        let call = UpdateTaskCall(task: task)
        call.fire()
        call.errorSignal.observeValues({ _ in
            self.localRepository.setTaskSyncing(userID: self.currentUserId, task: task, isSyncing: false)
        })
        return call.objectSignal.on(value: {[weak self]returnedTask in
            if let returnedTask = returnedTask {
                returnedTask.order = task.order
                self?.localRepository.save(userID: self?.currentUserId, task: returnedTask)
            }
        })
    }
    
    func syncTask(_ task: TaskProtocol) -> Signal<TaskProtocol?, Never> {
        if task.isNewTask {
            return self.createTask(task)
        } else {
            return self.updateTask(task)
        }
    }
    
    func deleteTask(_ task: TaskProtocol) -> Signal<EmptyResponseProtocol?, Never> {
        if !task.isValid {
            return Signal.empty
        }
        let call = DeleteTaskCall(task: task)
        call.fire()
        call.httpResponseSignal.observeValues { (response) in
            if response.statusCode == 200, task.isValid {
                self.localRepository.deleteTask(task)
            }
        }
        return call.objectSignal
    }
    
    func createTag(_ tag: TagProtocol) -> Signal<TagProtocol?, Never> {
        let call = CreateTagCall(tag: tag)
        call.fire()
        return call.objectSignal.on(value: {[weak self]returnedTag in
            if let returnedTag = returnedTag {
                self?.localRepository.save(userID: self?.currentUserId, tag: returnedTag)
            }
        })
    }
    
    func updateTag(_ tag: TagProtocol) -> Signal<TagProtocol?, Never> {
        let call = UpdateTagCall(tag: tag)
        call.fire()
        return call.objectSignal.on(value: {[weak self]returnedTag in
            if let returnedTag = returnedTag {
                returnedTag.order = tag.order
                self?.localRepository.save(userID: self?.currentUserId, tag: returnedTag)
            }
        })
    }
    
    func deleteTag(_ tag: TagProtocol) -> Signal<EmptyResponseProtocol?, Never> {
        let call = DeleteTagCall(tag: tag)
        call.fire()
        call.httpResponseSignal.observeValues {[weak self] (response) in
            if response.statusCode == 200 {
                self?.localRepository.deleteTag(tag)
            }
        }
        return call.objectSignal
    }
    
    func moveTask(_ task: TaskProtocol, toPosition: Int) -> Signal<[String]?, Never> {
        let call = MoveTaskCall(task: task, toPosition: toPosition)
        call.fire()
        return call.arraySignal.on(value: {[weak self] taskOrder in
            if let taskType = task.type, let taskOrder = taskOrder {
                self?.localRepository.updateTaskOrder(taskType: taskType, order: taskOrder)
            }
        })
    }
    
    func fixTaskOrder(movedTask: TaskProtocol, toPosition: Int) {
        localRepository.fixTaskOrder(movedTask: movedTask, toPosition: toPosition)
    }
    
    func getReminders() -> SignalProducer<ReactiveResults<[ReminderProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (userID) in
            return self?.localRepository.getReminders(userID: userID) ?? SignalProducer.empty
        })
    }
}
