//
//  DailyTableViewDataSoure.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

@objc
class DailyTableViewDataSourceInstantiator: NSObject {
    @objc
    static func instantiate(predicate: NSPredicate) -> TaskTableViewDataSourceProtocol {
        return DailyTableViewDataSource(predicate: predicate, taskType: TaskType.daily)
    }
}

class DailyTableViewDataSource: TaskTableViewDataSource {
    
    override func configure(cell: TaskTableViewCell, indexPath: IndexPath, task: TaskProtocol) {
        super.configure(cell: cell, indexPath: indexPath, task: task)
        if let dailycell = cell as? DailyTableViewCell {
            dailycell.checkboxTouched = {[weak self] in
                self?.disposable.inner.add(self?.repository.score(task: task, direction: task.completed ? .down : .up).observeCompleted {})
            }
            dailycell.checklistItemTouched = {[weak self] checklistItem in
                self?.disposable.inner.add(self?.repository.score(checklistItem: checklistItem, task: task).observeCompleted {})
            }
            dailycell.checklistIndicatorTouched = {[weak self] in
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
