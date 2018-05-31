//
//  TaskLocalRepository.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift
import RealmSwift
import Result

public class TaskLocalRepository: BaseLocalRepository {
    
    func save(userID: String?, task: TaskProtocol, tags: Results<RealmTag>?) {
        if let realmTask = task as? RealmTask {
            save(object: realmTask)
            return
        }
        if let oldTask = getRealm()?.object(ofType: RealmTask.self, forPrimaryKey: task.id) {
            task.order = oldTask.order
        }
        save(object: RealmTask(userID: userID, taskProtocol: task, tags: tags))
    }
    
    public func save(userID: String?, task: TaskProtocol) {
        let tags = getRealm()?.objects(RealmTag.self).filter("id IN %@", task.tags.map({ (tag) -> String? in
            return tag.id
        }))
        save(userID: userID, task: task, tags: tags)
    }
    
    public func save(userID: String?, tasks: [TaskProtocol], order: [String: [String]]? = nil) {
        let tags = getRealm()?.objects(RealmTag.self)
        var taskOrder = ["habits": [String](),
                         "dailies": [String](),
                         "todos": [String](),
                         "rewards": [String](),
                         ]
        if let order = order {
            taskOrder = order
        } else {
            getRealm()?.objects(RealmTask.self).sorted(byKeyPath: "order").forEach({ (task) in
                taskOrder[(task.type ?? "")+"s"]?.append(task.id ?? "")
            })
        }
        save(objects:tasks.map { (task) in
            task.order = taskOrder[(task.type ?? "")+"s"]?.index(of: task.id ?? "") ?? 0
            if let realmTask = task as? RealmTask {
                return realmTask
            }
            return RealmTask(userID: userID, taskProtocol: task, tags: tags)
        })
        removeOldTasks(newTasks: tasks)
    }
    
    public func save(userID: String?, tag: TagProtocol) {
        if let realmTag = tag as? RealmTag {
            save(object: realmTag)
            return
        }
        save(object: RealmTag(userID: userID, tagProtocol: tag))
        
    }
    
    private func removeOldTasks(newTasks: [TaskProtocol]) {
        let oldTasks = getRealm()?.objects(RealmTask.self)
        var tasksToRemove = [RealmTask]()
        oldTasks?.forEach({ (task) in
            if !newTasks.contains(where: { (newTask) -> Bool in
                return newTask.id == task.id
            }) {
                tasksToRemove.append(task)
            }
        })
        if tasksToRemove.count > 0 {
            let realm = getRealm()
            try? realm?.write {
                realm?.delete(tasksToRemove)
            }
        }
    }
    
    public func getTasks(predicate: NSPredicate) -> SignalProducer<ReactiveResults<[TaskProtocol]>, ReactiveSwiftRealmError> {
        return RealmTask.findBy(predicate: predicate).sorted(key: "order").reactive().map({ (value, changeset) -> ReactiveResults<[TaskProtocol]> in
            return (value.map({ (task) -> TaskProtocol in return task }), changeset)
        })
    }
    
    public func getTask(id: String) -> SignalProducer<TaskProtocol, ReactiveSwiftRealmError> {
        return RealmTask.findBy(key: id).skipNil().map({ task -> TaskProtocol in
            return task
        })
    }
    
    public func getTags() -> SignalProducer<ReactiveResults<[TagProtocol]>, ReactiveSwiftRealmError> {
        return RealmTag.findAll().sorted(key: "order").reactive().map({ (value, changeset) -> ReactiveResults<[TagProtocol]> in
            return (value.map({ (tag) -> TagProtocol in return tag }), changeset)
        })
    }
    
    public func getUserStats(id: String) -> SignalProducer<StatsProtocol, ReactiveSwiftRealmError> {
        return RealmUser.findBy(key: id).map({ user -> StatsProtocol? in
            return user?.stats
        }).skipNil()
    }
    
