//
//  TodoTableViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

@objc
class TodoTableViewDataSourceInstantiator: NSObject {
    @objc
    static func instantiate(predicate: NSPredicate) -> TaskTableViewDataSourceProtocol {
        return TodoTableViewDataSource(predicate: predicate, taskType: TaskType.todo)
    }
}

class TodoTableViewDataSource: TaskTableViewDataSource {
    
    let dateFormatter = DateFormatter()
    
    override init(predicate: NSPredicate, taskType: TaskType) {
        super.init(predicate: predicate, taskType: taskType)
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
    }
    
    override func configure(cell: TaskTableViewCell, indexPath: IndexPath, task: TaskProtocol) {
        if let todocell = cell as? ToDoTableViewCell {
            todocell.taskDetailLine.dateFormatter = dateFormatter
            todocell.checkboxTouched = {[weak self] in
                self?.disposable.inner.add(self?.repository.score(task: task, direction: task.completed ? .down : .up).observeCompleted {})
            }
            todocell.checklistItemTouched = { checklistItem in
                
            }
            todocell.checklistIndicatorTouched = {[weak self] in
                self?.expandSelectedCell(indexPath: indexPath)
            }
        }
        super.configure(cell: cell, indexPath: indexPath, task: task)
    }
    
    override func predicates(filterType: Int) -> [NSPredicate] {
        var predicates = super.predicates(filterType: filterType)
        switch filterType {
        case 0:
            predicates.append(NSPredicate(format: "completed == false"))
        case 1:
            predicates.append(NSPredicate(format: "completed == false && duedate != nil"))
        case 2:
            predicates.append(NSPredicate(format: "completed == true"))
        default:
            break
        }
        return predicates
    }
}
