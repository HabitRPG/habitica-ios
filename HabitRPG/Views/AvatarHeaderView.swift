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
    
    private let backBlockLeft = UIView()
    private let roundBlockLeft = UIView()
    private let backBlockRight = UIView()
    private let roundBlockRight = UIView()
    
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
        addSubview(avatarView)
        addSubview(backBlockLeft)
        roundBlockLeft.cornerRadius = 22
        roundBlockLeft.layer.maskedCorners = [.layerMinXMinYCorner]
        addSubview(roundBlockLeft)
        
        addSubview(backBlockRight)
        roundBlockRight.cornerRadius = 22
        roundBlockRight.layer.maskedCorners = [.layerMaxXMinYCorner]
        addSubview(roundBlockRight)
    }
    
    func applyTheme(theme: any Theme) {
        backgroundColor = theme.windowBackgroundColor
        backBlockLeft.backgroundColor = theme.windowBackgroundColor
        roundBlockLeft.backgroundColor = theme.contentBackgroundColor
        backBlockRight.backgroundColor = theme.windowBackgroundColor
        roundBlockRight.backgroundColor = theme.contentBackgroundColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarView.pin.width(140).height(147).top().hCenter()
        backBlockLeft.pin.size(22).bottom(-22).start()
        roundBlockLeft.pin.size(44).bottom(-44).start()
        backBlockRight.pin.size(22).bottom(-22).end()
        roundBlockRight.pin.size(44).bottom(-44).end()
    }
    
    func setAvatar(avatar: AvatarProtocol) {
        avatarView.avatar = AvatarViewModel(avatar: avatar)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 169)
    }
}
