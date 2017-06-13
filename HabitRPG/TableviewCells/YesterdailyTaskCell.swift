//
//  File.swift
//  Habitica
//
//  Created by Phillip on 08.06.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class YesterdailyTaskCell: UITableViewCell {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var checkbox: HRPGCheckBoxView!
    @IBOutlet weak var titleTextView: UILabel!
    @IBOutlet weak var checklistStackview: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.wrapperView.layer.borderWidth = 1
        self.wrapperView.layer.borderColor = UIColor.lightGray.cgColor
    }

    func configure(task: Task) {
        checkbox.configure(for: task)
        titleTextView.text = task.text
        
        checklistStackview.subviews.forEach { view in
            view.removeFromSuperview()
        }
        task.checklist?.forEach { item in
            let checklistItem = item as? ChecklistItem
            let label = UILabel()
            label.text = checklistItem?.text
            checklistStackview.addArrangedSubview(label)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
