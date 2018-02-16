//
//  TaskRepository.swift
//  Habitica
//
//  Created by Phillip Thelen on 14.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift

class TaskRepository: BaseRepository<TaskLocalRepository> {
    
    func getTasks() -> SignalProducer<RealmReactiveResults<Task>, ReactiveSwiftRealmError> {
        return localRepository.getTasks()
    }
    
}
