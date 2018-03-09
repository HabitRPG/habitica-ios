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
import Result

class TaskRepository: BaseRepository<TaskLocalRepository>, TaskRepositoryProtocol {
    
    func retrieveTasks() -> Signal<[TaskProtocol]?, NoError> {
        let call = RetrieveTasksCall()
        call.fire()
        return call.arraySignal.on(value: {[weak self] tasks in
            if let tasks = tasks {
                self?.localRepository.save(tasks)
            }
        })
    }
    
    func getTasks(predicate: NSPredicate) -> SignalProducer<ReactiveResults<[TaskProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getTasks(predicate: predicate)
    }
    
    func save(_ tasks: [TaskProtocol], order: [String: [String]]) {
        localRepository.save(tasks, order: order)
    }
    
    func score(task: TaskProtocol, direction: TaskScoringDirection) -> Signal<TaskResponseProtocol?, NoError> {
        let call = ScoreTaskCall(task: task, direction: direction)
        call.fire()
        return call.objectSignal.on(value: {[weak self] taskResponse in
            if task.type != "reward", let taskId = task.id, let response = taskResponse {
                self?.localRepository.updateScoredTask(id: taskId, direction: direction, response: response)
            }
            let toastView = ToastView(healthDiff: taskResponse?.health ?? 0,
                                      magicDiff: taskResponse?.magic ?? 0,
                                      expDiff: taskResponse?.experience ?? 0,
                                      goldDiff: taskResponse?.gold ?? 0,
                                      questDamage: 0,
                                      background: .green)
            ToastManager.show(toast: toastView)
        })
    }
}
