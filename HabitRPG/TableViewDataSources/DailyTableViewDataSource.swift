//
//  DailyTableViewDataSoure.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class DailyTableViewDataSource: TaskTableViewDataSource {
    
    init(predicate: NSPredicate) {
        super.init(predicate: predicate, taskType: TaskType.daily)
    }
    
    override func configure(cell: TaskTableViewCell, indexPath: IndexPath, task: TaskProtocol) {
        super.configure(cell: cell, indexPath: indexPath, task: task)
        if let dailycell = cell as? DailyTableViewCell {
            dailycell.checkboxTouched = {[weak self] in
                if task.isValid == false {
                    return
                }
                self?.scoreTask(task: task, direction: task.completed ? .down : .up, soundEffect: .dailyCompleted)
            }
            dailycell.checklistItemTouched = {[weak self] checklistItem in
                if task.isValid == false {
                    return
                }
                self?.disposable.add(self?.repository.score(checklistItem: checklistItem, task: task).observeCompleted {})
            }
            dailycell.checklistIndicatorTouched = {[weak self] in
                if task.isValid == false {
                    return
                }
                self?.expandSelectedCell(indexPath: indexPath)
            }
        }
    }
    
    override func predicates(filterType: Int) -> [NSPredicate] {
        var predicates = super.predicates(filterType: filterType)
        switch filterType {
        case 1:
            predicates.append(NSPredicate(format: "completed == false && isDue == true"))
        case 2:
            predicates.append(NSPredicate(format: "completed == true || isDue == false"))
        default:
            break
        }
        return predicates
    }
}
