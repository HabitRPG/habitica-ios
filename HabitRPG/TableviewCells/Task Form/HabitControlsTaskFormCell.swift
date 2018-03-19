//
//  HabitControlsTaskFormCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class HabitControlsTaskFormCell: UITableViewCell, TaskFormCell {
    
    private var taskTintColor = UIColor.purple300()
    
    @IBOutlet weak var plusControlView: UIView!
    @IBOutlet weak var plusControlIconView: UIImageView!
    @IBOutlet weak var plusControlLabel: UILabel!
    @IBOutlet weak var minusControlView: UIView!
    @IBOutlet weak var minusControlIconView: UIImageView!
    @IBOutlet weak var minusControlLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        plusControlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(plusTapped)))
        minusControlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(minusTapped)))
    }
    
    func configureFor(task: TaskProtocol) {
        plusControlIconView.image = HabiticaIcons.imageOfHabitControlPlus(taskTintColor: taskTintColor, isActive: task.up)
        if task.up {
            plusControlLabel.textColor = taskTintColor
        } else {
            plusControlLabel.textColor = UIColor.gray200()
        }
        minusControlIconView.image = HabiticaIcons.imageOfHabitControlMinus(taskTintColor: taskTintColor, isActive: task.down)
        if task.down {
            minusControlLabel.textColor = taskTintColor
        } else {
            minusControlLabel.textColor = UIColor.gray200()
        }
    }
    
    func setTaskTintColor(color: UIColor) {
        taskTintColor = color
    }
    
    @objc
    private func plusTapped() {
        
    }
    
    @objc
    private func minusTapped() {
        
    }
}

