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
    
    weak var task: TaskProtocol?
    @objc var isExpanded = false
    @objc var checkboxTouched: (() -> Void)?
    @objc var checklistIndicatorTouched: (() -> Void)?
    @objc var checklistItemTouched: ((_ item: ChecklistItemProtocol) -> Void)?

    override func awakeFromNib() {
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
            self.checklistIndicator.backgroundColor = .gray500()
            self.checklistDoneLabel.textColor = .gray300()
            self.checklistAllLabel.textColor = .gray300()
            self.checklistSeparator.backgroundColor = .gray300()
            self.checklistLeftBorderView.backgroundColor = .gray400()
            self.checklistRightBorderView.backgroundColor = .gray400()
        }
        
        if task.completed {
            self.checklistIndicator.backgroundColor = .gray500()
            self.titleLabel.textColor = .gray300()
            self.backgroundColor = ThemeService.shared.theme.contentBackgroundColorDimmed
        } else {
            self.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
            self.titleLabel.textColor = ThemeService.shared.theme.primaryTextColor
        }

        self.titleLabel.backgroundColor = self.backgroundColor
        self.subtitleLabel.backgroundColor = self.backgroundColor
        self.contentView.backgroundColor = self.backgroundColor
        self.mainTaskWrapper.backgroundColor = self.backgroundColor
        
        self.checklistIndicator.layoutIfNeeded()
    }
    
    func handleChecklist(_ task: TaskProtocol) {
        self.checklistIndicator.backgroundColor = UIColor.forTaskValueLight(Int(task.value))
        self.checklistLeftBorderView.backgroundColor = UIColor.forTaskValue(Int(task.value))
        self.checklistRightBorderView.backgroundColor = UIColor.forTaskValue(Int(task.value))
        self.checklistIndicator.isHidden = false
        self.checklistIndicator.translatesAutoresizingMaskIntoConstraints = false
        let checklistCount = task.checklist.count
        
        if checklistCount > 0 {
            var checkedCount = 0
            for item in task.checklist where item.completed {
                checkedCount += 1
            }
            self.checklistDoneLabel.text = "\(checkedCount)"
            self.checklistAllLabel.text = "\(checklistCount)"
            self.checklistDoneLabel.textColor = .white
            self.checklistAllLabel.textColor = .white
            self.checklistSeparator.backgroundColor = .white
            if checkedCount == checklistCount {
                self.checklistIndicator.backgroundColor = .gray500()
                self.checklistDoneLabel.textColor = .gray300()
                self.checklistAllLabel.textColor = .gray300()
                self.checklistSeparator.backgroundColor = .gray300()
                self.checklistLeftBorderView.backgroundColor = .gray400()
                self.checklistRightBorderView.backgroundColor = .gray400()
            }
            self.checklistDoneLabel.isHidden = false
            self.checklistAllLabel.isHidden = false
            self.checklistSeparator.isHidden = false
            if UI_USER_INTERFACE_IDIOM() == .pad {
                self.checklistIndicatorWidth.constant = 48.0
            } else {
                self.checklistIndicatorWidth.constant = 36.0
            }
        } else {
            self.checklistDoneLabel.isHidden = true
            self.checklistAllLabel.isHidden = true
            self.checklistSeparator.isHidden = true
            self.checklistIndicatorWidth.constant = 0
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
