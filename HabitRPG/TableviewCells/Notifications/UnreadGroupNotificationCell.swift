//
//  UnreadGroupNotification.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class UnreadGroupNotificationCell: BaseNotificationCell<NotificationNewChatProtocol> {
    
    func configureFor(notification: NotificationNewChatProtocol, partyID: String?) {
        super.configureFor(notification: notification)
        if notification.groupID == partyID {
            attributedTitle = try? HabiticaMarkdownHelper.toHabiticaAttributedString(L10n.Notifications.unreadPartyMessage(notification.groupName?.unicodeEmoji ?? ""))
        } else {
            attributedTitle = try? HabiticaMarkdownHelper.toHabiticaAttributedString(L10n.Notifications.unreadGuildMessage(notification.groupName?.unicodeEmoji ?? ""))
        }
    }
}
