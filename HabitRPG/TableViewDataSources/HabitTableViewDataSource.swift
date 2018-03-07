//
//  HabitTableViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class HabitTableViewDataSource: TaskTableViewDataSource {
    
    override func configure(cell: TaskTableViewCell, indexPath: IndexPath, task: TaskProtocol) {
        super.configure(cell: cell, indexPath: indexPath, task: task)
        if let habitCell = cell as? HabitTableViewCell {
            habitCell.plusTouched = {[weak self] in
                self?.disposable.inner.add(self?.repository.score(task: task, direction: .up).observeCompleted { })
            }
            habitCell.minusTouched = {[weak self] in
                self?.disposable.inner.add(self?.repository.score(task: task, direction: .down).observeCompleted { })
            }
        }
    }
    
}
