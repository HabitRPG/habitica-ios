//
//  UnallocatedPointsNotificationCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class UnallocatedPointsNotificationCell: BaseNotificationCell {
    
    func configureFor(notification: NotificationUnallocatedStatsProtocol) {
        isClosable = true
        titleLabel.text = L10n.Notifications.unallocatedStatPoints(notification.points)
        iconView.image = UIImage(asset: Asset.notificationsStats)
        super.configureFor(notification: notification)
        setNeedsLayout()
    }
}
