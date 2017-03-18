//
//  HRPGTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/03/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit
import Down

@objc
class TaskTableViewCell: UITableViewCell {

    //swiftlint:disable private_outlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleNoteConstraint: NSLayoutConstraint!
    @IBOutlet weak var textWrapperView: UIView!
    @IBOutlet weak var taskDetailLine: TaskDetailLineView!
    @IBOutlet weak var taskDetailSpacing: NSLayoutConstraint!
    //swiftlint:disable private_outlet

    func configure(task: Task) {
        self.titleLabel.text = task.text?.unicodeEmoji
        self.titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        self.titleLabel.textColor = .black
        self.subtitleLabel.textColor = .gray50()

        if let trimmedNotes = task.notes?.trimmingCharacters(in: .whitespacesAndNewlines) {
            self.subtitleLabel.text = trimmedNotes.unicodeEmoji
            self.subtitleLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
            self.titleNoteConstraint.constant = 6.0
        } else {
            self.subtitleLabel.text = nil
            self.titleNoteConstraint.constant = 0
        }

        self.taskDetailLine.configure(task: task)
        if self.taskDetailLine.hasContent {
            self.taskDetailLine.isHidden = false
            self.taskDetailSpacing.constant = 4
        } else {
            self.taskDetailLine.isHidden = true
            self.taskDetailSpacing.constant = 0
        }

        self.setNeedsLayout()
    }
}
