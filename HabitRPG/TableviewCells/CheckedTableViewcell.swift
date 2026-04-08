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
    @IBOutlet weak var checklistDueIndicator: UIView!
    
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

        mainTaskWrapper.clipsToBounds = true
        checklistContainer.clipsToBounds = true
        checklistContainer.isHidden = true
        contentView.clipsToBounds = true
    }
    
    override func configure(task: TaskProtocol, isLocked: Bool = false) {
        self.task = task
        super.configure(task: task, isLocked: isLocked)
        self.checkBox.configure(task: task, completed: task.completed(by: userID), isLocked: isLocked)
        self.checkBox.wasTouched = {[weak self] in
            self?.checkTask()
        }
        
        self.handleChecklist(animate: false)
        
        if task.completed(by: userID) {
            titleLabel.textColor = ThemeService.shared.theme.quadTextColor
            subtitleLabel.textColor = ThemeService.shared.theme.quadTextColor
        }
    }
    
    func handleChecklist(animate: Bool) {
        guard let task = self.task else {
            return
        }
        let checklistCount = task.checklist.count
        let theme = ThemeService.shared.theme

        var checklistDueAlpha: CGFloat = 1
        
        if checklistCount > 0 {
            var checkedCount = 0
            for item in task.checklist where item.completed {
                checkedCount += 1
            }
            checklistDoneLabel.text = "\(checkedCount)"
            checklistDoneLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 12, ofWeight: .medium)
            checklistTotalLabel.text = "\(checklistCount)"
            checklistTotalLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 12, ofWeight: .medium)
            checklistIndicator.backgroundColor = theme.offsetBackgroundColor
            checklistIndicator.cornerRadius = UIConstants.smallCornerRadius
            if checkedCount == checklistCount {
                checklistDoneLabel.textColor = theme.quadTextColor
                checklistTotalLabel.textColor = theme.quadTextColor
                checklistIndicatorSeparator.backgroundColor = theme.quadTextColor
                checklistDueAlpha = 0
            } else {
                checklistDoneLabel.textColor = theme.primaryTextColor
                checklistTotalLabel.textColor = theme.primaryTextColor
                checklistIndicatorSeparator.backgroundColor = theme.primaryTextColor
                checklistDueIndicator.backgroundColor = .forTaskValue(task.value)
                checklistDueAlpha = isExpanded ? 0 : 1
            }
            checklistIndicator.isHidden = false
            checklistTapArea.isHidden = false
        } else {
            checklistIndicator.isHidden = true
            checklistDueAlpha = 0
            checklistTapArea.isHidden = true
        }
        if animate {
            UIView.animate(withDuration: 0.3) {
                self.checklistDueIndicator.alpha = checklistDueAlpha
            }
        } else {
            self.checklistDueIndicator.alpha = checklistDueAlpha
        }

        checklistContainer.backgroundColor = .clear
        if isExpanded && checklistCount > 0 {
            checklistContainer.arrangedSubviews.forEach { (view) in
                view.removeFromSuperview()
            }
            addChecklistViews(task: task)
            if animate {
                checklistContainer.alpha = 0
                checklistContainer.isHidden = false
                UIView.animate(withDuration: 0.4) {
                    self.checklistContainer.alpha = 1
                }
            } else {
                checklistContainer.isHidden = false
                checklistContainer.alpha = 1
            }
        } else {
            if animate {
                checklistContainer.alpha = 1
                UIView.animate(withDuration: 0.3) {
                    self.checklistContainer.alpha = 0
                } completion: { _ in
                    self.checklistContainer.arrangedSubviews.forEach { (view) in
                        view.removeFromSuperview()
                    }
                    self.checklistContainer.isHidden = true
                }

            } else {
                checklistContainer.arrangedSubviews.forEach { (view) in
                    view.removeFromSuperview()
                }
                checklistContainer.isHidden = true
            }
        }
    }
    
    private func addChecklistViews(task: TaskProtocol) {
        for item in task.checklist {
            let checkbox = CheckboxView()
            checkbox.configure(checklistItem: item, withTitle: true, taskType: task.type)
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
            let lineHeight = checklistTotalLabel.font.lineHeight
            let charCount = max(checklistTotalLabel.text?.count ?? 0, checklistDoneLabel.text?.count ?? 0)
            checklistIndicator.pin.height(lineHeight * 2 + 10).vCenter().minWidth(32).width(CGFloat(charCount) * 0.7 * lineHeight + 16).end(12)
            checklistIndicatorSeparator.pin.width(10).height(1).center()
            checklistDoneLabel.pin.above(of: checklistIndicatorSeparator).marginBottom(2).start().end().sizeToFit(.width)
            checklistTotalLabel.pin.below(of: checklistIndicatorSeparator).marginTop(2).start().end().sizeToFit(.width)
            checklistTapArea.pin.start(to: checklistIndicator.edge.start).end().margin(0, -15).top().bottom()
            checklistDueIndicator.pin
                .right(to: checklistIndicator.edge.end)
                .marginEnd(-2)
                .top(to: checklistIndicator.edge.top)
                .marginTop(-2)
                .size(10)
        }
        
        if isExpanded && (task?.checklist.count ?? 0) > 0 {
            checklistContainer.pin.below(of: checkBox).marginTop(10).start().end()
            var containerHeight: CGFloat = 0
            for checkbox in checklistContainer.arrangedSubviews {
                let height = max(50, checkbox.intrinsicContentSize.height)
                containerHeight += height
            }
            checklistContainer.pin.height(containerHeight)
            mainTaskWrapper.pin.height(checkBox.frame.origin.y + checkBox.frame.size.height + containerHeight + 20)
        }
    }
}
