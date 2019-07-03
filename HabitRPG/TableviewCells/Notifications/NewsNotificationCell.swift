//
//  NewsNotificationCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class NewsNotificationCell: BaseNotificationCell<NotificationNewsProtocol> {
    
    override func configureFor(notification: NotificationNewsProtocol) {
        super.configureFor(notification: notification)
        title = L10n.Notifications.newBailey
        itemDescription = notification.title
        iconView.image = UIImage(asset: Asset.notificationsBailey)
        super.configureFor(notification: notification)
        setNeedsLayout()
    }
}
