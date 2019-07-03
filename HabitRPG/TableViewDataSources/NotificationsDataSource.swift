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
    
    weak var viewController: UIViewController?
    
    private let userRepository = UserRepository()
    private let inventoryRepository = InventoryRepository()
    private let socialRepository = SocialRepository()
    
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
                cell.closeAction = { [weak self] in self?.dismiss(notification: notification) }
            }
        case .newStuff:
            if let cell = cell as? NewsNotificationCell,  let notif = notification as? NotificationNewsProtocol {
                cell.configureFor(notification: notif)
                cell.closeAction = { [weak self] in self?.dismiss(notification: notification) }
            }
        case .newChatMessage:
            if let cell = cell as? UnreadGroupNotificationCell, let notif = notification as? NotificationNewChatProtocol {
                cell.configureFor(notification: notif)
                cell.closeAction = { [weak self] in self?.dismiss(notification: notification) }
            }
        case .newMysteryItem:
            if let cell = cell as? NewMysteryItemNotificationCell, let notif = notification as? NotificationNewMysteryItemProtocol {
                cell.configureFor(notification: notif)
                cell.closeAction = { [weak self] in self?.dismiss(notification: notification) }
            }
        case .questInvite:
            if let cell = cell as? QuestInviteNotificationCell, let notif = notification as? NotificationQuestInviteProtocol {
                if let result = inventoryRepository.getQuest(key: notif.questKey ?? "").first(), let quest = result.value, let thisQuest = quest {
                    cell.configureFor(quest: thisQuest)
                }
                cell.configureFor(notification: notif)
                cell.declineAction = { [weak self] in self?.socialRepository.rejectQuestInvitation(groupID: "party").observeCompleted {
                        self?.dismiss(notification: notification)
                    }
                }
                cell.acceptAction = { [weak self] in self?.socialRepository.acceptQuestInvitation(groupID: "party").observeCompleted {
                    self?.dismiss(notification: notification)
                    }
                }
            }
        case .groupInvite:
            if let cell = cell as? GroupInviteNotificationCell, let notif = notification as? NotificationGroupInviteProtocol {
                cell.configureFor(notification: notif)
                cell.declineAction = { [weak self] in self?.socialRepository.rejectGroupInvitation(groupID: notif.groupID ?? "").observeCompleted {
                    self?.dismiss(notification: notification)
                    }
                }
                cell.acceptAction = { [weak self] in self?.socialRepository.joinGroup(groupID: notif.groupID ?? "").observeCompleted {
                    self?.dismiss(notification: notification)
                    }
                }
            }
        default:
            cell.textLabel?.text = notification.id
        }
        
        return cell
    }
    
    func didSelectedNotificationAt(indexPath: IndexPath) {
        if let notification = item(at: indexPath) {
            openNotification(notification: notification)
        }
    }
    
    private func dismiss(notification: NotificationProtocol) {
        userRepository.readNotification(notification: notification)
    }
    
    private func openNotification(notification: NotificationProtocol) {
        // This could be handled better
        var url: String? = nil
        switch notification.type {
        case .groupInvite:
            if let notif = notification as? NotificationGroupInviteProtocol {
                if notif.isParty {
                    url = "/party"
                } else {
                    url = "/groups/guild/\(notif.groupID ?? "")"
                }
            }
        case .newChatMessage:
            if let notif = notification as? NotificationNewChatProtocol {
                if notif.isParty {
                    url = "/party"
                } else {
                    url = "/groups/guild/\(notif.groupID ?? "")"
                }
            }
        case .questInvite:
            url = "/party"
        case .unallocatedStatsPoints:
            url = "/user/stats"
        case .newMysteryItem:
            url = "/inventory/items"
        case .newStuff:
            url = "/static/new-stuff"
        case .generic:
            break
        }
        if let url = url {
            viewController?.dismiss(animated: true) {
                RouterHandler.shared.handle(urlString: url)
            }
        }
    }
}
