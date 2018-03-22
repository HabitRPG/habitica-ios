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
    
    func save(task: TaskProtocol) {
        localRepository.save(task)
    }
    
    func score(task: TaskProtocol, direction: TaskScoringDirection) -> Signal<TaskResponseProtocol?, NoError> {
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
            
            if task.type != "reward", let taskId = task.id {
                self?.localRepository.update(taskId: taskId, stats: stats, direction: direction, response: response)
            }
            
            let toastView = ToastView(healthDiff: healthDiff,
                                      magicDiff: magicDiff,
                                      expDiff: expDiff,
                                      goldDiff: goldDiff,
                                      questDamage: 0,
                                      background: healthDiff >= 0 ? .green : .red)
            ToastManager.show(toast: toastView)
        }).map({ (response, _) in
            return response
        })
    }
    
    func getNewTask() -> TaskProtocol {
        return localRepository.getNewTask()
    }
    
    func getEditableTask(id: String) -> TaskProtocol? {
        return localRepository.getEditableTask(id: id)
    }
}
