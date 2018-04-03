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
        return TodoTableViewDataSource(predicate: predicate)
    }
}

class TodoTableViewDataSource: TaskTableViewDataSource {
    
    override func configure(cell: TaskTableViewCell, indexPath: IndexPath, task: TaskProtocol) {
        super.configure(cell: cell, indexPath: indexPath, task: task)
        if let todocell = cell as? ToDoTableViewCell {
            todocell.checkboxTouched = {[weak self] in
                self?.disposable.inner.add(self?.repository.score(task: task, direction: task.completed ? .down : .up).observeCompleted {})
            }
            todocell.checklistItemTouched = {[weak self] checklistItem in
                
            }
            todocell.checklistIndicatorTouched = {[weak self] in
                self?.expandSelectedCell(indexPath: indexPath)
            }
        }
    }
    
}
