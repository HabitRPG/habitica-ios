//
//  HRPGCheckedTableViewcell.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/03/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit
import Down

class CheckedTableViewCell: TaskTableViewCell {

    //swiftlint:disable:next private_outlet
    @IBOutlet weak var checkBox: HRPGCheckBoxView!
    //swiftlint:disable:next private_outlet
    @IBOutlet weak var checklistIndicator: UIView!
    @IBOutlet weak private var checklistDoneLabel: UILabel!
    @IBOutlet weak private var checklistAllLabel: UILabel!
    @IBOutlet weak private var checklistSeparator: UIView!
    @IBOutlet weak private var checklistIndicatorWidth: NSLayoutConstraint!

    override func configure(task: Task) {
        super.configure(task: task)
        self.checkBox.configure(for: task)
        self.checklistIndicator.backgroundColor = task.lightTaskColor()
        self.checklistIndicator.isHidden = false
        self.checklistIndicator.translatesAutoresizingMaskIntoConstraints = false
        let checklistCount = task.checklist?.count ?? 0
        if checklistCount > 0 {
            var checkedCount = 0
            if let checklist = task.checklist?.array as? [ChecklistItem] {
                for item in checklist {
                    if item.completed.boolValue {
                        checkedCount += 1
                    }
                }
            }
            self.checklistDoneLabel.text = "\(checkedCount)"
            self.checklistAllLabel.text = "\(checklistCount)"
            if checkedCount == checklistCount {
                self.checklistIndicator.backgroundColor = .gray100()
            }
            self.checklistDoneLabel.isHidden = false
            self.checklistAllLabel.isHidden = false
            self.checklistSeparator.isHidden = false
            self.checklistIndicatorWidth.constant = 37.0
        } else {
            self.checklistDoneLabel.isHidden = true
            self.checklistAllLabel.isHidden = true
            self.checklistSeparator.isHidden = true
            self.checklistIndicatorWidth.constant = 0
        }

        if task.completed?.boolValue ?? false {
            self.backgroundColor = .gray500()
            self.checklistIndicator.backgroundColor = .gray100()
            self.titleLabel.textColor = .gray50()
        } else {
            self.backgroundColor = .white
            self.titleLabel.textColor = .black
        }

        self.titleLabel.backgroundColor = self.backgroundColor
        self.subtitleLabel.backgroundColor = self.backgroundColor
        self.textWrapperView.backgroundColor = self.backgroundColor

        self.checklistIndicator.layoutIfNeeded()
    }

    func configure(checklistItem: ChecklistItem, task: Task) {
        if task.completed?.boolValue ?? false {
            self.backgroundColor = .gray500()
            self.checklistIndicator.backgroundColor = .gray100()
            self.titleLabel.textColor = .gray50()
        } else {
            self.backgroundColor = .white
            self.titleLabel.textColor = .black
        }
        self.titleLabel.text = checklistItem.text.unicodeEmoji
        self.titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        self.checkBox.configure(for: checklistItem, for: task)
        self.checklistIndicator.isHidden = true
        self.subtitleLabel.text = nil
        self.titleNoteConstraint.constant = 0

        self.taskDetailLine.isHidden = true
        self.taskDetailSpacing.constant = 0
    }

}
