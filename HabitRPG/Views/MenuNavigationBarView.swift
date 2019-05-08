//
//  MenuNavigationBarView.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class MenuNavigationBarView: UIView, Themeable {
    
    @objc public var messagesAction: (() -> Void)?
    @objc public var settingsAction: (() -> Void)?
    @objc public var notificationsAction: (() -> Void)?
    
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var messagesButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var messagesBadge: PaddedLabel!
    @IBOutlet weak var settingsBadge: PaddedLabel!
    @IBOutlet weak var notificationsBadge: PaddedLabel!
    
    // MARK: - Private Helper Methods
   
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.showPet = false
        avatarView.showMount = false
        avatarView.size = .compact
        messagesBadge.horizontalPadding = 4
        
        messagesButton.accessibilityLabel = L10n.Titles.messages
        settingsButton.accessibilityLabel = L10n.Titles.settings
        notificationsButton.accessibilityLabel = L10n.Titles.notifications
        
        ThemeService.shared.addThemeable(themable: self, applyImmediately: true)
    }
    
    func applyTheme(theme: Theme) {
        backgroundColor = theme.navbarHiddenColor
    }
    
    @objc
    public func configure(user: UserProtocol) {
        displayNameLabel.text = user.profile?.name
        if let username = user.username {
            usernameLabel.text = "@\(username)"
            usernameLabel.isHidden = false
        } else {
            usernameLabel.isHidden = true
        }
        avatarView.avatar = AvatarViewModel(avatar: user)
        if let numberNewMessages = user.inbox?.numberNewMessages, numberNewMessages > 0 {
            messagesBadge.text = String(numberNewMessages)
            messagesBadge.isHidden = false
        } else {
            messagesBadge.isHidden = true
        }
        
        if user.flags?.verifiedUsername != true {
            settingsBadge.text = "1"
            settingsBadge.isHidden = false
        } else {
            settingsBadge.isHidden = true
        }
    }
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        if let action = messagesAction {
            action()
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        if let action = settingsAction {
            action()
        }
    }
    
    @IBAction func notificationsButtonTapped(_ sender: Any) {
        if let action = notificationsAction {
            action()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 72)
    }
}
