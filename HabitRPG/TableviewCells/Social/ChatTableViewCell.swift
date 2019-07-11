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
import Habitica_Models
import Down

class ChatTableViewCell: UITableViewCell, UITextViewDelegate, Themeable {
    
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var avatarWrapper: UIView!
    @IBOutlet weak private var messageWrapper: UIView!
    @IBOutlet weak private var displaynameLabel: UsernameLabel!
    @IBOutlet weak private var positionLabel: PaddedLabel!
    @IBOutlet weak private var sublineLabel: UILabel!
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
            displaynameLabel.contributorLevel = contributorLevel
            positionLabel.isHidden = contributorLevel < 8
            positionLabel.textColor = .white
            if contributorLevel == 8 {
                positionLabel.text = L10n.moderator
                positionLabel.backgroundColor = UIColor.blue10()
            } else if contributorLevel == 9 {
                positionLabel.text = L10n.staff
                positionLabel.backgroundColor = UIColor.purple300()
            }
        }
    }

    private var wasMentioned = false
    override func awakeFromNib() {
        super.awakeFromNib()
        messageTextView.delegate = self
        let wrapperTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(expandCell))
        wrapperTapRecognizer.delegate = self
        wrapperTapRecognizer.cancelsTouchesInView = false
        messageWrapper.addGestureRecognizer(wrapperTapRecognizer)
        let messageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(expandCell))
        messageTapRecognizer.delegate = self
        messageTapRecognizer.cancelsTouchesInView = false
        messageTextView.addGestureRecognizer(messageTapRecognizer)
        
        displaynameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displayProfile)))
        avatarWrapper.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displayProfile)))
        
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
    
    func configure(chatMessage: ChatMessageProtocol, previousMessage: ChatMessageProtocol?, nextMessage: ChatMessageProtocol?, userID: String, username: String, isModerator: Bool, isExpanded: Bool) {
        isPrivateMessage = false
        self.isModerator = isModerator
        isOwnMessage = chatMessage.userID == userID
        wasMentioned = chatMessage.text?.range(of: "@\(username)") != nil

        displaynameLabel.text = chatMessage.displayName?.unicodeEmoji
        contributorLevel = chatMessage.contributor?.level ?? 0
        
        stylePlusOneButton(likes: chatMessage.likes, userID: userID)
        
        setSubline(username: chatMessage.username, date: chatMessage.timestamp)
        
        if let text = chatMessage.text {
            setMessageText(text)
        }
        
        if previousMessage?.isValid == true, previousMessage?.userID == chatMessage.userID {
            topSpacing = 2
            avatarView.isHidden = true
        } else {
            topSpacing = 4
            avatarView.isHidden = isOwnMessage

            if !isOwnMessage && !isAvatarHidden, let userStyles = chatMessage.userStyles {
                avatarView.avatar = AvatarViewModel(avatar: userStyles)
            }
        }
        
        if nextMessage?.isValid == true, nextMessage?.userID == chatMessage.userID {
            bottomSpacing = 2
        } else if isFirstMessage {
            bottomSpacing = 34
        } else {
            bottomSpacing = 4
        }
        
        if isModerator && chatMessage.flags.isEmpty == false {
            reportView.isHidden = false
            reportView.setTitle("\(chatMessage.flags.count)", for: .normal)
        } else {
            reportView.isHidden = true
        }
        
        self.isExpanded = isExpanded
        applyAccessibility()
        setNeedsLayout()
        
        applyTheme(theme: ThemeService.shared.theme)
    }
    
    @objc
    func configure(inboxMessage: InboxMessageProtocol, previousMessage: InboxMessageProtocol?, nextMessage: InboxMessageProtocol?, user: UserProtocol?, isExpanded: Bool) {
        isPrivateMessage = true
        plusOneButton.isHidden = true
        isOwnMessage = inboxMessage.sent
        isAvatarHidden = true
        if inboxMessage.sent {
            displaynameLabel.text = user?.profile?.name?.unicodeEmoji
            contributorLevel = user?.contributor?.level ?? 0
            setSubline(username: user?.username, date: inboxMessage.timestamp)
        } else {
            displaynameLabel.text = inboxMessage.displayName?.unicodeEmoji
            contributorLevel = inboxMessage.contributor?.level ?? 0
            setSubline(username: inboxMessage.username, date: inboxMessage.timestamp)
        }
        displaynameLabel.contributorLevel = contributorLevel
        
        if let text = inboxMessage.text {
            messageTextView.attributedText = try? Down(markdownString: text.unicodeEmoji).toHabiticaAttributedString()
        }
        
        if previousMessage?.sent == inboxMessage.sent {
            topSpacing = 2
            avatarView.isHidden = true
        } else {
            topSpacing = 4
            avatarView.isHidden = isOwnMessage
        }
        
        if nextMessage?.sent == inboxMessage.sent {
            bottomSpacing = 2
        } else if isFirstMessage {
            bottomSpacing = 34
        } else {
            bottomSpacing = 4
        }
        
        self.isExpanded = isExpanded
        applyAccessibility()
        setNeedsLayout()
        
        applyTheme(theme: ThemeService.shared.theme)
    }
    
    func applyTheme(theme: Theme) {
        backgroundColor = theme.windowBackgroundColor
        contentView.backgroundColor = theme.windowBackgroundColor
        plusOneButton.backgroundColor = theme.windowBackgroundColor
        if wasMentioned {
            messageWrapper.backgroundColor = theme.lightlyTintedBackgroundColor
        } else {
            messageWrapper.backgroundColor = theme.contentBackgroundColor
        }
    }
    
    private func setSubline(username: String?, date: Date?) {
        let date = (date as NSDate?)?.timeAgoSinceNow() ?? ""
        if let username = username {
            sublineLabel.text = "@\(username) · \(date)"
        } else {
            sublineLabel.text = date
        }
    }
    
    private func setMessageText(_ text: String) {
        if let attributedText = try? Down(markdownString: text.unicodeEmoji).toHabiticaAttributedString() {
            messageTextView.attributedText = attributedText
        } else {
            messageTextView.text = ""
        }
    }
    
    private func stylePlusOneButton(likes: [ChatMessageReactionProtocol], userID: String) {
        plusOneButton.setTitle(nil, for: .normal)
        plusOneButton.setTitleColor(UIColor.gray300(), for: .normal)
        plusOneButton.tintColor = UIColor.gray300()
        var wasLiked = false
        let likedMessageCount = likes.filter({ (like) -> Bool in
            return like.hasReacted == true
        }).count
        if likedMessageCount > 0 {
            plusOneButton.setTitle(" +\(likedMessageCount)", for: .normal)
            for like in likes where like.userID == userID && like.hasReacted == true {
                plusOneButton.setTitleColor(UIColor.purple400(), for: .normal)
                plusOneButton.tintColor = UIColor.purple400()
                wasLiked = true
                break
            }
        }
        plusOneButton.setImage(HabiticaIcons.imageOfChatLikeIcon(wasLiked: wasLiked), for: .normal)
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: messageWrapper)
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
                if attributes[NSAttributedString.Key.link] != nil {
                    return false
                }
            }
        }
        if displaynameLabel.frame.contains(location) {
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
        replyButton.isHidden = !shouldShow || isPrivateMessage
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
        accessibilityLabel = "\(displaynameLabel.text ?? ""), \(sublineLabel.text ?? ""), \(messageTextView.text ?? "")"
        shouldGroupAccessibilityChildren = true
        messageTextView.isAccessibilityElement = false
        plusOneButton.isAccessibilityElement = false
        accessibilityCustomActions = [
            UIAccessibilityCustomAction(name: L10n.Accessibility.replyToMessage, target: self, selector: #selector(replyButtonTapped(_:))),
            UIAccessibilityCustomAction(name: L10n.Accessibility.copyMessage, target: self, selector: #selector(copyButtonTapped(_:)))
        ]
        if isOwnMessage {
            accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Accessibility.deleteMessage, target: self, selector: #selector(deleteButtonTapped(_:))))
        } else {
            accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Accessibility.likeMessage, target: self, selector: #selector(plusOneButtonTapped(_:))))
            accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Accessibility.reportMessage, target: self, selector: #selector(reportButtonTapped(_:))))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    fileprivate func layout() {
        avatarWrapper.pin.start(12).top(4).size(40)
        if isAvatarHidden {
            messageWrapper.pin.top(topSpacing).start(leftSpacing).right(12)
        } else {
            messageWrapper.pin.top(topSpacing).after(of: avatarWrapper).marginStart(leftSpacing).end(12)
        }
        displaynameLabel.pin.start(12).top(8).maxWidth(65%).sizeToFit(.widthFlexible)
        positionLabel.pin.right(of: displaynameLabel).marginStart(8).top(8).sizeToFit(.heightFlexible)
        if displaynameLabel.bounds.size.height < positionLabel.bounds.size.height {
            displaynameLabel.pin.height(positionLabel.bounds.size.height)
        }
        positionLabel.pin.vCenter(to: displaynameLabel.edge.vCenter)
        sublineLabel.pin.left(12).below(of: displaynameLabel).marginTop(2).sizeToFit(.widthFlexible)
        messageTextView.pin.horizontally(8).below(of: sublineLabel).sizeToFit(.width)
        plusOneButton.pin.top(8).right(8).minWidth(20).sizeToFit(.height)
        reportView.pin.top(12).left(of: plusOneButton).marginRight(8)
        
        var height = messageTextView.frame.origin.y + messageTextView.frame.size.height + 4
        if isExpanded {
            height += 36
            replyButton.pin.start(12).below(of: messageTextView).marginTop(4).sizeToFit(.width)
            if replyButton.isHidden {
                copyButton.pin.start(12).below(of: messageTextView).marginTop(4).sizeToFit(.width)
            } else {
                copyButton.pin.after(of: replyButton, aligned: .top).marginStart(8).sizeToFit(.width)
            }
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
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return !RouterHandler.shared.handle(url: URL)
    }
}
