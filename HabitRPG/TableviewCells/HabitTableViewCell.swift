//
//  HRPGHabitTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class HabitTableViewCell: TaskTableViewCell {

    //swiftlint:disable:next private_outlet
    @IBOutlet weak var plusButton: HabitButton!
    //swiftlint:disable:next private_outlet
    @IBOutlet weak var minusButton: HabitButton!

    @objc var plusTouched: (() -> Void)?
    @objc var minusTouched: (() -> Void)?

    override func configure(task: TaskProtocol) {
        super.configure(task: task)
        self.plusButton.configure(task: task, isNegative: false)
        self.minusButton.configure(task: task, isNegative: true)
        self.plusButton.action = {[weak self] in
            self?.scoreUp()
        }
        self.minusButton.action = {[weak self] in
            self?.scoreDown()
        }
    }
    
    override func applyAccessibility(_ task: TaskProtocol) {
        super.applyAccessibility(task)
        var customActions = [UIAccessibilityCustomAction]()
        if task.up {
            customActions.append(UIAccessibilityCustomAction(name: NSLocalizedString("Score habit up", comment: ""), target: self, selector: #selector(scoreUp)))
        }
        if task.down {
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
