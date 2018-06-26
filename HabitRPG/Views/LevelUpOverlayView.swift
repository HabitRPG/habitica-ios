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
    
    private var avatarWrapper = UIView()
    
    init(avatar: AvatarProtocol) {
        super.init()
        self.title = L10n.levelupTitle
        self.message = L10n.levelupDescription(avatar.stats?.level ?? 0)
        setupAvatarView(avatar: avatar)
        addShareAction {[weak self] (_) in
            var items: [Any] = [
                L10n.levelupShare(avatar.stats?.level ?? 0)
            ]
            if let image = self?.avatarView.snapshotView(afterScreenUpdates: true) {
                items.append(image)
            }
            if let weakSelf = self {
                HRPGSharingManager.shareItems(items, withPresenting: weakSelf, withSourceView: nil)
            }
        }
        addCloseAction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarView.pin.width(140).height(147).hCenter().top()
    }
    
    private func setupAvatarView(avatar: AvatarProtocol) {
        contentView = avatarWrapper
        avatarWrapper.addSubview(avatarView)
        avatarView.translatesAutoresizingMaskIntoConstraints = true
        avatarView.avatar = AvatarViewModel(avatar: avatar)
        
        avatarWrapper.addConstraint(NSLayoutConstraint(item: avatarWrapper,
                                                       attribute: NSLayoutAttribute.height,
                                                       relatedBy: NSLayoutRelation.equal,
                                                       toItem: nil,
                                                       attribute: NSLayoutAttribute.notAnAttribute,
                                                       multiplier: 1,
                                                       constant: 160))
    }
}
