//
//  ResetStreakTaskFormCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class ResetStreakTaskFormCell: UITableViewCell, TaskFormCell {
    
    @IBOutlet weak var control: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureFor(task: TaskProtocol) {
        
    }
    
    func setTaskTintColor(color: UIColor) {
        control.tintColor = color
    }
}
