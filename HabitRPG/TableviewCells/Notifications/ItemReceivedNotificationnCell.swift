//
//  ItemReceivedNotificationnCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.01.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class ItemReceivedNotificationCell: BaseNotificationCell<NotificationItemReceivedProtocol> {
    
    override func configureFor(notification: NotificationItemReceivedProtocol) {
        super.configureFor(notification: notification)
        title = notification.title
        itemDescription = notification.message
        iconView.setImagewith(name: notification.icon)
        setNeedsLayout()
    }
}
