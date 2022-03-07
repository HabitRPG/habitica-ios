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
        var unformattedString = ""
        if notification.isParty {
            unformattedString = L10n.Notifications.partyInvite(groupName)
        } else {
            if notification.isPublicGuild {
                unformattedString = L10n.Notifications.publicGuildInvite(groupName)
            } else {
                unformattedString = L10n.Notifications.privateGuildInvite(groupName)
            }
        }
        attributedTitle = try? HabiticaMarkdownHelper.toHabiticaAttributedString(unformattedString)
    }
    
}
