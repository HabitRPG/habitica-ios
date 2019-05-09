//
//  HabitControlsFormRow.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Eureka

struct HabitControlsValue: Equatable {
    static func == (lhs: HabitControlsValue, rhs: HabitControlsValue) -> Bool {
        return lhs.positive == rhs.positive && lhs.negative == rhs.negative
    }
    
    var positive = true
    var negative = false
}

class HabitControlsCell: Cell<HabitControlsValue>, CellType {
    
    @IBOutlet weak var plusControlView: UIView!
    @IBOutlet weak var plusControlIconView: UIImageView!
    @IBOutlet weak var plusControlLabel: UILabel!
    @IBOutlet weak var minusControlView: UIView!
    @IBOutlet weak var minusControlIconView: UIImageView!
    @IBOutlet weak var minusControlLabel: UILabel!
    
    override public func setup() {
        super.setup()
        plusControlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(plusTapped)))
        minusControlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(minusTapped)))
        
        if row.value == nil {
            row.value = HabitControlsValue()
        }
        
        contentView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor.withAlphaComponent(0.8)
    }

    @objc
    private func plusTapped() {
        row.value?.positive = !(row.value?.positive ?? false)
        row.updateCell()
        if #available(iOS 10, *) {
            UISelectionFeedbackGenerator.oneShotSelectionChanged()
        }
    }
    
    @objc
    private func minusTapped() {
        row.value?.negative = !(row.value?.negative ?? false)
        row.updateCell()
        if #available(iOS 10, *) {
            UISelectionFeedbackGenerator.oneShotSelectionChanged()
        }
    }

    public override func update() {
        if let taskRow = row as? HabitControlsRow {
            plusControlIconView.image = HabiticaIcons.imageOfHabitControlPlus(taskTintColor: taskRow.tintColor, isActive: taskRow.value?.positive ?? false)
            if taskRow.value?.positive == true {
                plusControlLabel.textColor = taskRow.tintColor
            } else {
                plusControlLabel.textColor = UIColor.gray200()
            }
            minusControlIconView.image = HabiticaIcons.imageOfHabitControlMinus(taskTintColor: taskRow.tintColor, isActive: taskRow.value?.negative ?? false)
            if taskRow.value?.negative == true {
                minusControlLabel.textColor = taskRow.tintColor
            } else {
                minusControlLabel.textColor = UIColor.gray200()
            }
            applyAccessibility()
        }
    }
    
    private func applyAccessibility() {
        if let taskRow = row as? HabitControlsRow {
            shouldGroupAccessibilityChildren = true
            isAccessibilityElement = true
            if taskRow.value?.positive == true && taskRow.value?.negative == true {
                accessibilityLabel = L10n.Tasks.Form.Accessibility.positiveAndNegativeEnabled
            } else if taskRow.value?.positive == true {
                accessibilityLabel = L10n.Tasks.Form.Accessibility.positiveEnabled
            } else if taskRow.value?.negative == true {
                accessibilityLabel = L10n.Tasks.Form.Accessibility.negativeEnabled
            }
            
            accessibilityCustomActions = []
            if taskRow.value?.positive == true {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.disablePositive, target: self, selector: #selector(plusTapped)))
            } else {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.enablePositive, target: self, selector: #selector(plusTapped)))
            }
            if taskRow.value?.negative == true {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.disableNegative, target: self, selector: #selector(minusTapped)))
            } else {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.enableNegative, target: self, selector: #selector(minusTapped)))
            }
        }
    }
}

final class HabitControlsRow: TaskRow<HabitControlsCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<HabitControlsCell>(nibName: "HabitControlsCell")
    }
}
