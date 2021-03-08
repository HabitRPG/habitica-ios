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
    
    @objc public var profileAction: (() -> Void)?
    @objc public var messagesAction: (() -> Void)?
    @objc public var settingsAction: (() -> Void)?
    @objc public var notificationsAction: (() -> Void)?
    
    private lazy var avatarWrapper: UIView = {
        let view = UIView()
        view.cornerRadius = 20
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileAreaTapped)))
        return view
    }()
    private lazy var avatarView: AvatarView = {
        let view = AvatarView()
        view.showPet = false
        view.showMount = false
        view.size = .compact
        view.isUserInteractionEnabled = true
        return view
    }()
    private lazy var displayNameLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 17, ofWeight: .semibold)
        label.adjustsFontForContentSizeCategory = true
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileAreaTapped)))
        return label
    }()
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 15)
        label.adjustsFontForContentSizeCategory = true
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileAreaTapped)))
        return label
    }()
    
    private lazy var messagesButton: UIButton = {
        let button = UIButton()
        button.accessibilityLabel = L10n.Titles.messages
        button.setImage(Asset.menuMessages.image, for: .normal)
        button.addTarget(self, action: #selector(messageButtonTapped), for: .touchUpInside)
        button.isPointerInteractionEnabled = true
        return button
    }()
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.accessibilityLabel = L10n.Titles.settings
        button.setImage(Asset.menuSettings.image, for: .normal)
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        button.isPointerInteractionEnabled = true
        return button
    }()
    lazy var notificationsButton: UIButton = {
        let button = UIButton()
        button.accessibilityLabel = L10n.Titles.notifications
        button.setImage(Asset.menuNotifications.image, for: .normal)
        button.addTarget(self, action: #selector(notificationsButtonTapped), for: .touchUpInside)
        button.isPointerInteractionEnabled = true
        return button
    }()
    var messagesBadge = BadgeView()
    var settingsBadge = BadgeView()
    var notificationsBadge = BadgeView()
    
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
        isUserInteractionEnabled = true
        messagesBadge.isHidden = true
        settingsBadge.isHidden = true
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
        messagesBadge.textColor = theme.lightTextColor
        notificationsBadge.backgroundColor = theme.fixedTintColor
        messagesBadge.backgroundColor = theme.fixedTintColor
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
        setNeedsLayout()
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
    
    @objc
    func profileAreaTapped() {
        if let action = profileAction {
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
        avatarWrapper.pin.size(40).start(pin.safeArea.left + 16).top(16)
        displayNameLabel.pin.after(of: avatarWrapper).marginStart(16).sizeToFit(.heightFlexible).maxWidth(parentWidth - 40 - 32)
        usernameLabel.pin.after(of: avatarWrapper).marginStart(16).sizeToFit(.heightFlexible)
        let labelsHeight = displayNameLabel.frame.size.height + usernameLabel.frame.size.height
        displayNameLabel.pin.top((72 - labelsHeight) / 2)
        usernameLabel.pin.below(of: displayNameLabel)
        settingsButton.pin.size(50)
        messagesButton.pin.size(50)
        notificationsButton.pin.size(50)
        var topOffset: CGFloat = 11
        var buttonSpacing: CGFloat = 0
        var endSpacing: CGFloat = 10
        if displayInTwoRows {
            topOffset = 62
            endSpacing = 58
            //take the full width, subtract spacing on the side and subtract the width of all 3 buttons. Remaining width is the divided evenly among the buttons
            buttonSpacing = (parentWidth - (endSpacing * 2) - 150) / 2
        }
        settingsButton.pin.top(topOffset).end(endSpacing)
        messagesButton.pin.top(to: settingsButton.edge.top).before(of: settingsButton).marginEnd(buttonSpacing)
        notificationsButton.pin.top(to: settingsButton.edge.top).before(of: messagesButton).marginEnd(buttonSpacing)
        settingsBadge.pin.top(to: settingsButton.edge.top).start(to: settingsButton.edge.start).marginStart(30).sizeToFit(.heightFlexible)
        messagesBadge.pin.top(to: messagesButton.edge.top).start(to: messagesButton.edge.start).marginStart(30).sizeToFit(.heightFlexible)
        notificationsBadge.pin.top(to: notificationsButton.edge.top).start(to: notificationsButton.edge.start).marginStart(30).sizeToFit(.heightFlexible)
    }
}
