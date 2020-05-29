//
//  TodoTableViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class TodoTableViewDataSource: TaskTableViewDataSource {
    
    let dateFormatter = DateFormatter()
    
    init(predicate: NSPredicate) {
        super.init(predicate: predicate, taskType: TaskType.todo)
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
    }
    
    override func configure(cell: TaskTableViewCell, indexPath: IndexPath, task: TaskProtocol) {
        if let todocell = cell as? ToDoTableViewCell {
            todocell.taskDetailLine.dateFormatter = dateFormatter
            todocell.checkboxTouched = {[weak self] in
                self?.disposable.add(self?.repository.score(task: task, direction: task.completed ? .down : .up).observeCompleted {
                    SoundManager.shared.play(effect: .todoCompleted)
                    })
            }
            todocell.checklistItemTouched = {[weak self] checklistItem in
                self?.disposable.add(self?.repository.score(checklistItem: checklistItem, task: task).observeCompleted {})
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
