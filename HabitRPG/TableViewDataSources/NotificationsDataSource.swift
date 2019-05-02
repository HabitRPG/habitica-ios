//
//  NotificationsDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class NotificationsDataSource: BaseReactiveTableViewDataSource<NotificationProtocol> {
    
    private let userRepository = UserRepository()
    
    override init() {
        super.init()
        sections.append(ItemSection<NotificationProtocol>())
        fetchNotifications()
    }

    private func fetchNotifications() {
        disposable.inner.add(userRepository.getNotifications().on(value: {[weak self] (entries, changes) in
                self?.sections[0].items = entries
                self?.notify(changes: changes)
            }).start())
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let notification = item(at: indexPath) else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: notification.type.rawValue, for: indexPath)
        
        switch notification.type {
        case .unallocatedStatsPoints:
            if let cell = cell as? UnallocatedPointsNotificationCell, let notif = notification as? NotificationUnallocatedStatsProtocol {
                cell.configureFor(notification: notif)
            }
        case .newStuff:
            if let cell = cell as? NewsNotificationCell,  let notif = notification as? NotificationNewsProtocol {
                cell.configureFor(notification: notif)
            }
        case .newChatMessage:
            if let notif = notification as? NotificationNewChatProtocol {
                
            }
        case .newMysteryItem:
            if let notif = notification as? NotificationNewMysteryItemProtocol {
                
            }
        default:
            cell.textLabel?.text = notification.id
        }
        
        return cell
    }
}
