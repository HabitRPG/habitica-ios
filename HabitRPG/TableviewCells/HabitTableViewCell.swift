//
//  HRPGHabitTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/03/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class HabitTableViewCell: TaskTableViewCell {
    
    @IBOutlet weak var plusButton: HRPGHabitButtons!
    @IBOutlet weak var minusButton: HRPGHabitButtons!
    
    override func configure(task: Task) {
        super.configure(task: task)
        self.plusButton.configure(for: task, isNegative: false)
        self.minusButton.configure(for: task, isNegative: true)
    }
}
