//
//  HRPGTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Down

@objc
class TaskTableViewCell: UITableViewCell {

    //swiftlint:disable private_outlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var taskDetailLine: TaskDetailLineView!
    //swiftlint:disable private_outlet

    @objc
    func configure(task: HRPGTaskProtocol) {
        if let text = task.text {
            self.titleLabel.attributedText = try? Down(markdownString: text.unicodeEmoji).toHabiticaAttributedString()
        }
        self.titleLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 16)
        self.titleLabel.textColor = .gray10()
        self.subtitleLabel.textColor = .gray200()

        if let trimmedNotes = task.notes?.trimmingCharacters(in: .whitespacesAndNewlines), trimmedNotes.count > 0 {
            self.subtitleLabel.text = trimmedNotes.unicodeEmoji
            self.subtitleLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
            self.subtitleLabel.isHidden = false
        } else {
            self.subtitleLabel.text = nil
            self.subtitleLabel.isHidden = true
        }

        self.taskDetailLine.configure(task: task)
        self.taskDetailLine.isHidden = !self.taskDetailLine.hasContent

        self.setNeedsLayout()
        
        if let task = task as? Task {
            self.applyAccessibility(task)
        }
    }
    
    func applyAccessibility(_ task: Task) {
        self.shouldGroupAccessibilityChildren = true
        self.isAccessibilityElement = true
        self.accessibilityHint = NSLocalizedString("Double tap to edit", comment: "")
    }
    
    func configureNew(task: HRPGTask) {
        self.titleLabel.text = task.text.unicodeEmoji
        self.titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        self.titleLabel.textColor = .gray10()
        self.subtitleLabel.textColor = .gray200()
        
        let trimmedNotes = task.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedNotes.characters.count > 0 {
            self.subtitleLabel.text = trimmedNotes.unicodeEmoji
            self.subtitleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
            self.subtitleLabel.isHidden = false
        } else {
            self.subtitleLabel.text = nil
            self.subtitleLabel.isHidden = true
        }
        
        self.taskDetailLine.configureNew(task: task)
        self.taskDetailLine.isHidden = !self.taskDetailLine.hasContent
        
        self.setNeedsLayout()
    }
}
