//
//  HRPGDailyTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/03/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Foundation

class DailyTableViewCell: CheckedTableViewCell {
    func configure(task: Task, offset: Int) {
        super.configure(task: task)
        if !(task.completed?.boolValue ?? false) {
            if task.dueToday(withOffset: offset) {
                self.titleLabel.textColor = .black
            } else {
                self.titleLabel.textColor = .darkGray
                self.checklistIndicator.backgroundColor = .gray100()
            }
        }
    }
}
