//
//  DifficultyTaskFormCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class DifficultyTaskFormCell: UITableViewCell, TaskFormCell {
    
    private var taskTintColor = UIColor.purple300()
    
    @IBOutlet weak var trivialControlView: UIView!
    @IBOutlet weak var trivialControlIconView: UIImageView!
    @IBOutlet weak var trivialControlLabel: UILabel!
    
    @IBOutlet weak var easyControlView: UIView!
    @IBOutlet weak var easyControlIconView: UIImageView!
    @IBOutlet weak var easyControlLabel: UILabel!
    
    @IBOutlet weak var mediumControlView: UIView!
    @IBOutlet weak var mediumControlIconView: UIImageView!
    @IBOutlet weak var mediumControlLabel: UILabel!
    
    @IBOutlet weak var hardControlView: UIView!
    @IBOutlet weak var hardControlIconView: UIImageView!
    @IBOutlet weak var hardControlLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        trivialControlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trivialTapped)))
        easyControlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(easyTapped)))
        mediumControlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mediumTapped)))
        hardControlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hardTapped)))

    }
    
    func configureFor(task: TaskProtocol) {
        if task.priority == 0.1 {
            trivialControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskTintColor, difficulty: 0.1, isActive: true)
            trivialControlLabel.textColor = taskTintColor
        } else {
            trivialControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskTintColor, difficulty: 0.1, isActive: false)
            trivialControlLabel.textColor = UIColor.gray200()
        }
        if task.priority == 1 {
            easyControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskTintColor, difficulty: 1, isActive: true)
            easyControlLabel.textColor = taskTintColor
        } else {
            easyControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskTintColor, difficulty: 1, isActive: false)
            easyControlLabel.textColor = UIColor.gray200()
        }
        if task.priority == 2 {
            mediumControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskTintColor, difficulty: 2, isActive: true)
            mediumControlLabel.textColor = taskTintColor
        } else {
            mediumControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskTintColor, difficulty: 2, isActive: false)
            mediumControlLabel.textColor = UIColor.gray200()
        }
        if task.priority == 3 {
            hardControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskTintColor, difficulty: 3, isActive: true)
            hardControlLabel.textColor = taskTintColor
        } else {
            hardControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskTintColor, difficulty: 3, isActive: false)
            hardControlLabel.textColor = UIColor.gray200()
        }
    }
    
    func setTaskTintColor(color: UIColor) {
        taskTintColor = color
    }
    
    @objc
    private func trivialTapped() {
        
    }
    
    @objc
    private func easyTapped() {
        
    }
    
    @objc
    private func mediumTapped() {
        
    }
    
    @objc
    private func hardTapped() {
        
    }
}

