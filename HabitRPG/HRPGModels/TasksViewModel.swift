//
//  TasksViewModel.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/28/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import FunkyNetwork
import ReactiveSwift
import Result

protocol TasksViewModelInputs {
    func refresh()
}

protocol TasksViewModelOutputs {
    var tasksUpdatedSignal: Signal<[HRPGTask]?, NoError> { get }
}

protocol TasksViewModelType {
    var inputs: TasksViewModelInputs { get }
    var outputs: TasksViewModelOutputs { get }
}

class TasksViewModel: TasksViewModelType, TasksViewModelInputs, TasksViewModelOutputs {
    let tasksUpdatedSignal: Signal<[HRPGTask]?, NoError>
    let tasksProperty = MutableProperty<[HRPGTask]?>(nil)
    let tasksCall: GetTasksCall
    
    init(tasksCall: GetTasksCall = GetTasksCall()) {
        self.tasksCall = tasksCall
        
        self.tasksUpdatedSignal = tasksProperty.signal
        
        self.refreshProperty.signal.observeValues { _ in
            self.downloadTasks()
        }
    }
    
    let refreshProperty = MutableProperty()
    func refresh() {
        self.refreshProperty.value = ()
    }
    
    func downloadTasks() {
        tasksCall.fetchTasks().startWithResult { (result) in
            switch result {
            case let .success(tasks):
                self.tasksProperty.value = tasks
                break
            case let .failure(error):
                print(error)
                break
            }
        }
    }
    
    var inputs: TasksViewModelInputs { return self }
    var outputs: TasksViewModelOutputs { return self }

}