    public func update(taskId: String, stats: StatsProtocol, direction: TaskScoringDirection, response: TaskResponseProtocol) {
        RealmTask.findBy(key: taskId).take(first: 1).skipNil().on(value: { realmTask in
            try? self.getRealm()?.write {
                if let delta = response.delta {
                    realmTask.value = realmTask.value + delta
                }
                if realmTask.type != TaskType.habit.rawValue {
                    realmTask.completed = direction == .up
                    if direction == .up {
                        realmTask.streak += 1
                    }
                } else {
                    if direction == .up {
                        realmTask.counterUp += 1
                    }
                    if direction == .down {
                        realmTask.counterDown += 1
                    }
                }
                
                stats.health = response.health ?? 0
                stats.experience = response.experience ?? 0
                stats.mana = response.magic ?? 0
                stats.gold = response.gold ?? 0
            }
        }).start()
    }

    public func getNewTask() -> TaskProtocol {
        return RealmTask()
    }
    
    public func getNewTag(id: String? = nil) -> TagProtocol {
        let tag = RealmTag()
        if let id = id {
            tag.id = id
        }
        return tag
    }
    
    public func getNewChecklistItem() -> ChecklistItemProtocol {
        return RealmChecklistItem()
    }
    
    public func getNewReminder() -> ReminderProtocol {
        return RealmReminder()
    }
    
    public func getEditableTask(id: String) -> TaskProtocol? {
        if let task = getRealm()?.object(ofType: RealmTask.self, forPrimaryKey: id) {
            let editableTask = RealmTask(value: task)
            if let weekRepeat = task.weekRepeat {
                editableTask.weekRepeat = RealmWeekRepeat(value: weekRepeat)
            }
            return editableTask
        }
        return nil
    }
    
    public func getEditableTag(id: String) -> TagProtocol? {
        if let tag = getRealm()?.object(ofType: RealmTag.self, forPrimaryKey: id) {
            let editableTag = RealmTag(userID: tag.userID, tagProtocol: tag)
            return editableTag
        }
        return nil
    }
    
    public func setTaskSyncing(userID: String?, task: TaskProtocol, isSyncing: Bool) {
        if let realmTask = task as? RealmTask {
            try? getRealm()?.write {
                realmTask.isSyncing = isSyncing
            }
        } else {
            task.isSyncing = isSyncing
            save(userID: userID, task: task)
        }
    }
    
    public func getUnsyncedTasks() -> SignalProducer<[TaskProtocol], ReactiveSwiftRealmError> {
        return RealmTask.findBy(query: "isSyncing == false && isSynced == false").map({ (value) -> [TaskProtocol] in
            return value.map({ (task) -> TaskProtocol in return task })
        })
    }
    
    public func deleteTask(_ task: TaskProtocol) {
        let realm = getRealm()
        if let realmTask = realm?.object(ofType: RealmTask.self, forPrimaryKey: task.id) {
            try? realm?.write {
                realm?.delete(realmTask)
            }
        }
    }
    
    public func moveTask(_ task: TaskProtocol, toPosition: Int) {
        try? getRealm()?.write {
            task.order = toPosition
        }
    }
    
    public func deleteTag(_ tag: TagProtocol) {
        let realm = getRealm()
        if let realmTag = realm?.object(ofType: RealmTag.self, forPrimaryKey: tag.id) {
            try? realm?.write {
                realm?.delete(realmTag)
            }
        }
    }
    
    public func fixTaskOrder(movedTask: TaskProtocol, toPosition: Int) {
        var taskOrder = 0
        let realm = getRealm()
        guard let tasks = realm?.objects(RealmTask.self).filter("type == %@", movedTask.type ?? "").sorted(byKeyPath: "order") else {
            return
        }
        try? realm?.write {
            for task in tasks {
                if task.id == movedTask.id {
                    task.order = toPosition
                    break
                }
                task.order = taskOrder
                taskOrder += 1
            }
        }
    }
    
    public func getReminders(userID: String) -> SignalProducer<ReactiveResults<[ReminderProtocol]>, ReactiveSwiftRealmError> {
        return RealmReminder.findBy(query: "userID == '\(userID)'").reactive().map({ (value, changeset) -> ReactiveResults<[ReminderProtocol]> in
            return (value.map({ (reminder) -> ReminderProtocol in return reminder }), changeset)
        })
    }
}
