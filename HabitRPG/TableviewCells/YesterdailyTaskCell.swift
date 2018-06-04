//
//  File.swift
//  Habitica
//
//  Created by Phillip on 08.06.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class YesterdailyTaskCell: UITableViewCell {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var checkbox: CheckboxView!
    @IBOutlet weak var titleTextView: UILabel!
    @IBOutlet weak var checklistStackview: UIStackView!
    
    var onChecklistItemChecked: ((ChecklistItemProtocol) -> Void)?
    var checklistItems: [ChecklistItemProtocol]?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.wrapperView.layer.borderWidth = 1
        self.wrapperView.layer.borderColor = UIColor.lightGray.cgColor
    }

    func configure(task: TaskProtocol) {
        checkbox.configure(task: task)
        titleTextView.text = task.text?.unicodeEmoji

        checklistStackview.subviews.forEach { view in
            view.removeFromSuperview()
        }

        checklistItems = task.checklist
        for checklistItem in task.checklist {
            if let view = UIView.fromNib(nibName: "YesterdailyChecklistItem") {
                let label = view.viewWithTag(2) as? UILabel
                label?.text = checklistItem.text?.unicodeEmoji
                let checkbox = view.viewWithTag(1) as? CheckboxView
                checkbox?.configure(checklistItem: checklistItem, withTitle: false)
                checkbox?.backgroundColor = UIColor.gray700()
                checkbox?.wasTouched = {
                    if let checked = self.onChecklistItemChecked {
                        checked(checklistItem)
                    }
                }
                checklistStackview.addArrangedSubview(view)
                let recognizer = UITapGestureRecognizer(target: self, action: #selector(YesterdailyTaskCell.handleChecklistTap(recognizer:)))
                view.addGestureRecognizer(recognizer)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    @objc
    func handleChecklistTap(recognizer: UITapGestureRecognizer) {
        for (index, view) in checklistStackview.arrangedSubviews.enumerated() where view == recognizer.view {
            if let checked = self.onChecklistItemChecked, let item = checklistItems?[index] {
                checked(item)
            }
            return
        }
    }
    
}
