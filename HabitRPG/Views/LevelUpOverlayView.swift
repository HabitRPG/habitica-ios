//
//  LevelUpOverlayView.swift
//  Habitica
//
//  Created by Phillip Thelen on 19.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import PinLayout

class LevelUpOverlayView: HabiticaAlertController {
    
    private var avatarView: AvatarView = {
        let view = AvatarView()
        return view
    }()
    private var borderView: UIImageView = {
        let view = UIImageView()
        view.image = HabiticaIcons.imageOfDashBorder
        return view
    }()
    private var avatarWrapper = UIView()
    
    init(avatar: AvatarProtocol) {
        super.init()
        title = L10n.levelupTitle(avatar.stats?.level ?? 0)
        messageFont = CustomFontMetrics.scaledSystemFont(ofSize: 15)
        messageColor = ThemeService.shared.theme.ternaryTextColor
        message = L10n.levelupDescription
        arrangeMessageLast = true
        containerViewSpacing = 18
        setupAvatarView(avatar: avatar)
        addAction(title: L10n.onwards, isMainAction: true)
        addShareAction {[weak self] (_) in
            var items: [Any] = [
                L10n.levelupShare(avatar.stats?.level ?? 0)
            ]
            if let image = self?.avatarView.snapshotView(afterScreenUpdates: true) {
                items.append(image)
            }
            if let weakSelf = self {
                SharingManager.share(items: items, presentingViewController: weakSelf, sourceView: nil)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarView.pin.width(94).height(98).hCenter().top(8)
        borderView.pin.width(113).height(116).hCenter().top()
    }
    
    private func setupAvatarView(avatar: AvatarProtocol) {
        contentView = avatarWrapper
        avatarWrapper.addSubview(avatarView)
        avatarWrapper.addSubview(borderView)
        avatarView.translatesAutoresizingMaskIntoConstraints = true
        avatarView.avatar = AvatarViewModel(avatar: avatar)
        
        avatarWrapper.addConstraint(NSLayoutConstraint(item: avatarWrapper,
                                                       attribute: NSLayoutConstraint.Attribute.height,
                                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                                       toItem: nil,
                                                       attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                       multiplier: 1,
                                                       constant: 116))
    }
}
