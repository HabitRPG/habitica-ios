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
    @IBOutlet weak var checklistContainer: StackView!
    @IBOutlet weak var checklistIndicator: UIView!
    @IBOutlet weak var checklistIndicatorSeparator: UIView!
    @IBOutlet weak var checklistDoneLabel: UILabel!
    @IBOutlet weak var checklistTotalLabel: UILabel!
    @IBOutlet weak var checklistTapArea: UIView!
    @IBOutlet weak var checklistBoxBackground: UIView!
    
    weak var task: TaskProtocol?
    @objc var isExpanded = false
    @objc var checkboxTouched: (() -> Void)?
    @objc var checklistIndicatorTouched: (() -> Void)?
    @objc var checklistItemTouched: ((_ item: ChecklistItemProtocol) -> Void)?

    override var minHeight: CGFloat {
        if checklistIndicator.isHidden {
            return super.minHeight
        } else {
            return 67
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentStartEdge = checkBox.edge.end
        
        checklistTapArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandTask)))
    }
    
    override func configure(task: TaskProtocol) {
        self.task = task
        super.configure(task: task)
        self.checkBox.configure(task: task, completed: task.completed(by: userID) )
        self.checkBox.wasTouched = {[weak self] in
            self?.checkTask()
        }
        
        handleChecklist(task)
        
        if task.completed(by: userID)  {
            titleLabel.textColor = ThemeService.shared.theme.quadTextColor
            subtitleLabel.textColor = ThemeService.shared.theme.quadTextColor
        }
    }
    
    func handleChecklist(_ task: TaskProtocol) {
        let checklistCount = task.checklist.count
        let theme = ThemeService.shared.theme

        if checklistCount > 0 {
            var checkedCount = 0
            for item in task.checklist where item.completed {
                checkedCount += 1
            }
            checklistDoneLabel.text = "\(checkedCount)"
            checklistTotalLabel.text = "\(checklistCount)"
            if checkedCount == checklistCount {
                if theme.isDark {
                    checklistIndicator.backgroundColor = .gray50
                } else {
                    checklistIndicator.backgroundColor = theme.offsetBackgroundColor
                }
                checklistDoneLabel.textColor = theme.quadTextColor
                checklistTotalLabel.textColor = theme.quadTextColor
                checklistIndicatorSeparator.backgroundColor = theme.quadTextColor
            } else {
                if theme.isDark {
                    checklistIndicator.backgroundColor = .gray100
                } else {
                    checklistIndicator.backgroundColor = theme.ternaryTextColor
                }
                checklistDoneLabel.textColor = theme.lightTextColor
                checklistTotalLabel.textColor = theme.lightTextColor
                checklistIndicatorSeparator.backgroundColor = theme.lightTextColor
            }
            checklistIndicator.isHidden = false
            checklistTapArea.isHidden = false
        } else {
            checklistIndicator.isHidden = true
            checklistTapArea.isHidden = true
        }

        checklistContainer.backgroundColor = .clear
        checklistContainer.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        if isExpanded && checklistCount > 0 {
            addChecklistViews(task: task)
            if task.completed || (task.type == TaskType.daily.rawValue && !task.isDue) {
                if theme.isDark {
                    checklistBoxBackground.backgroundColor = .gray50
                } else {
                    checklistBoxBackground.backgroundColor = theme.offsetBackgroundColor
                }
            } else {
                checklistBoxBackground.backgroundColor = UIColor.forTaskValueExtraLight(task.value)
            }
            checklistBoxBackground.isHidden = false
            checklistContainer.isHidden = false
        } else {
            checklistBoxBackground.isHidden = true
            checklistContainer.isHidden = true
        }
    }
    
    private func addChecklistViews(task: TaskProtocol) {
        var checkColor = UIColor.white
        if task.completed(by: userID)  || (task.type == TaskType.daily.rawValue && !task.isDue) {
            checkColor = ThemeService.shared.theme.quadTextColor
        } else {
            checkColor = UIColor.forTaskValueDarkest(task.value)
        }
        var checkboxColor = UIColor.white
        if task.completed(by: userID)  || (task.type == TaskType.daily.rawValue && !task.isDue) {
            checkboxColor = ThemeService.shared.theme.separatorColor
        } else {
            checkboxColor = UIColor.forTaskValueLight(task.value)
        }

        for item in task.checklist {
            let checkbox = CheckboxView()
            checkbox.configure(checklistItem: item, withTitle: true, checkColor: checkColor, checkboxColor: checkboxColor, taskType: task.type)
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
        self.accessibilityWrapper?.accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Accessibility.completeTask, target: self, selector: #selector(checkTask)))

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
        if task.completed(by: userID) {
            stateText = L10n.Accessibility.completed
        }
        self.accessibilityWrapper?.accessibilityLabel = "\(stateText), \(accessibilityWrapper.accessibilityLabel ?? "")"
        
        let checklistCount = task.checklist.count
        if checklistCount > 0 {
            self.accessibilityWrapper?.accessibilityLabel = "\(accessibilityWrapper.accessibilityLabel ?? ""), \(checklistCount) checklist items"
            self.isAccessibilityElement = false
            if isExpanded {
                self.accessibilityWrapper?.accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Accessibility.collapseChecklist, target: self, selector: #selector(expandTask)))
            } else {
                self.accessibilityWrapper?.accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Accessibility.expandChecklist, target: self, selector: #selector(expandTask)))
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
    
    override func layoutContentStartEdge() {
        checkBox.pin.start().width(40)
    }
    
    override func layoutContentEndEdge() {
        if !checklistIndicator.isHidden {
            checklistIndicator.pin.end(12).width(24)
            contentEndEdge = checklistIndicator.edge.start
        } else {
            contentEndEdge = mainTaskWrapper.edge.end
        }
        super.layoutContentEndEdge()
    }
    
    override func layout() {
        super.layout()
        checkBox.pin.start().top().bottom().width(40)
        if !checklistIndicator.isHidden {
            checklistIndicator.pin.height(42).vCenter()
            checklistIndicatorSeparator.pin.width(12).height(1).center()
            checklistDoneLabel.pin.above(of: checklistIndicatorSeparator).marginBottom(2).start().end().sizeToFit(.width)
            checklistTotalLabel.pin.below(of: checklistIndicatorSeparator).marginTop(2).start().end().sizeToFit(.width)
            checklistTapArea.pin.start(to: checklistIndicator.edge.start).end(to: checklistIndicator.edge.end).margin(0, -15).top().bottom()
        }
        
        if isExpanded && (task?.checklist.count ?? 0) > 0 {
            checklistContainer.pin.below(of: checkBox).marginTop(10).start().end()
            var containerHeight: CGFloat = 0
            for checkbox in checklistContainer.arrangedSubviews {
                checkbox.pin.sizeToFit(.width)
                containerHeight += checkbox.frame.size.height
            }
            checklistContainer.pin.height(containerHeight)
            checklistBoxBackground.pin.below(of: checkBox).start().width(40).height(containerHeight + 20)
            mainTaskWrapper.pin.height(checklistBoxBackground.frame.origin.y + checklistBoxBackground.frame.size.height)
        }
    }
}
