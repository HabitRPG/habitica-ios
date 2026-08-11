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
        view.cornerRadius = 10
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
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileAreaTapped)))
        return label
    }()
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
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
        avatarView.pin.size(50).start(-9).top(-2)
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
    }

    func applyTheme(theme: Theme) {
        let isDefaultTheme = (ThemeName(rawValue: UserDefaults.standard.string(forKey: "theme") ?? "") ?? .defaultTheme) == .defaultTheme
        let headerColor = isDefaultTheme ? UIColor.purple300 : theme.navbarHiddenColor
        let textColor = isDefaultTheme ? UIColor.white : (theme.navbarHiddenColor.isLight() ? UIColor.gray50 : theme.lightTextColor)
        backgroundColor = headerColor
        displayNameLabel.textColor = textColor
        usernameLabel.textColor = textColor
        settingsBadge.backgroundColor = UIColor.purple100
        settingsBadge.textColor = .white
        settingsButton.tintColor = textColor
        messagesBadge.backgroundColor = UIColor.purple100
        messagesBadge.textColor = .white
        messagesButton.tintColor = textColor
        notificationsBadge.backgroundColor = UIColor.purple100
        notificationsBadge.textColor = .white
        notificationsButton.tintColor = textColor
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
    }

    @objc
    public func configure(user: UserProtocol) {
        guard user.isValid else {
            return
        }
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
        setNeedsLayout()
    }

    @objc
    func messageButtonTapped() {
        messagesAction?()
    }

    @objc
    func settingsButtonTapped() {
        settingsAction?()
    }

    @objc
    func notificationsButtonTapped() {
        notificationsAction?()
    }

    @objc
    func profileAreaTapped() {
        profileAction?()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 72)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }

    private func layout() {
        let centerY: CGFloat = 36
        let avatarSize: CGFloat = 40
        avatarWrapper.pin.width(avatarSize).height(avatarSize).start(pin.safeArea.left + 20).top(centerY - avatarSize / 2)

        let iconSize: CGFloat = 32
        let iconSpacing: CGFloat = 16
        settingsButton.pin.size(iconSize).end(pin.safeArea.right + 16).top(centerY - iconSize / 2)
        messagesButton.pin.size(iconSize).before(of: settingsButton).marginEnd(iconSpacing).top(centerY - iconSize / 2)
        notificationsButton.pin.size(iconSize).before(of: messagesButton).marginEnd(iconSpacing).top(centerY - iconSize / 2)

        let labelX = avatarWrapper.frame.maxX + 12
        let labelWidth = max(0, notificationsButton.frame.minX - 12 - labelX)
        let lineHeight: CGFloat = 14
        let lineSpacing: CGFloat = 6
        let stackHeight = usernameLabel.isHidden ? lineHeight : lineHeight * 2 + lineSpacing
        let stackTop = centerY - stackHeight / 2
        displayNameLabel.pin.start(labelX).width(labelWidth).height(lineHeight).top(stackTop)
        usernameLabel.pin.start(labelX).below(of: displayNameLabel).marginTop(lineSpacing).width(labelWidth).height(lineHeight)

        positionBadge(notificationsBadge, on: notificationsButton)
        positionBadge(messagesBadge, on: messagesButton)
        positionBadge(settingsBadge, on: settingsButton)
    }

    private func positionBadge(_ badge: BadgeView, on button: UIButton) {
        badge.pin.top(to: button.edge.top).marginTop(-4).start(to: button.edge.start).marginStart(18).sizeToFit(.heightFlexible)
    }
}
