//
//  TaskAttributeRow.swift
//  Habitica
//
//  Created by Phillip Thelen on 06.02.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Eureka

class TaskAttributeCell: Cell<String>, CellType {
    
    @IBOutlet weak var strengthButton: UILabel!
    @IBOutlet weak var intelligenceButton: UILabel!
    @IBOutlet weak var constitutionButton: UILabel!
    @IBOutlet weak var perceptionButton: UILabel!
    
    override public func setup() {
        super.setup()
        
        if row.value == nil {
            row.value = "str"
        }
        backgroundColor = .clear
        selectionStyle = .none
        
        strengthButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(strengthTapped)))
        intelligenceButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(intelligenceTapped)))
        constitutionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(constitutionTapped)))
        perceptionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(perceptionTapped)))
    }

    @objc
    private func strengthTapped() {
        if row.isDisabled {
            return
        }
        row.value = "str"
        row.updateCell()
        if #available(iOS 10, *) {
            UISelectionFeedbackGenerator.oneShotSelectionChanged()
        }
    }
    
    @objc
    private func intelligenceTapped() {
        if row.isDisabled {
            return
        }
        row.value = "int"
        row.updateCell()
        if #available(iOS 10, *) {
            UISelectionFeedbackGenerator.oneShotSelectionChanged()
        }
    }
    
    @objc
    private func constitutionTapped() {
        if row.isDisabled {
            return
        }
        row.value = "con"
        row.updateCell()
        if #available(iOS 10, *) {
            UISelectionFeedbackGenerator.oneShotSelectionChanged()
        }
    }
    
    @objc
    private func perceptionTapped() {
        if row.isDisabled {
            return
        }
        row.value = "per"
        row.updateCell()
        if #available(iOS 10, *) {
            UISelectionFeedbackGenerator.oneShotSelectionChanged()
        }
    }

    public override func update() {
        if let taskRow = row as? TaskAttributeRow {
            updateViews(taskRow: taskRow)
            applyAccessibility()
        }
        contentView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor.withAlphaComponent(0.8)
    }
    
    private func updateViews(taskRow: TaskAttributeRow) {
        updateView(view: strengthButton, viewValue: "str")
        updateView(view: intelligenceButton, viewValue: "int")
        updateView(view: constitutionButton, viewValue: "con")
        updateView(view: perceptionButton, viewValue: "per")
    }
    
    private func updateView(view: UILabel, viewValue: String) {
        if row.value == viewValue {
            view.backgroundColor = tintColor
            view.textColor = .white
        } else {
            view.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
            view.textColor = ThemeService.shared.theme.primaryTextColor
        }
    }
    
    func updateTintColor(_ newTint: UIColor) {
        self.tintColor = newTint
        (row as? TaskAttributeRow)?.tintColor = newTint
        update()
    }
    
    private func applyAccessibility() {
        if let taskRow = row as? TaskAttributeRow {
            shouldGroupAccessibilityChildren = true
            isAccessibilityElement = true
            accessibilityCustomActions = [
                UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.setAttribute(L10n.Stats.strengthTitle),
                                                                           target: self,
                                                                           selector: #selector(strengthTapped)),
            UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.setAttribute(L10n.Stats.intelligenceTitle),
                                                                           target: self,
                                                                           selector: #selector(intelligenceTapped)),
            UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.setAttribute(L10n.Stats.constitutionTitle),
                                                                           target: self,
                                                                           selector: #selector(constitutionTapped)),
            UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.setAttribute(L10n.Stats.perceptionTitle),
                                                                           target: self,
                                                                           selector: #selector(perceptionTapped))
            ]
            if taskRow.value == "str" {
                accessibilityLabel = L10n.Tasks.Form.Accessibility.attribute(L10n.Tasks.Form.trivial)
                accessibilityCustomActions?.remove(at: 0)
            } else if taskRow.value == "int" {
                accessibilityLabel = L10n.Tasks.Form.Accessibility.attribute(L10n.Tasks.Form.easy)
                accessibilityCustomActions?.remove(at: 1)
            } else if taskRow.value == "con" {
                accessibilityLabel = L10n.Tasks.Form.Accessibility.attribute(L10n.Tasks.Form.medium)
                accessibilityCustomActions?.remove(at: 2)
            } else if taskRow.value == "per" {
                accessibilityLabel = L10n.Tasks.Form.Accessibility.attribute(L10n.Tasks.Form.hard)
                accessibilityCustomActions?.remove(at: 3)
            }
        }
    }
}

final class TaskAttributeRow: TaskRow<TaskAttributeCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<TaskAttributeCell>(nibName: "TaskAttributeRow")
    }
    
    override func updateTintColor(_ newTint: UIColor) {
        super.updateTintColor(newTint)
        cell.updateTintColor(newTint)
    }
}
