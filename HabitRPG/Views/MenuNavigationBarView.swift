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
    
    private var avatarWrapper: UIView = {
        let view = UIView()
        view.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    private var avatarView: AvatarView = {
        let view = AvatarView()
        view.showPet = false
        view.showMount = false
        view.size = .compact
        return view
    }()
    private var displayNameLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 17, ofWeight: .semibold)
        if #available(iOS 10.0, *) {
            label.adjustsFontForContentSizeCategory = true
        }
        return label
    }()
    private var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 15)
        if #available(iOS 10.0, *) {
            label.adjustsFontForContentSizeCategory = true
        }
        return label
    }()
    
    private var messagesButton: UIButton = {
        let button = UIButton()
        button.accessibilityLabel = L10n.Titles.messages
        button.setImage(Asset.menuMessages.image, for: .normal)
        button.addTarget(self, action: #selector(messageButtonTapped), for: .touchUpInside)
        return button
    }()
    private var settingsButton: UIButton = {
        let button = UIButton()
        button.accessibilityLabel = L10n.Titles.settings
        button.setImage(Asset.menuSettings.image, for: .normal)
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        return button
    }()
    private var notificationsButton: UIButton = {
        let button = UIButton()
        button.accessibilityLabel = L10n.Titles.notifications
        button.setImage(Asset.menuNotifications.image, for: .normal)
        button.addTarget(self, action: #selector(notificationsButtonTapped), for: .touchUpInside)
        return button
    }()
    var messagesBadge: PaddedLabel = {
        let badge = PaddedLabel()
        badge.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
        badge.textAlignment = .center
        return badge
    }()
    var settingsBadge: PaddedLabel = {
        let badge = PaddedLabel()
        badge.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
        badge.textAlignment = .center
        return badge
    }()
    var notificationsBadge: PaddedLabel = {
        let badge = PaddedLabel()
        badge.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
        badge.textAlignment = .center
        return badge
    }()
    
    private var displayInTwoRows: Bool = false {
        didSet {
            if oldValue != displayInTwoRows {
                invalidateIntrinsicContentSize()
                superview?.superview?.setNeedsLayout()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(avatarWrapper)
        avatarWrapper.addSubview(avatarView)
        avatarView.pin.size(50).start(-9).top()
        addSubview(displayNameLabel)
        addSubview(usernameLabel)
        addSubview(notificationsButton)
        addSubview(notificationsBadge)
        addSubview(messagesButton)
        addSubview(messagesBadge)
        addSubview(settingsButton)
        addSubview(settingsBadge)
        ThemeService.shared.addThemeable(themable: self, applyImmediately: true)
        
        #if DEBUG
            usernameLabel.isUserInteractionEnabled = true
            usernameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleRow)))
        #endif
    }

    @objc
    private func toggleRow() {
        displayInTwoRows = !displayInTwoRows
    }
    
    func applyTheme(theme: Theme) {
        backgroundColor = theme.navbarHiddenColor
        displayNameLabel.textColor = theme.lightTextColor
        usernameLabel.textColor = theme.lightTextColor
        settingsBadge.backgroundColor = theme.badgeColor
        settingsBadge.textColor = theme.lightTextColor
        messagesBadge.backgroundColor = theme.badgeColor
        messagesBadge.textColor = theme.lightTextColor
        notificationsBadge.backgroundColor = theme.badgeColor
        notificationsBadge.textColor = theme.lightTextColor
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
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
        
        if bounds.size.width <= 320 {
            displayInTwoRows = true
            return
        }
        displayNameLabel.pin.sizeToFit(.height)
        let labelWidth = displayNameLabel.frame.size.width
        displayInTwoRows = bounds.size.width - 32 - 40 - 16 - 150 < labelWidth
    }
    
    @objc
    func messageButtonTapped() {
        if let action = messagesAction {
            action()
        }
    }
    
    @objc
    func settingsButtonTapped() {
        if let action = settingsAction {
            action()
        }
    }
    
    @objc
    func notificationsButtonTapped() {
        if let action = notificationsAction {
            action()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        if displayInTwoRows {
            return CGSize(width: UIScreen.main.bounds.size.width, height: 110)
        } else {
            return CGSize(width: UIScreen.main.bounds.size.width, height: 72)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        let parentWidth = bounds.size.width
        avatarWrapper.pin.size(40).start(16).top(16)
        displayNameLabel.pin.after(of: avatarWrapper).marginStart(16).sizeToFit(.heightFlexible).maxWidth(parentWidth - 40 - 32)
        usernameLabel.pin.after(of: avatarWrapper).marginStart(16).sizeToFit(.heightFlexible)
        let labelsHeight = displayNameLabel.frame.size.height + usernameLabel.frame.size.height
        displayNameLabel.pin.top((72 - labelsHeight) / 2)
        usernameLabel.pin.below(of: displayNameLabel)
        settingsButton.pin.size(50).end(16)
        messagesButton.pin.size(50)
        notificationsButton.pin.size(50)
        var topOffset: CGFloat = 11
        var buttonSpacing: CGFloat = 0
        if displayInTwoRows {
            topOffset = 62
            //take the full width, subtract spacing on the side and subtract the width of all 3 buttons. Remaining width is the divided evenly among the buttons
            buttonSpacing = (parentWidth - 32 - 150) / 2
        }
        settingsButton.pin.top(topOffset)
        messagesButton.pin.top(to: settingsButton.edge.top).before(of: settingsButton).marginEnd(buttonSpacing)
        notificationsButton.pin.top(to: settingsButton.edge.top).before(of: messagesButton).marginEnd(buttonSpacing)
        settingsBadge.pin.top(to: settingsButton.edge.top).start(to: settingsButton.edge.start).marginStart(30).sizeToFit(.heightFlexible)
        settingsBadge.cornerRadius = settingsBadge.frame.size.height / 2
        messagesBadge.pin.top(to: messagesButton.edge.top).start(to: messagesButton.edge.start).marginStart(30).sizeToFit(.heightFlexible)
        messagesBadge.cornerRadius = messagesBadge.frame.size.height / 2
        notificationsBadge.pin.top(to: notificationsButton.edge.top).start(to: notificationsButton.edge.start).marginStart(30).sizeToFit(.heightFlexible)
        notificationsBadge.cornerRadius = notificationsBadge.frame.size.height / 2
    }
}
