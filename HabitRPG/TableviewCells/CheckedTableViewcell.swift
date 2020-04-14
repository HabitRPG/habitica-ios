//
//  HRPGCheckedTableViewcell.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Down
import Habitica_Models

class CheckedTableViewCell: TaskTableViewCell {

    @IBOutlet weak var checkBox: CheckboxView!
    @IBOutlet weak var checklistIndicator: UIView!
    @IBOutlet weak var checklistDoneLabel: UILabel!
    @IBOutlet weak var checklistAllLabel: UILabel!
    @IBOutlet weak var checklistSeparator: UIView!
    @IBOutlet weak var checklistIndicatorWidth: NSLayoutConstraint!
    @IBOutlet weak var checklistContainer: UIStackView!
    @IBOutlet weak var checklistLeftBorderView: UIView!
    @IBOutlet weak var checklistRightBorderView: UIView!
    @IBOutlet weak var checklistItemBackgroundView: UIView!
    @IBOutlet weak var dimmOverlayRightView: UIView!
    @IBOutlet weak var dimmOverlayLeftView: UIView!
    
    weak var task: TaskProtocol?
    @objc var isExpanded = false
    @objc var checkboxTouched: (() -> Void)?
    @objc var checklistIndicatorTouched: (() -> Void)?
    @objc var checklistItemTouched: ((_ item: ChecklistItemProtocol) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        checklistIndicator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandTask)))
    }
    
    override func configure(task: TaskProtocol) {
        self.task = task
        super.configure(task: task)
        self.checkBox.configure(task: task)
        self.checkBox.wasTouched = {[weak self] in
            self?.checkTask()
        }
        
        handleChecklist(task)

        if task.completed || (!task.isDue && task.type == TaskType.daily.rawValue) {
            checklistIndicator.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
            checklistDoneLabel.textColor = ThemeService.shared.theme.quadTextColor
            checklistAllLabel.textColor = ThemeService.shared.theme.quadTextColor
            checklistSeparator.backgroundColor = ThemeService.shared.theme.quadTextColor
            checklistLeftBorderView.backgroundColor = ThemeService.shared.theme.dimmedTextColor
            checklistRightBorderView.backgroundColor = ThemeService.shared.theme.dimmedTextColor
        }
        
        if task.completed {
            self.checklistIndicator.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
            self.titleLabel.textColor = ThemeService.shared.theme.quadTextColor
            self.backgroundColor = ThemeService.shared.theme.contentBackgroundColorDimmed
        } else {
            self.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
            self.titleLabel.textColor = ThemeService.shared.theme.primaryTextColor
        }

        self.titleLabel.backgroundColor = self.backgroundColor
        self.subtitleLabel.backgroundColor = self.backgroundColor
        self.contentView.backgroundColor = self.backgroundColor
        self.mainTaskWrapper.backgroundColor = self.backgroundColor
        
        dimmOverlayLeftView.isHidden = !ThemeService.shared.theme.isDark
        dimmOverlayLeftView.backgroundColor = ThemeService.shared.theme.taskOverlayTint
        dimmOverlayRightView.isHidden = !ThemeService.shared.theme.isDark
        dimmOverlayRightView.backgroundColor = ThemeService.shared.theme.taskOverlayTint
        
        self.checklistIndicator.layoutIfNeeded()
    }
    
    func handleChecklist(_ task: TaskProtocol) {
        self.checklistIndicator.backgroundColor = UIColor.forTaskValueLight(Int(task.value))
        checklistLeftBorderView.backgroundColor = UIColor.forTaskValue(Int(task.value))
        checklistRightBorderView.backgroundColor = UIColor.forTaskValue(Int(task.value))
        checklistIndicator.isHidden = false
        checklistIndicator.translatesAutoresizingMaskIntoConstraints = false
        let checklistCount = task.checklist.count
        
        if checklistCount > 0 {
            var checkedCount = 0
            for item in task.checklist where item.completed {
                checkedCount += 1
            }
            checklistDoneLabel.text = "\(checkedCount)"
            checklistAllLabel.text = "\(checklistCount)"
            checklistDoneLabel.textColor = .white
            checklistAllLabel.textColor = .white
            checklistSeparator.backgroundColor = .white
            if checkedCount == checklistCount {
                checklistIndicator.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
                checklistDoneLabel.textColor = ThemeService.shared.theme.quadTextColor
                checklistAllLabel.textColor = ThemeService.shared.theme.quadTextColor
                checklistSeparator.backgroundColor = ThemeService.shared.theme.quadTextColor
                checklistLeftBorderView.backgroundColor = ThemeService.shared.theme.dimmedTextColor
                checklistRightBorderView.backgroundColor = ThemeService.shared.theme.dimmedTextColor
            }
            checklistDoneLabel.isHidden = false
            checklistAllLabel.isHidden = false
            checklistSeparator.isHidden = false
            if UI_USER_INTERFACE_IDIOM() == .pad {
                checklistIndicatorWidth.constant = 48.0
            } else {
                checklistIndicatorWidth.constant = 36.0
            }
        } else {
            checklistDoneLabel.isHidden = true
            checklistAllLabel.isHidden = true
            checklistSeparator.isHidden = true
            checklistIndicatorWidth.constant = 0
        }
        
        checklistContainer.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        if isExpanded {
            addChecklistViews(task: task)
        }
        checklistItemBackgroundView.backgroundColor = ThemeService.shared.theme.contentBackgroundColorDimmed
    }
    
    private func addChecklistViews(task: TaskProtocol) {
        for item in task.checklist {
            let checkbox = CheckboxView()
            checkbox.configure(checklistItem: item, withTitle: true)
            checklistContainer.addArrangedSubview(checkbox)
            checkbox.wasTouched = {[weak self] in
                if let action = self?.checklistItemTouched {
                    action(item)
                }
            }
            if item.completed {
                checkbox.accessibilityLabel = L10n.Accessibility.completedX(item.text ?? "")
            } else {
                checkbox.accessibilityLabel = L10n.Accessibility.notCompletedX(item.text ?? "")
            }
            checkbox.shouldGroupAccessibilityChildren = true
            checkbox.isAccessibilityElement = true
            checkbox.accessibilityHint = L10n.Accessibility.doubleTapToComplete
        }
    }
    
    override func applyAccessibility(_ task: TaskProtocol) {
        super.applyAccessibility(task)
        self.mainTaskWrapper?.accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Accessibility.completeTask, target: self, selector: #selector(checkTask)))

        var stateText = ""
        if task.type == "daily" {
            if task.isDue {
                stateText = L10n.Accessibility.due
            } else {
                stateText = L10n.Accessibility.notDue
            }
        } else {
            stateText = L10n.Accessibility.notCompleted
        }
        if task.completed {
            stateText = L10n.Accessibility.completed
        }
        self.mainTaskWrapper?.accessibilityLabel = "\(stateText), \(mainTaskWrapper.accessibilityLabel ?? "")"
        
        let checklistCount = task.checklist.count
        if checklistCount > 0 {
            self.mainTaskWrapper?.accessibilityLabel = "\(mainTaskWrapper.accessibilityLabel ?? ""), \(checklistCount) checklist items"
            self.isAccessibilityElement = false
            if isExpanded {
                self.mainTaskWrapper?.accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Accessibility.collapseChecklist, target: self, selector: #selector(expandTask)))
            } else {
                self.mainTaskWrapper?.accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Accessibility.expandChecklist, target: self, selector: #selector(expandTask)))
            }
        }
    }
    
    @objc
    func checkTask() {
        if let action = checkboxTouched {
            action()
        }
    }
    
    @objc
    func expandTask() {
        if let action = checklistIndicatorTouched {
            action()
        }
    }
}
