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
    
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var messagesButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var messagesBadge: PaddedLabel!
    @IBOutlet weak var settingsBadge: PaddedLabel!
    
    // MARK: - Private Helper Methods
   
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.showPet = false
        avatarView.showMount = false
        avatarView.size = .compact
        messagesBadge.horizontalPadding = 4
        
        ThemeService.shared.addThemeable(themable: self, applyImmediately: true)
    }
    
    func applyTheme(theme: Theme) {
        backgroundColor = theme.backgroundTintColor
    }
    
    @objc
    public func configure(user: UserProtocol, enableChangeUsername: Bool) {
        displayNameLabel.text = user.profile?.name
        if enableChangeUsername, let username = user.username {
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
        
        if enableChangeUsername && user.flags?.verifiedUsername != true {
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
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 72)
    }
}
