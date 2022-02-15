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
    
    let monthDayFormatter = DateFormatter()
    let shortLocalizedFormatter = DateFormatter()
    
    init(predicate: NSPredicate) {
        super.init(predicate: predicate, taskType: TaskType.todo)
        
        monthDayFormatter.dateStyle = .none
        monthDayFormatter.timeStyle = .none
        monthDayFormatter.setLocalizedDateFormatFromTemplate("MMMd")
        
        guard let preferredLocale = Locale.preferredLanguages.first else {
            return
        }
        shortLocalizedFormatter.dateStyle = .none
        shortLocalizedFormatter.timeStyle = .none
        shortLocalizedFormatter.locale = Locale.init(identifier: preferredLocale)
        shortLocalizedFormatter.setLocalizedDateFormatFromTemplate("yy-MM-dd")
    }
    
    override func configure(cell: TaskTableViewCell, indexPath: IndexPath, task: TaskProtocol) {
        if let todocell = cell as? ToDoTableViewCell {
            todocell.taskDetailLine.monthDayFormatter = monthDayFormatter
            todocell.taskDetailLine.shortLocalizedFormatter = shortLocalizedFormatter
            
            todocell.checkboxTouched = {[weak self] in
                if !task.isValid {
                    return
                }
                self?.scoreTask(task: task, direction: task.completed ? .down : .up, soundEffect: .todoCompleted)
            }
            todocell.checklistItemTouched = {[weak self] checklistItem in
                if !task.isValid {
                    return
                }
                self?.disposable.add(self?.repository.score(checklistItem: checklistItem, task: task).observeCompleted {})
            }
            todocell.checklistIndicatorTouched = {[weak self] in
                if !task.isValid {
                    return
                }
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
