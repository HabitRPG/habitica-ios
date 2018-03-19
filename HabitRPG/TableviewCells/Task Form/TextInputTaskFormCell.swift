//
//  TextInputTaskFormCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

enum TaskInputType {
    case title
    case notes
}

class TextInputTaskFormCell: UITableViewCell, TaskFormCell {
    
    var inputType: TaskInputType = .title {
        didSet {
            if inputType == .title {
                topSpacingConstraint.constant = 12
                bottomSpacingConstraint.constant = 4
            } else {
                topSpacingConstraint.constant = 4
                bottomSpacingConstraint.constant = 12
            }
        }
    }
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var topSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSpacingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: bounds.size.width)
    }
    
    func configureFor(task: TaskProtocol) {
        switch inputType {
        case .title:
            titleLabel.text = L10n.title
            textField.text = task.text?.unicodeEmoji
        case .notes:
            titleLabel.text = L10n.notes
            textField.text = task.notes?.unicodeEmoji
        }
    }
    
    func setTaskTintColor(color: UIColor) {
        cellBackgroundView.backgroundColor = color
        textField.backgroundColor = color.darker(by: 16)
    }
}
