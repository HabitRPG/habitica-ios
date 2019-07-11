//
//  UnallocatedPointsNotificationCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class UnallocatedPointsNotificationCell: BaseNotificationCell<NotificationUnallocatedStatsProtocol> {
    
    override func configureFor(notification: NotificationUnallocatedStatsProtocol) {
        attributedTitle = try? HabiticaMarkdownHelper.toHabiticaAttributedString(L10n.Notifications.unallocatedStatPoints(notification.points))
        iconView.image = UIImage(asset: Asset.notificationsStats)
        super.configureFor(notification: notification)
        setNeedsLayout()
    }
}
