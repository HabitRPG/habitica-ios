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
    @IBOutlet weak var titleLabel: UITextView!
    @IBOutlet weak var subtitleLabel: UITextView!
    @IBOutlet weak var taskDetailLine: TaskDetailLineView!
    @IBOutlet weak var mainTaskWrapper: UIView!
    @IBOutlet weak var syncingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var syncErrorIndicator: UIImageView!
    @IBOutlet weak var syncIndicatorsWidth: NSLayoutConstraint!
    @IBOutlet weak var syncIndicatorsSpacing: NSLayoutConstraint!
    //swiftlint:disable private_outlet
    
    @objc public var isLocked: Bool = false

    @objc var syncErrorTouched: (() -> Void)?
    @objc var openForm: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        syncErrorIndicator.image = HabiticaIcons.imageOfInfoIcon(infoIconColor: UIColor.red50)
        
        syncErrorIndicator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(syncErrorTapped)))
        
        var gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openFormTapped))
        gestureRecognizer.delegate = self
        gestureRecognizer.cancelsTouchesInView = false
        titleLabel.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openFormTapped))
        gestureRecognizer.delegate = self
        gestureRecognizer.cancelsTouchesInView = false
        subtitleLabel.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc
    func configure(task: TaskProtocol) {
        self.titleLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 16)
        if let text = task.text {
            self.titleLabel.attributedText = try? Down(markdownString: text.unicodeEmoji).toHabiticaAttributedString(baseSize: 16, textColor: ThemeService.shared.theme.primaryTextColor)
        }

        if let trimmedNotes = task.notes?.trimmingCharacters(in: .whitespacesAndNewlines), trimmedNotes.isEmpty == false {
            self.subtitleLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 13)
            self.subtitleLabel.attributedText = try? Down(markdownString: trimmedNotes.unicodeEmoji).toHabiticaAttributedString(baseSize: 13, textColor: ThemeService.shared.theme.secondaryTextColor)
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
        
        contentView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        mainTaskWrapper.backgroundColor = contentView.backgroundColor
        titleLabel.backgroundColor = contentView.backgroundColor
        subtitleLabel.backgroundColor = contentView.backgroundColor
    }
    
    func applyAccessibility(_ task: TaskProtocol) {
        self.mainTaskWrapper.accessibilityCustomActions = []
        self.mainTaskWrapper.shouldGroupAccessibilityChildren = true
        self.mainTaskWrapper.isAccessibilityElement = true
        self.mainTaskWrapper.accessibilityHint = L10n.Accessibility.doubleTapToEdit
        self.mainTaskWrapper.accessibilityLabel = "\(task.text ?? "")"
        self.mainTaskWrapper.accessibilityLabel = "\(self.mainTaskWrapper.accessibilityLabel ?? ""), Value: \(String.forTaskQuality(task: task))"
        if let notes = task.notes, !notes.isEmpty {
            self.mainTaskWrapper.accessibilityLabel = "\(self.mainTaskWrapper.accessibilityLabel ?? ""), \(notes)"
        }
    }
    
    @objc
    private func syncErrorTapped() {
        if let action = syncErrorTouched {
            action()
        }
    }
    
    @objc
    private func openFormTapped() {
        if let action = openForm {
            action()
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return !RouterHandler.shared.handle(url: URL)
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: titleLabel.superview)
        if titleLabel.frame.contains(location) && titleLabel == gestureRecognizer.view {
            let layoutManager = titleLabel.layoutManager
            var messageViewLocation = touch.location(in: titleLabel)
            messageViewLocation.x -= titleLabel.textContainerInset.left
            messageViewLocation.y -= titleLabel.textContainerInset.top
            let characterIndex = layoutManager.characterIndex(for: messageViewLocation, in: titleLabel.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            if characterIndex < titleLabel.textStorage.length {
                let attributes = titleLabel.textStorage.attributes(at: characterIndex, effectiveRange: nil)
                if attributes[NSAttributedString.Key.link] != nil {
                    return false
                }
            }
        }
        if subtitleLabel.frame.contains(location) && subtitleLabel == gestureRecognizer.view {
            let layoutManager = subtitleLabel.layoutManager
            var messageViewLocation = touch.location(in: subtitleLabel)
            messageViewLocation.x -= subtitleLabel.textContainerInset.left
            messageViewLocation.y -= subtitleLabel.textContainerInset.top
            let characterIndex = layoutManager.characterIndex(for: messageViewLocation, in: subtitleLabel.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            if characterIndex < subtitleLabel.textStorage.length {
                let attributes = subtitleLabel.textStorage.attributes(at: characterIndex, effectiveRange: nil)
                if attributes[NSAttributedString.Key.link] != nil {
                    return false
                }
            }
        }
        return true
    }
}
