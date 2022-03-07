//
//  NewMysteryitemNotificationCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class NewMysteryItemNotificationCell: BaseNotificationCell<NotificationNewMysteryItemProtocol> {
    
    override func configureFor(notification: NotificationNewMysteryItemProtocol) {
        super.configureFor(notification: notification)
        attributedTitle = try? HabiticaMarkdownHelper.toHabiticaAttributedString(L10n.Notifications.newMysteryItem)
        let month = Calendar.current.component(.month, from: Date())
        iconView.setImagewith(name: "inventory_present_\(month)") {[weak self] _, _ in
            self?.setNeedsLayout()
        }
    }
}
