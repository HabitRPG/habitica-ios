//
//  HabitDifficultyRow.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Eureka

public class TaskDifficultyCell: Cell<Float>, CellType {
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
    
    public override func setup() {
        super.setup()
        trivialControlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(trivialTapped)))
        easyControlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(easyTapped)))
        mediumControlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mediumTapped)))
        hardControlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hardTapped)))
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    @objc
    private func trivialTapped() {
        row.value = 0.1
        row.updateCell()
        if #available(iOS 10, *) {
            UISelectionFeedbackGenerator.oneShotSelectionChanged()
        }
        accessibilityValue = L10n.Tasks.Form.Accessibility.taskDifficulty(L10n.Tasks.Form.trivial)
    }
    
    @objc
    private func easyTapped() {
        row.value = 1
        row.updateCell()
        if #available(iOS 10, *) {
            UISelectionFeedbackGenerator.oneShotSelectionChanged()
        }
        accessibilityValue = L10n.Tasks.Form.Accessibility.taskDifficulty(L10n.Tasks.Form.easy)
    }
    
    @objc
    private func mediumTapped() {
        row.value = 1.5
        row.updateCell()
        if #available(iOS 10, *) {
            UISelectionFeedbackGenerator.oneShotSelectionChanged()
        }
        accessibilityValue = L10n.Tasks.Form.Accessibility.taskDifficulty(L10n.Tasks.Form.medium)
    }
    
    @objc
    private func hardTapped() {
        row.value = 2
        row.updateCell()
        if #available(iOS 10, *) {
            UISelectionFeedbackGenerator.oneShotSelectionChanged()
        }
        accessibilityValue = L10n.Tasks.Form.Accessibility.taskDifficulty(L10n.Tasks.Form.hard)
    }

    public override func update() {
        if let taskRow = row as? TaskDifficultyRow {
            updateViews(taskRow: taskRow)
            applyAccessibility()
        }
        contentView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor.withAlphaComponent(0.8)
    }
    
    private func updateViews(taskRow: TaskDifficultyRow) {
        if taskRow.value == 0.1 {
            trivialControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskRow.tintColor, difficulty: 0.1, isActive: true)
            trivialControlLabel.textColor = taskRow.tintColor
        } else {
            trivialControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskRow.tintColor, difficulty: 0.1, isActive: false)
            trivialControlLabel.textColor = ThemeService.shared.theme.ternaryTextColor
        }
        if taskRow.value == 1 {
            easyControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskRow.tintColor, difficulty: 1, isActive: true)
            easyControlLabel.textColor = taskRow.tintColor
        } else {
            easyControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskRow.tintColor, difficulty: 1, isActive: false)
            easyControlLabel.textColor = ThemeService.shared.theme.ternaryTextColor
        }
        if taskRow.value == 1.5 {
            mediumControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskRow.tintColor, difficulty: 1.5, isActive: true)
            mediumControlLabel.textColor = ThemeService.shared.theme.ternaryTextColor
        } else {
            mediumControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskRow.tintColor, difficulty: 1.5, isActive: false)
            mediumControlLabel.textColor = ThemeService.shared.theme.ternaryTextColor
        }
        if taskRow.value == 2 {
            hardControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskRow.tintColor, difficulty: 2, isActive: true)
            hardControlLabel.textColor = taskRow.tintColor
        } else {
            hardControlIconView.image = HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: taskRow.tintColor, difficulty: 2, isActive: false)
            hardControlLabel.textColor = ThemeService.shared.theme.ternaryTextColor
        }
    }
    
    func updateTintColor(_ newTint: UIColor) {
        self.tintColor = newTint
        (row as? TaskDifficultyRow)?.tintColor = newTint
        update()
    }
    
    private func applyAccessibility() {
        if let taskRow = row as? TaskDifficultyRow {
            shouldGroupAccessibilityChildren = true
            isAccessibilityElement = true
            accessibilityTraits = .adjustable
            if taskRow.value == 0.1 {
                accessibilityLabel = L10n.Tasks.Form.Accessibility.taskDifficulty(L10n.Tasks.Form.trivial)
            } else if taskRow.value == 1.0 {
                accessibilityLabel = L10n.Tasks.Form.Accessibility.taskDifficulty(L10n.Tasks.Form.easy)
            } else if taskRow.value == 1.5 {
                accessibilityLabel = L10n.Tasks.Form.Accessibility.taskDifficulty(L10n.Tasks.Form.medium)
            } else if taskRow.value == 2.0 {
                accessibilityLabel = L10n.Tasks.Form.Accessibility.taskDifficulty(L10n.Tasks.Form.hard)
            }
        }
    }
    
    public override func accessibilityIncrement() {
        super.accessibilityIncrement()
        if let taskRow = row as? TaskDifficultyRow {
            if taskRow.value == 0.1 {
                easyTapped()
            } else if taskRow.value == 1.0 {
                mediumTapped()
            } else if taskRow.value == 1.5 {
                hardTapped()
            } else if taskRow.value == 2.0 {
                trivialTapped()
            }
        }
    }
    
    public override func accessibilityDecrement() {
        super.accessibilityIncrement()
        if let taskRow = row as? TaskDifficultyRow {
            if taskRow.value == 0.1 {
                hardTapped()
                
            } else if taskRow.value == 1.0 {
                trivialTapped()
            } else if taskRow.value == 1.5 {
                easyTapped()
            } else if taskRow.value == 2.0 {
                mediumTapped()
            }
        }
    }
}

final class TaskDifficultyRow: TaskRow<TaskDifficultyCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<TaskDifficultyCell>(nibName: "TaskDifficultyCell")
    }
}
