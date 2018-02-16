//
//  ChatTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import DateTools

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var messageWrapper: UIView!
    @IBOutlet weak private var usernameLabel: UsernameLabel!
    @IBOutlet weak private var positionLabel: PaddedLabel!
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var messageTextView: UITextView!
    @IBOutlet weak private var plusOneButton: UIButton!
    @IBOutlet weak private var extraButtonsStackView: UIStackView!
    @IBOutlet weak private var reportButton: UIButton!
    @IBOutlet weak private var deleteButton: UIButton!
    @IBOutlet weak private var leftMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak private var extraButtonsHeightConstraint: NSLayoutConstraint!
    
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
    
    private var isOwnMessage = false {
        didSet {
            if isOwnMessage {
                leftMarginConstraint.constant = 64
            } else {
                leftMarginConstraint.constant = 8
            }
            reportButton.isHidden = isOwnMessage
            if !isModerator {
                deleteButton.isHidden = !isOwnMessage
            }
        }
    }
    private var isPrivateMessage = false
    private var isModerator = false {
        didSet {
            deleteButton.isHidden = false
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
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(expandCell))
        messageTextView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tapGestureRecognizer)
        
        usernameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displayProfile)))
        
        selectionStyle = .none
        backgroundColor = .white
        
        positionLabel.horizontalPadding = 8
    }
    
    @objc
    func configure(chatMessage: ChatMessage, userID: String, username: String, isModerator: Bool, isExpanded: Bool) {
        self.isExpanded = isExpanded
        isPrivateMessage = false
        self.isModerator = isModerator
        isOwnMessage = chatMessage.uuid == userID
        wasMentioned = chatMessage.text.range(of: username) != nil

        usernameLabel.text = chatMessage.user.unicodeEmoji
        contributorLevel = chatMessage.contributorLevel.intValue
        messageTextView.textColor = UIColor.gray10()
        
        stylePlusOneButton(likes: chatMessage.likes as? Set<ChatMessageLike>, userID: userID)
        
        setTimeStamp(date: chatMessage.timestamp)
        
        if chatMessage.attributedText?.length ?? 0 > 0 {
            messageTextView.attributedText = chatMessage.attributedText
        } else {
            messageTextView.text = chatMessage.text.unicodeEmoji
        }
    }
    
    @objc
    func configure(inboxMessage: InboxMessage, user: User, isExpanded: Bool) {
        self.isExpanded = isExpanded
        isPrivateMessage = true
        plusOneButton.isHidden = true
        isOwnMessage = inboxMessage.sent?.boolValue ?? false
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

    }
    
    private func setTimeStamp(date: Date?) {
        timeLabel.text = (date as NSDate?)?.timeAgoSinceNow()
    }
    
    private func stylePlusOneButton(likes: Set<ChatMessageLike>?, userID: String) {
        plusOneButton.setTitle(nil, for: .normal)
        plusOneButton.setTitleColor(UIColor.gray50(), for: .normal)
        plusOneButton.tintColor = UIColor.gray300()
        var wasLiked = false
        if let likes = likes {
            if likes.count > 0 {
                plusOneButton.setTitle(" +\(likes.count)", for: .normal)
                for like in likes where like.userID == userID {
                    plusOneButton.setTitleColor(UIColor.purple400(), for: .normal)
                    plusOneButton.tintColor = UIColor.purple400()
                    wasLiked = true
                    break
                }
            }
        }
        plusOneButton.setImage(HabiticaIcons.imageOfChatLikeIcon(wasLiked: wasLiked), for: .normal)
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: contentView)
        if plusOneButton.frame.contains(location) {
            return false
        }
        if messageTextView.frame.contains(location) {
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
        if extraButtonsStackView.frame.contains(location) {
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
        extraButtonsStackView.isHidden = !shouldShow
        if shouldShow {
            extraButtonsHeightConstraint.constant = 36
        } else {
            extraButtonsHeightConstraint.constant = 0
        }
    }
}
