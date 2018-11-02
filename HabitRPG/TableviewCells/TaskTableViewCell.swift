//
//  HRPGTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Down
import Habitica_Models

@objc
class TaskTableViewCell: UITableViewCell, UITextViewDelegate {

    //swiftlint:disable private_outlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var taskDetailLine: TaskDetailLineView!
    @IBOutlet weak var mainTaskWrapper: UIView!
    @IBOutlet weak var syncingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var syncErrorIndicator: UIImageView!
    @IBOutlet weak var syncIndicatorsWidth: NSLayoutConstraint!
    @IBOutlet weak var syncIndicatorsSpacing: NSLayoutConstraint!
    //swiftlint:disable private_outlet
    
    @objc public var isLocked: Bool = false

    @objc var syncErrorTouched: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        syncErrorIndicator.image = HabiticaIcons.imageOfInfoIcon(infoIconColor: UIColor.red50())
        
        syncErrorIndicator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(syncErrorTapped)))
    }
    
    @objc
    func configure(task: TaskProtocol) {
        self.titleLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 16)
        if let text = task.text {
            self.titleLabel.attributedText = try? Down(markdownString: text.unicodeEmoji).toHabiticaAttributedString()
        }

        if let trimmedNotes = task.notes?.trimmingCharacters(in: .whitespacesAndNewlines), trimmedNotes.count > 0 {
            self.subtitleLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
            self.subtitleLabel.attributedText = try? Down(markdownString: trimmedNotes.unicodeEmoji).toHabiticaAttributedString()
            self.subtitleLabel.isHidden = false
        } else {
            self.subtitleLabel.text = nil
            self.subtitleLabel.isHidden = true
        }

        self.taskDetailLine.configure(task: task)
        self.taskDetailLine.isHidden = !self.taskDetailLine.hasContent
        
        self.syncingIndicator.isHidden = !task.isSyncing
        if !self.syncingIndicator.isHidden {
            self.syncingIndicator.startAnimating()
        }
        self.syncErrorIndicator.isHidden = task.isSyncing || task.isSynced
        
        if self.syncingIndicator.isHidden && self.syncErrorIndicator.isHidden {
            syncIndicatorsWidth.constant = 0
            syncIndicatorsSpacing.constant = 0
        } else {
            syncIndicatorsWidth.constant = 20
            syncIndicatorsSpacing.constant = 8
        }

        self.setNeedsLayout()
        
        self.applyAccessibility(task)
    }
    
    func applyAccessibility(_ task: TaskProtocol) {
        self.mainTaskWrapper.accessibilityCustomActions = []
        self.mainTaskWrapper.shouldGroupAccessibilityChildren = true
        self.mainTaskWrapper.isAccessibilityElement = true
        self.mainTaskWrapper.accessibilityHint = NSLocalizedString("Double tap to edit", comment: "")
        self.mainTaskWrapper.accessibilityLabel = "\(task.text ?? "")"
        self.mainTaskWrapper.accessibilityLabel = "\(self.mainTaskWrapper.accessibilityLabel ?? ""), Value: \(String.forTaskQuality(task: task))"
        if let notes = task.notes, !notes.isEmpty {
            self.mainTaskWrapper.accessibilityLabel = "\(self.mainTaskWrapper.accessibilityLabel ?? ""), \(notes)"
        }
        
        contentView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        titleLabel.textColor = ThemeService.shared.theme.primaryTextColor
        subtitleLabel.textColor = ThemeService.shared.theme.secondaryTextColor
    }
    
    @objc
    private func syncErrorTapped() {
        if let action = syncErrorTouched {
            action()
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return RouterHandler.shared.handle(url: URL)
    }
}
