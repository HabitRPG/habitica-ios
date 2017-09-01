//
//  HRPGHabitTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class HabitTableViewCell: TaskTableViewCell {

    //swiftlint:disable:next private_outlet
    @IBOutlet weak var plusButton: HRPGHabitButtons!
    //swiftlint:disable:next private_outlet
    @IBOutlet weak var minusButton: HRPGHabitButtons!

    override func configure(task: Task) {
        super.configure(task: task)
        self.plusButton.configure(for: task, isNegative: false)
        self.minusButton.configure(for: task, isNegative: true)
    }
}
