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

    @objc var plusTouched: (() -> Void)?
    @objc var minusTouched: (() -> Void)?

    override func configure(task: HRPGTaskProtocol) {
        super.configure(task: task)
        if let taskObject = task as? NSObjectProtocol & HRPGTaskProtocol {
            self.plusButton.isLocked = self.isLocked
            self.minusButton.isLocked = self.isLocked
            
            self.plusButton.configure(forTask: taskObject, isNegative: false)
            self.minusButton.configure(forTask: taskObject, isNegative: true)
        }
        if task is Task {
            self.plusButton.action({[weak self] in
                self?.scoreUp()
            })
            self.minusButton.action({[weak self] in
                self?.scoreDown()
            })
        }
    }
    
    override func applyAccessibility(_ task: Task) {
        super.applyAccessibility(task)
        var customActions = [UIAccessibilityCustomAction]()
        if task.up?.boolValue ?? false {
            customActions.append(UIAccessibilityCustomAction(name: NSLocalizedString("Score habit up", comment: ""), target: self, selector: #selector(scoreUp)))
        }
        if task.down?.boolValue ?? false {
            customActions.append(UIAccessibilityCustomAction(name: NSLocalizedString("Score habit down", comment: ""), target: self, selector: #selector(scoreDown)))
        }
        self.accessibilityCustomActions = customActions
    }
    
    @objc
    func scoreUp() {
        if let action = plusTouched {
            action()
        }
    }
    
    @objc
    func scoreDown() {
        if let action = minusTouched {
            action()
        }
    }
}
