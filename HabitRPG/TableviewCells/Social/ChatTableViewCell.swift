//
//  ChatTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import DateTools
import PinLayout

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var avatarWrapper: UIView!
    @IBOutlet weak private var messageWrapper: UIView!
    @IBOutlet weak private var usernameLabel: UsernameLabel!
    @IBOutlet weak private var positionLabel: PaddedLabel!
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var messageTextView: UITextView!
    @IBOutlet weak private var plusOneButton: UIButton!
    @IBOutlet weak private var replyButton: UIButton!
    @IBOutlet weak private var copyButton: UIButton!
    @IBOutlet weak private var reportButton: UIButton!
    @IBOutlet weak private var deleteButton: UIButton!
    @IBOutlet weak var reportView: UIButton!
    
    @objc public var profileAction: (() -> Void)?
    @objc public var reportAction: (() -> Void)?
    @objc public var replyAction: (() -> Void)?
    @objc public var deleteAction: (() -> Void)?
    @objc public var plusOneAction: (() -> Void)?
    @objc public var copyAction: (() -> Void)?
    @objc public var expandAction: (() -> Void)?
    @objc public var isExpanded = false {
        didSet {
            showHideExtraButtons(isExpanded)
        }
    }
    @objc public var isFirstMessage = false
    
    private var topSpacing: CGFloat = 4
    private var bottomSpacing: CGFloat = 4
    private var leftSpacing: CGFloat = 12
    
    private var hideDeleteButton = false
    private var hideReportButton = false
    
    private var isOwnMessage = false {
        didSet {
            updateLeftMargin()
            avatarView.isHidden = isOwnMessage
            hideReportButton = isOwnMessage
            if !isModerator {
                hideDeleteButton = !isOwnMessage
            }
        }
    }
    private var isPrivateMessage = false
    private var isModerator = false {
        didSet {
            hideDeleteButton = false
        }
    }
    private var isAvatarHidden = false {
        didSet {
            avatarWrapper.isHidden = isAvatarHidden
            updateLeftMargin()
        }
    }
    
    private var contributorLevel = 0 {
        didSet {
            usernameLabel.contributorLevel = contributorLevel
            positionLabel.isHidden = contributorLevel < 8
            if contributorLevel == 8 {
                positionLabel.text = NSLocalizedString("Moderator", comment: "")
                positionLabel.backgroundColor = UIColor.blue10()
            } else if contributorLevel == 9 {
                positionLabel.text = NSLocalizedString("Staff", comment: "")
                positionLabel.backgroundColor = UIColor.purple300()
            }
        }
    }

    private var wasMentioned = false {
        didSet {
            if wasMentioned {
                messageWrapper.backgroundColor = UIColor.purple600()
            } else {
                messageWrapper.backgroundColor = .white
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let wrapperTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(expandCell))
        wrapperTapRecognizer.delegate = self
        wrapperTapRecognizer.cancelsTouchesInView = false
        messageWrapper.addGestureRecognizer(wrapperTapRecognizer)
        let messageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(expandCell))
        messageTapRecognizer.delegate = self
        messageTapRecognizer.cancelsTouchesInView = false
        messageTextView.addGestureRecognizer(messageTapRecognizer)
        
        usernameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displayProfile)))
        
        selectionStyle = .none
        backgroundColor = .white
        
        avatarView.size = .compact
        avatarView.showMount = false
        avatarView.showPet = false
        
        positionLabel.horizontalPadding = 8
        
        if frame.size.width < 375 {
            isAvatarHidden = true
        }
        
        reportView.setImage(#imageLiteral(resourceName: "ChatReport").withRenderingMode(.alwaysTemplate), for: .normal)
        
        messageTextView.font = CustomFontMetrics.scaledSystemFont(ofSize: 15, ofWeight: .regular)
    }
    
    @objc
    func configure(chatMessage: ChatMessage, previousMessage: ChatMessage?, nextMessage: ChatMessage?, userID: String, username: String, isModerator: Bool, isExpanded: Bool) {
        isPrivateMessage = false
        self.isModerator = isModerator
        isOwnMessage = chatMessage.uuid == userID
        wasMentioned = chatMessage.text?.range(of: username) != nil

        usernameLabel.text = chatMessage.user?.unicodeEmoji
        contributorLevel = chatMessage.contributorLevel?.intValue ?? 0
        messageTextView.textColor = UIColor.gray10()
        
        stylePlusOneButton(likes: chatMessage.likes, userID: userID)
        
        setTimeStamp(date: chatMessage.timestamp)
        
        if chatMessage.attributedText?.length ?? 0 > 0 {
            messageTextView.attributedText = chatMessage.attributedText
        } else {
            messageTextView.text = chatMessage.text?.unicodeEmoji
        }
        
        if previousMessage?.uuid == chatMessage.uuid {
            topSpacing = 2
            avatarView.isHidden = true
        } else {
            topSpacing = 4
            avatarView.isHidden = isOwnMessage

            if !isOwnMessage && !isAvatarHidden {
                avatarView.avatar = chatMessage.avatar
            }
        }
        
        if nextMessage?.uuid == chatMessage.uuid {
            bottomSpacing = 2
        } else if isFirstMessage {
            bottomSpacing = 34
        } else {
            bottomSpacing = 4
        }
        
        if let flags = chatMessage.flags, isModerator && flags.count > 0 {
            reportView.isHidden = false
            reportView.setTitle("\(flags.count)", for: .normal)
        } else {
            reportView.isHidden = true
        }
        
        self.isExpanded = isExpanded
        applyAccessibility()
        setNeedsLayout()
    }
    
    @objc
    func configure(inboxMessage: InboxMessage, previousMessage: InboxMessage?, nextMessage: InboxMessage?, user: User, isExpanded: Bool) {
        isPrivateMessage = true
        plusOneButton.isHidden = true
        isOwnMessage = inboxMessage.sent?.boolValue ?? false
        isAvatarHidden = true
        if inboxMessage.sent?.boolValue ?? false {
            usernameLabel.text = user.username.unicodeEmoji
            contributorLevel = user.contributorLevel.intValue
        } else {
            usernameLabel.text = inboxMessage.username?.unicodeEmoji
            contributorLevel = inboxMessage.contributorLevel?.intValue ?? 0
        }
        usernameLabel.contributorLevel = contributorLevel
        messageTextView.textColor = .black
        
        setTimeStamp(date: inboxMessage.timestamp)
        
        if inboxMessage.attributedText?.length ?? 0 > 0 {
            messageTextView.attributedText = inboxMessage.attributedText
        } else {
            messageTextView.text = inboxMessage.text?.unicodeEmoji
        }
        
        if previousMessage?.sent?.boolValue == inboxMessage.sent?.boolValue {
            topSpacing = 2
            avatarView.isHidden = true
        } else {
            topSpacing = 4
            avatarView.isHidden = isOwnMessage
        }
        
        if nextMessage?.sent?.boolValue == inboxMessage.sent?.boolValue {
            bottomSpacing = 2
        } else if isFirstMessage {
            bottomSpacing = 34
        } else {
            bottomSpacing = 4
        }
        
        self.isExpanded = isExpanded
        applyAccessibility()
        setNeedsLayout()
    }
    
    private func setTimeStamp(date: Date?) {
        timeLabel.text = (date as NSDate?)?.timeAgoSinceNow()
    }
    
    private func stylePlusOneButton(likes: Set<ChatMessageLike>?, userID: String) {
        plusOneButton.setTitle(nil, for: .normal)
        plusOneButton.setTitleColor(UIColor.gray300(), for: .normal)
        plusOneButton.tintColor = UIColor.gray300()
        var wasLiked = false
        if let likes = likes {
            let likedMessageCount = likes.filter({ (like) -> Bool in
                return like.wasLiked?.boolValue == true
            }).count
            if likedMessageCount > 0 {
                plusOneButton.setTitle(" +\(likedMessageCount)", for: .normal)
                for like in likes where like.userID == userID && like.wasLiked?.boolValue == true {
                    plusOneButton.setTitleColor(UIColor.purple400(), for: .normal)
                    plusOneButton.tintColor = UIColor.purple400()
                    wasLiked = true
                    break
                }
            }
        }
        plusOneButton.setImage(HabiticaIcons.imageOfChatLikeIcon(wasLiked: wasLiked), for: .normal)
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: contentView)
        if plusOneButton.frame.contains(location) {
            return false
        }
        if messageTextView.frame.contains(location) {
            if messageTextView == gestureRecognizer.view {
                return false
            }
            let layoutManager = messageTextView.layoutManager
            var messageViewLocation = touch.location(in: messageTextView)
            messageViewLocation.x -= messageTextView.textContainerInset.left
            messageViewLocation.y -= messageTextView.textContainerInset.top
            let characterIndex = layoutManager.characterIndex(for: messageViewLocation, in: messageTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            if characterIndex < messageTextView.textStorage.length {
                let attributes = messageTextView.textStorage.attributes(at: characterIndex, effectiveRange: nil)
                if attributes[NSAttributedStringKey.link] != nil {
                    return false
                }
            }
        }
        if usernameLabel.frame.contains(location) {
            return false
        }
        if replyButton.frame.contains(location) {
            return false
        }
        if copyButton.frame.contains(location) {
            return false
        }
        if reportButton.frame.contains(location) {
            return false
        }
        if deleteButton.frame.contains(location) {
            return false
        }
        return true
    }
    
    @objc
    private func displayProfile() {
        if let action = profileAction {
            action()
        }
    }
    
    @objc
    private func expandCell() {
        if let action = expandAction {
            action()
        }
    }
    
    @IBAction func plusOneButtonTapped(_ sender: Any) {
        if let action = plusOneAction {
            action()
        }
    }
    
    @IBAction func replyButtonTapped(_ sender: Any) {
        if let action = replyAction {
            action()
        }
    }
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        if let action = reportAction {
            action()
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        if let action = deleteAction {
            action()
        }
    }
    
    @IBAction func copyButtonTapped(_ sender: Any) {
        if let action = copyAction {
            action()
        }
    }
    
    private func showHideExtraButtons(_ shouldShow: Bool) {
        replyButton.isHidden = !shouldShow
        copyButton.isHidden = !shouldShow
        if shouldShow {
            reportButton.isHidden = hideReportButton
            deleteButton.isHidden = hideDeleteButton
        } else {
            reportButton.isHidden = true
            deleteButton.isHidden = true
        }
    }
    
    private func updateLeftMargin() {
        leftSpacing = 8
        if isAvatarHidden {
            leftSpacing = 12
        }
        if isOwnMessage {
            leftSpacing = 64
        }
    }
    
    private func applyAccessibility() {
        accessibilityLabel = "\(usernameLabel.text ?? ""), \(timeLabel.text ?? ""), \(messageTextView.text ?? "")"
        shouldGroupAccessibilityChildren = true
        messageTextView.isAccessibilityElement = false
        plusOneButton.isAccessibilityElement = false
        accessibilityCustomActions = [
            UIAccessibilityCustomAction(name: NSLocalizedString("Reply to Message", comment: ""), target: self, selector: #selector(replyButtonTapped(_:))),
            UIAccessibilityCustomAction(name: NSLocalizedString("Copy Message", comment: ""), target: self, selector: #selector(copyButtonTapped(_:)))
        ]
        if isOwnMessage {
            accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: NSLocalizedString("Delete Message", comment: ""), target: self, selector: #selector(deleteButtonTapped(_:))))
        } else {
            accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: NSLocalizedString("Like Message", comment: ""), target: self, selector: #selector(plusOneButtonTapped(_:))))
            accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: NSLocalizedString("Report Message", comment: ""), target: self, selector: #selector(reportButtonTapped(_:))))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    fileprivate func layout() {
        avatarWrapper.pin.start(12).top(4).size(36)
        if isAvatarHidden {
            messageWrapper.pin.top(topSpacing).start(leftSpacing).right(12)
        } else {
            messageWrapper.pin.top(topSpacing).after(of: avatarWrapper).marginStart(leftSpacing).end(12)
        }
        usernameLabel.pin.start(12).top(8).maxWidth(65%).sizeToFit(.widthFlexible)
        positionLabel.pin.right(of: usernameLabel).marginStart(8).top(8).sizeToFit(.heightFlexible)
        if usernameLabel.bounds.size.height < positionLabel.bounds.size.height {
            usernameLabel.pin.height(positionLabel.bounds.size.height)
        }
        positionLabel.pin.vCenter(to: usernameLabel.edge.vCenter)
        timeLabel.pin.left(12).below(of: usernameLabel).marginTop(2).sizeToFit(.widthFlexible)
        messageTextView.pin.horizontally(8).below(of: timeLabel).sizeToFit(.width)
        plusOneButton.pin.top(8).right(8).minWidth(20).sizeToFit(.height)
        reportView.pin.top(12).left(of: plusOneButton).marginRight(8)
        
        var height = messageTextView.frame.origin.y + messageTextView.frame.size.height + 4
        if isExpanded {
            height += 36
            replyButton.pin.start(12).below(of: messageTextView).marginTop(4).sizeToFit(.width)
            copyButton.pin.after(of: replyButton, aligned: .top).marginStart(8).sizeToFit(.width)
            reportButton.pin.after(of: copyButton, aligned: .top).marginStart(8).sizeToFit(.width)
            deleteButton.pin.after(of: visible([copyButton, reportButton]), aligned: .top).marginStart(8).sizeToFit(.width)
        }
        messageWrapper.pin.height(height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.width(size.width)
        layout()
        return CGSize(width: contentView.frame.width, height: messageWrapper.frame.height + topSpacing + bottomSpacing)
    }
}
