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
import ReactiveObjCBridge
import ReactiveObjC

class TaskRepository: BaseRepository<TaskLocalRepository>, TaskRepositoryProtocol {
    
    func retrieveTasks() {
        RetrieveTasksAPICall().execute { (tasks) in
            if let newTasks = tasks {
                self.localRepository.save(newTasks)
            }
        }
    }
    
    func getTasks(predicate: NSPredicate) -> SignalProducer<ReactiveResults<[TaskProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getTasks(predicate: predicate)
    }
}
