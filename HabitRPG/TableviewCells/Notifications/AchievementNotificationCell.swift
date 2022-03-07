//
//  AchievementNotificationCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.01.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class AchievementNotificationCell: BaseNotificationCell<NotificationProtocol> {
    
    override func configureFor(notification: NotificationProtocol) {
        title = notification.achievementModalText
        iconView.image = UIImage(asset: Asset.notificationsStats)
        super.configureFor(notification: notification)
        setNeedsLayout()
    }
}
