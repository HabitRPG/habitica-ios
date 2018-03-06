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
    
    public func getTasks(predicate: NSPredicate) -> SignalProducer<ReactiveResults<[TaskProtocol]>, ReactiveSwiftRealmError> {
        return RealmTask.findBy(predicate: predicate).reactive().map({ (value, changeset) -> ReactiveResults<[TaskProtocol]> in
            return (value.map({ (task) -> TaskProtocol in return task }), changeset)
        })
    }
}
