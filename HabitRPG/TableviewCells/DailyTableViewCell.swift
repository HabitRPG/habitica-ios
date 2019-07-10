//
//  HRPGDailyTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class DailyTableViewCell: CheckedTableViewCell {
    @objc
    func configure(task: TaskProtocol, offset: Int) {
        super.configure(task: task)
        if !(task.completed) {
            if !task.dueToday() {
                checklistIndicator.backgroundColor = .gray600()
                checklistDoneLabel.textColor = .gray100()
                checklistAllLabel.textColor = .gray100()
                checklistSeparator.backgroundColor = .gray100()
                checklistLeftBorderView.backgroundColor = .gray500()
                checklistRightBorderView.backgroundColor = .gray500()
            }
        }
    }
}
