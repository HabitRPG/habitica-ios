//
//  QuestParticipantView.swift
//  Habitica
//
//  Created by Phillip Thelen on 08.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class QuestParticipantView: UIView {
    
    let avatarView: AvatarView = {
        let view = AvatarView()
        view.showPet = false
        view.showMount = false
        view.size = .compact
        view.cornerRadius = 20
        view.backgroundColor = UIColor.gray600()
        return view
    }()
    let usernameLabel: UILabel = {
        let view = UILabel()
        view.font = CustomFontMetrics.scaledSystemFont(ofSize: 14, ofWeight: .medium)
        view.textColor = ThemeService.shared.theme.primaryTextColor
        return view
    }()
    lazy var invitationLabel: UILabel = {
        let view = UILabel()
        view.font = CustomFontMetrics.scaledSystemFont(ofSize: 14, ofWeight: .medium)
        return view
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(avatarView)
        addSubview(usernameLabel)
    }
    
    func configure(member: MemberProtocol) {
        avatarView.avatar = AvatarViewModel(avatar: member)
        usernameLabel.text = member.profile?.name
    }
    
    func configure(participant: QuestParticipantProtocol) {
        addSubview(invitationLabel)
        if participant.responded {
            if participant.accepted {
                invitationLabel.text = L10n.Quests.accepted
                invitationLabel.textColor = UIColor.green50()
            } else {
                invitationLabel.text = L10n.Quests.rejected
                invitationLabel.textColor = UIColor.red50()
            }
        } else {
            invitationLabel.text = L10n.Quests.pending
            invitationLabel.textColor = UIColor.gray400()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        avatarView.pin.start().size(40).vCenter()
        if invitationLabel.superview != nil {
            usernameLabel.pin.after(of: avatarView).marginStart(16).end().sizeToFit(.width)
            invitationLabel.pin.after(of: avatarView).marginStart(16).end().sizeToFit(.width)
            usernameLabel.pin.top((frame.size.height - usernameLabel.frame.size.height - invitationLabel.frame.size.height) / 2)
            invitationLabel.pin.below(of: usernameLabel)
        } else {
            usernameLabel.pin.after(of: avatarView).marginStart(16).end().sizeToFit(.width).vCenter()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.size.width, height: 56)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 56)
    }
}
