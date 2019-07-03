//
//  UnreadGroupNotification.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class UnreadGroupNotificationCell: BaseNotificationCell<NotificationNewChatProtocol> {
    
    override func configureFor(notification: NotificationNewChatProtocol) {
        super.configureFor(notification: notification)
        if notification.isParty {
            attributedTitle = try? HabiticaMarkdownHelper.toHabiticaAttributedString(L10n.Notifications.unreadPartyMessage(notification.groupName?.unicodeEmoji ?? ""))
        } else {
            attributedTitle = try? HabiticaMarkdownHelper.toHabiticaAttributedString(L10n.Notifications.unreadGuildMessage(notification.groupName?.unicodeEmoji ?? ""))
        }
    }
}
