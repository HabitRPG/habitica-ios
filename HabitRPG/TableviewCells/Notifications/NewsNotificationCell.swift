//
//  NewsNotificationCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class NewsNotificationCell: BaseNotificationCell {
    
    func configureFor(notification: NotificationNewsProtocol) {
        isClosable = true
        titleLabel.text = L10n.Notifications.newBailey
        iconView.image = UIImage(asset: Asset.notificationsBailey)
        super.configureFor(notification: notification)
        setNeedsLayout()
    }
}
