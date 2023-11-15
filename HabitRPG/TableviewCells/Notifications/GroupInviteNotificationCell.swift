//
//  GroupInviteNotificationCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class GroupInviteNotificationCell: BaseNotificationCell<NotificationGroupInviteProtocol> {
    
    override func configureFor(notification: NotificationGroupInviteProtocol) {
        super.configureFor(notification: notification)
        showResponseButtons = true
        isClosable = false
        
        let groupName = notification.groupName ?? ""
        setTitleFor(groupName: groupName, inviterName: nil, isPartyInvitation: notification.isParty)
    }
    
    func setTitleFor(groupName: String, inviterName: String?, isPartyInvitation: Bool) {
        var unformattedString = ""
        if isPartyInvitation {
            if let inviterName = inviterName {
                unformattedString = L10n.Party.invitationInvitername(inviterName, groupName)
            } else {
                unformattedString = L10n.Party.invitationNoInvitername(groupName)
            }
        } else {
            if let inviterName = inviterName {
                unformattedString = L10n.Groups.guildInvitationInvitername(inviterName, groupName)
            } else {
                unformattedString = L10n.Groups.guildInvitationNoInvitername(groupName)
            }
        }
        attributedTitle = try? HabiticaMarkdownHelper.toHabiticaAttributedString(unformattedString)
    }
}
