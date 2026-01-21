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
            avatarWrapper.cornerConfiguration = .corners(radius: .fixed(UIConstants.mediumCornerRadius))
        }
    }
    
    func applyTheme(theme: any Theme) {
        backgroundColor = theme.windowBackgroundColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 26.0, *) {
            avatarContainer.pin.width(142).height(149).top(-4).hCenter()
            avatarWrapper.pin.width(134).height(141).top(4).hCenter()
            avatarView.pin.width(140).height(147).center()
        } else {
            avatarContainer.pin.width(140).height(147).top(0).hCenter()
            avatarWrapper.pin.width(140).height(147).top().hCenter()
            avatarView.pin.width(140).height(147).center()
        }
        
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath()
        let width = frame.width
        let height = frame.height
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addArc(withCenter: CGPoint(x: width - UIConstants.largeCornerRadius, y: height),
                    radius: UIConstants.largeCornerRadius,
                    startAngle: 0,
                    endAngle: ((.pi * 270) / 180),
                    clockwise: false)
        path.addLine(to: CGPoint(x: UIConstants.largeCornerRadius, y: height - UIConstants.largeCornerRadius))
        path.addArc(withCenter: CGPoint(x: UIConstants.largeCornerRadius, y: height),
                    radius: UIConstants.largeCornerRadius,
                    startAngle: ((.pi * 270) / 180),
                    endAngle: ((.pi * 180) / 180),
                    clockwise: false)
        path.addLine(to: CGPoint.zero)
        path.close()
        shapeLayer.path = path.cgPath
        layer.mask = shapeLayer
    }
    
    func setAvatar(avatar: AvatarProtocol) {
        avatarView.avatar = AvatarViewModel(avatar: avatar)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 155 + UIConstants.largeCornerRadius)
    }
}
