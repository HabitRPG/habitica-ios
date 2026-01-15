//
//  AvatarHeaderView.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.05.24.
//  Copyright © 2024 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class AvatarHeaderView: UIView, Themeable {
    private let avatarView = AvatarView()
    private let avatarWrapper = UIView()
    private let avatarContainer = UIVisualEffectView()
    private let backBlockLeft = UIView()
    private let roundBlockLeft = UIView()
    private let backBlockRight = UIView()
    private let roundBlockRight = UIView()
   
    private let roundingWrapper = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        ThemeService.shared.addThemeable(themable: self)
        addSubview(avatarContainer)
        avatarWrapper.addSubview(avatarView)
        avatarWrapper.clipsToBounds = true
        avatarContainer.contentView.addSubview(avatarWrapper)
        if #available(iOS 26.0, *) {
            avatarContainer.effect = UIGlassEffect(style: .regular)
            avatarContainer.cornerConfiguration = .corners(radius: .fixed(UIConstants.mediumCornerRadius))
            avatarWrapper.cornerConfiguration = .corners(radius: .containerConcentric())
        }
        roundingWrapper.clipsToBounds = true
        addSubview(roundingWrapper)
        roundingWrapper.addSubview(backBlockLeft)
        roundBlockLeft.cornerRadius = UIConstants.largeCornerRadius
        roundBlockLeft.layer.maskedCorners = [.layerMinXMinYCorner]
        roundingWrapper.addSubview(roundBlockLeft)
        
        roundingWrapper.addSubview(backBlockRight)
        roundBlockRight.cornerRadius = UIConstants.largeCornerRadius
        roundBlockRight.layer.maskedCorners = [.layerMaxXMinYCorner]
        roundingWrapper.addSubview(roundBlockRight)
    }
    
    func applyTheme(theme: any Theme) {
        if #available(iOS 26.0, *) {
            backgroundColor = .clear
            backBlockLeft.backgroundColor = .clear
            roundBlockLeft.backgroundColor = .clear
            backBlockRight.backgroundColor = .clear
            roundBlockRight.backgroundColor = .clear
        } else {
            backgroundColor = theme.windowBackgroundColor
            backBlockLeft.backgroundColor = theme.windowBackgroundColor
            roundBlockLeft.backgroundColor = theme.contentBackgroundColor
            backBlockRight.backgroundColor = theme.windowBackgroundColor
            roundBlockRight.backgroundColor = theme.contentBackgroundColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 26.0, *) {
            avatarContainer.pin.width(142).height(149).top(-22).hCenter()
            avatarWrapper.pin.width(134).height(141).top(4).hCenter()
            avatarView.pin.width(140).height(147).center()
        } else {
            avatarContainer.pin.width(140).height(147).top(0).hCenter()
            avatarWrapper.pin.width(140).height(147).top().hCenter()
            avatarView.pin.width(140).height(147).center()
            let csize = UIConstants.largeCornerRadius
            roundingWrapper.pin.width(bounds.width).height(csize).bottom(-csize)
            backBlockLeft.pin.size(csize - 2).top().start()
            roundBlockLeft.pin.size(csize).top().start()
            backBlockRight.pin.size(csize - 3).top().end()
            roundBlockRight.pin.size(csize).top().end()
        }
    }
    
    func setAvatar(avatar: AvatarProtocol) {
        avatarView.avatar = AvatarViewModel(avatar: avatar)
    }
    
    override var intrinsicContentSize: CGSize {
        if #available(iOS 26.0, *) {
            return CGSize(width: UIScreen.main.bounds.size.width, height: 127)
        } else {
            return CGSize(width: UIScreen.main.bounds.size.width, height: 158)
        }
    }
}
