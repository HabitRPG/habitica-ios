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

public class TaskLocalRepository: BaseLocalRepository {
    
    public func save(_ task: TaskProtocol) {
        if let realmTask = task as? RealmTask {
            save(object: realmTask)
            return
        }
        save(object: RealmTask(task))
    }
    
    public func save(_ tasks: [TaskProtocol]) {
        tasks.forEach { (task) in
            save(task)
        }
    }
    
    public func save(_ tasks: [TaskProtocol], order: [String: [String]]) {
        tasks.forEach { (task) in
            task.order = order[(task.type ?? "")+"s"]?.index(of: task.id ?? "") ?? 0
            save(task)
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
    
    public func getUserStats(id: String) -> SignalProducer<StatsProtocol, ReactiveSwiftRealmError> {
        return RealmUser.findBy(key: id).map({ user -> StatsProtocol? in
            return user?.stats
        }).skipNil()
    }
    
    public func update(taskId: String, stats: StatsProtocol, direction: TaskScoringDirection, response: TaskResponseProtocol) {
        RealmTask.findBy(key: taskId).take(first: 1).skipNil().on(value: { realmTask in
            try? self.realm?.write {
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
}
