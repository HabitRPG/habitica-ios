//
//  GroupInvitationListView.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import PinLayout

class GroupInvitationListView: UIView {
    
    private var invitationViews = [GroupInvitationView]()
    private let socialRepository = SocialRepository()
    
    func set(invitations: [GroupInvitationProtocol]?) {
        invitationViews.forEach { (view) in
            view.removeFromSuperview()
        }
        invitationViews.removeAll()
        
        for invitation in invitations ?? [] {
            let view = GroupInvitationView()
            view.set(invitation: invitation)
            view.responseAction = {[weak self] didAccept in
                guard let groupID = invitation.id else {
                    return
                }
                if didAccept {
                    self?.socialRepository.joinGroup(groupID: groupID).observeCompleted {}
                } else {
                    self?.socialRepository.rejectGroupInvitation(groupID: groupID).observeCompleted {}

                }
            }
            addSubview(view)
            invitationViews.append(view)
        }
        
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        var topEdge = edge.top
        for view in invitationViews {
            view.pin.top(to: topEdge).width(frame.size.width).height(70)
            topEdge = view.edge.bottom
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layout()
        let height = (invitationViews.last?.frame.origin.y ?? 0) + (invitationViews.last?.frame.size.height ?? 0)
        return CGSize(width: frame.size.width, height: height)
    }
}
