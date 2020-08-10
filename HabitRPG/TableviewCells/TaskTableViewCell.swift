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
import PinLayout

@objc
class TaskTableViewCell: UITableViewCell, UITextViewDelegate {

    //swiftlint:disable private_outlet
    @IBOutlet weak var titleLabel: UITextView!
    @IBOutlet weak var subtitleLabel: UITextView!
    @IBOutlet weak var taskDetailLine: TaskDetailLineView!
    @IBOutlet weak var mainTaskWrapper: UIView!
    @IBOutlet weak var syncingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var syncErrorIndicator: UIImageView!
    //swiftlint:disable private_outlet
    
    var contentStartEdge: HorizontalEdge?
    var contentEndEdge: HorizontalEdge?
    var minHeight: CGFloat {
        return 46
    }
    
    @objc public var isLocked: Bool = false

    @objc var syncErrorTouched: (() -> Void)?
    @objc var openForm: (() -> Void)?
    @objc var challengeIconTapped: (() -> Void)?
    
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
        
        taskDetailLine.onChallengeIconTapped = {[weak self] in
            if let action = self?.challengeIconTapped {
                action()
            }
        }
        
        contentStartEdge = mainTaskWrapper.edge.start
        contentEndEdge = mainTaskWrapper.edge.end
    }
    
    @objc
    func configure(task: TaskProtocol) {
        self.titleLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 15)
        self.titleLabel.textContainerInset = UIEdgeInsets.zero
        self.subtitleLabel.textContainerInset = UIEdgeInsets.zero
        if let text = task.text {
            let mutableString = try? Down(markdownString: text.unicodeEmoji).toHabiticaAttributedString(baseSize: 15, textColor: ThemeService.shared.theme.primaryTextColor)
            let strLength = mutableString?.string.count ?? 0
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 2
            mutableString?.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: strLength))

            self.titleLabel.attributedText = mutableString
        }

        if let trimmedNotes = task.notes?.trimmingCharacters(in: .whitespacesAndNewlines), trimmedNotes.isEmpty == false {
            self.subtitleLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 11)
            self.subtitleLabel.attributedText = try? Down(markdownString: trimmedNotes.unicodeEmoji).toHabiticaAttributedString(baseSize: 11, textColor: ThemeService.shared.theme.ternaryTextColor)
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

        self.setNeedsLayout()
        
        self.applyAccessibility(task)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        mainTaskWrapper.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        titleLabel.backgroundColor = mainTaskWrapper.backgroundColor
        subtitleLabel.backgroundColor = mainTaskWrapper.backgroundColor
        titleLabel.textColor = ThemeService.shared.theme.primaryTextColor
        subtitleLabel.textColor = ThemeService.shared.theme.ternaryTextColor
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
    
    override func layoutSubviews() {
        layout()
        super.layoutSubviews()
    }
    
    func layoutContentStartEdge() {
        
    }
    
    func layoutContentEndEdge() {
        
    }
    
    func layout() {
        mainTaskWrapper.pin.horizontally(10).top(4)
        var lastView: UIView = titleLabel
        if let contentStartEdge = contentStartEdge, let contentEndEdge = contentEndEdge {
            layoutContentStartEdge()
            layoutContentEndEdge()
            titleLabel.pin.top(10).start(to: contentStartEdge).marginStart(10).marginEnd(11).end(to: contentEndEdge).sizeToFit(.width)
            if !subtitleLabel.text.isEmpty {
                subtitleLabel.pin.below(of: lastView).marginTop(1).start(to: contentStartEdge).marginStart(10).marginEnd(11).end(to: contentEndEdge).sizeToFit(.width)
                lastView = subtitleLabel
            }
            if !taskDetailLine.isHidden {
                taskDetailLine.pin.below(of: lastView).marginTop(7).start(to: contentStartEdge).marginStart(12).marginEnd(12).end(to: contentEndEdge).sizeToFit(.width)
                lastView = taskDetailLine
            }
        }
        var height = lastView.frame.origin.y + lastView.frame.size.height + 10
        if lastView == subtitleLabel {
            height += 7
        }
        mainTaskWrapper.pin.height(max(height, minHeight))
        if lastView == titleLabel {
            titleLabel.pin.vCenter()
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.width(size.width)
        layout()
        return CGSize(width: contentView.frame.width, height: mainTaskWrapper.frame.size.height + 8)
    }
}
