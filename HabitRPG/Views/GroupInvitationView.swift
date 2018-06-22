//
//  GroupInvitationView.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import PinLayout

class GroupInvitationView: UIView {
    
    private let avatarView: AvatarView = {
        let view = AvatarView()
        view.cornerRadius = 20
        return view
    }()
    private let label: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = CustomFontMetrics.scaledSystemFont(ofSize: 15, ofWeight: .semibold)
        view.numberOfLines = 3
        return view
    }()
    private let declineButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .white
        view.cornerRadius = 16
        view.setImage(HabiticaIcons.imageOfDeclineIcon, for: .normal)
        view.addTarget(self, action: #selector(declineInvitation), for: .touchUpInside)
        return view
    }()
    private let acceptButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .white
        view.cornerRadius = 16
        view.setImage(HabiticaIcons.imageOfAcceptIcon, for: .normal)
        view.addTarget(self, action: #selector(acceptInvitation), for: .touchUpInside)
        return view
    }()
    
    private var inviterName: String?
    
    var responseAction: ((Bool) -> Void)?
    
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
        addSubview(label)
        addSubview(declineButton)
        addSubview(acceptButton)
        
        backgroundColor = UIColor.blue100()
    }
    
    func set(invitation: GroupInvitationProtocol) {
        setLabel(name: invitation.name, isParty: invitation.isPartyInvitation)
    }
    
    private func setLabel(name: String?, isParty: Bool) {
        if isParty {
            if let inviterName = self.inviterName {
                label.text = L10n.Party.invitationInvitername(inviterName)
            } else {
                label.text = L10n.Party.invitationNoInvitername
            }
        } else {
            if let inviterName = self.inviterName {
                label.text = L10n.Groups.guildInvitationInvitername(inviterName, name ?? "")
            } else {
                label.text = L10n.Groups.guildInvitationNoInvitername(name ?? "")
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        acceptButton.pin.end(16).vCenter().size(32)
        declineButton.pin.before(of: acceptButton).marginEnd(20).size(32).vCenter()
        avatarView.pin.start(16).vCenter().size(40)
        label.pin.after(of: avatarView).before(of: declineButton).marginHorizontal(16).top().bottom()
    }
    
    @objc
    private func declineInvitation() {
        if let action = responseAction {
            action(false)
        }
    }
    
    @objc
    private func acceptInvitation() {
        if let action = responseAction {
            action(true)
        }
    }
}
