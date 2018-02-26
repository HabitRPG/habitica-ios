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
    @IBOutlet weak var mainTaskWrapper: UIView!
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
        self.mainTaskWrapper.accessibilityCustomActions = []
        self.mainTaskWrapper.shouldGroupAccessibilityChildren = true
        self.mainTaskWrapper.isAccessibilityElement = true
        self.mainTaskWrapper.accessibilityHint = NSLocalizedString("Double tap to edit", comment: "")
        self.mainTaskWrapper.accessibilityLabel = "\(task.text ?? "")"
        self.mainTaskWrapper.accessibilityLabel = "\(self.accessibilityLabel ?? ""), Value: \(String.forTaskQuality(task: task))"
        if let notes = task.notes, !notes.isEmpty {
            self.mainTaskWrapper.accessibilityLabel = "\(self.accessibilityLabel ?? ""), \(notes)"
        }
    }
}
