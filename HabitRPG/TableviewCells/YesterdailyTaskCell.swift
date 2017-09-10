//
//  File.swift
//  Habitica
//
//  Created by Phillip on 08.06.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class YesterdailyTaskCell: UITableViewCell {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var checkbox: HRPGCheckBoxView!
    @IBOutlet weak var titleTextView: UILabel!
    @IBOutlet weak var checklistStackview: UIStackView!
    
    var onChecklistItemChecked: ((ChecklistItem) -> Void)?
    var checklistItems: [ChecklistItem]?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.wrapperView.layer.borderWidth = 1
        self.wrapperView.layer.borderColor = UIColor.lightGray.cgColor
    }

    func configure(task: Task) {
        checkbox.configure(for: task)
        titleTextView.text = task.text.unicodeEmoji

        checklistStackview.subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        //TODO: Checklists
        /*guard let checklist = task.checklist else {
            return
        }
        checklistItems = checklist.array as? [ChecklistItem]
        for item in checklist {
            if let view = UIView.fromNib(nibName: "YesterdailyChecklistItem"), let checklistItem = item as? ChecklistItem {
                let label = view.viewWithTag(2) as? UILabel
                label?.text = checklistItem.text.unicodeEmoji
                let checkbox = view.viewWithTag(1) as? HRPGCheckBoxView
                checkbox?.configure(for: checklistItem, withTitle:false)
                checkbox?.backgroundColor = UIColor.gray700()
                checklistStackview.addArrangedSubview(view)
                let recognizer = UITapGestureRecognizer(target: self, action:#selector(YesterdailyTaskCell.handleChecklistTap(recognizer:)))
                view.addGestureRecognizer(recognizer)
            }
        }*/
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func handleChecklistTap(recognizer: UITapGestureRecognizer) {
        for (index, view) in checklistStackview.arrangedSubviews.enumerated() where view == recognizer.view {
            if let checked = self.onChecklistItemChecked, let item = checklistItems?[index] {
                checked(item)
            }
            return
        }
    }
    
}
