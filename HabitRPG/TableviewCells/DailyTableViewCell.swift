//
//  HRPGDailyTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation

class DailyTableViewCell: CheckedTableViewCell {
    func configure(task: Task, offset: Int) {
        super.configure(task: task)
        if !(task.completed) {
            if !task.isDue {
                self.checklistIndicator.backgroundColor = .gray600()
                self.checklistDoneLabel.textColor = .gray100()
                self.checklistAllLabel.textColor = .gray100()
                self.checklistSeparator.backgroundColor = .gray100()
                self.checklistLeftBorderView.backgroundColor = .gray500()
                self.checklistRightBorderView.backgroundColor = .gray500()
            }
        }
    }
}
