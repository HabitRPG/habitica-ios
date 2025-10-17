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
import PinLayout

class NotificationsDataSource: BaseReactiveTableViewDataSource<NotificationProtocol> {
    
    weak var viewController: UIViewController?
    
    private let userRepository = UserRepository()
    private let inventoryRepository = InventoryRepository()
    private let socialRepository = SocialRepository()
    
    private var partyID: String?
    
    override init() {
        super.init()
        sections.append(ItemSection<NotificationProtocol>())
        fetchNotifications()
    }

    private func fetchNotifications() {
        disposable.add(userRepository.getNotifications().on(value: {[weak self] (entries, changes) in
                self?.sections[0].items = entries
                self?.notify(changes: changes)
            }).start())
        disposable.add(userRepository.getUser().map { $0.party?.id }.skipRepeats()
                        .on(value: {[weak self] partyID in
                            self?.partyID = partyID
                        }).start())
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let notification = item(at: indexPath) else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: notification.achievementKey != nil ? "ACHIEVEMENT" : notification.type.rawValue, for: indexPath)
        cell.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        
        if !notification.isValid {
            return cell
        }
        
        switch notification.type {
        case .unallocatedStatsPoints:
            if let cell = cell as? UnallocatedPointsNotificationCell, let notif = notification as? NotificationUnallocatedStatsProtocol {
                cell.configureFor(notification: notif)
                cell.closeAction = { [weak self] in self?.dismiss(notification: notification) }
            }
        case .newStuff:
            if let cell = cell as? NewsNotificationCell, let notif = notification as? NotificationNewsProtocol {
                cell.configureFor(notification: notif)
                cell.closeAction = { [weak self] in self?.dismiss(notification: notification) }
            }
        case .newChatMessage:
            if let cell = cell as? UnreadGroupNotificationCell, let notif = notification as? NotificationNewChatProtocol {
                cell.configureFor(notification: notif, partyID: partyID)
                cell.closeAction = { [weak self] in self?.dismiss(notification: notification) }
            }
        case .newMysteryItem:
            if let cell = cell as? NewMysteryItemNotificationCell, let notif = notification as? NotificationNewMysteryItemProtocol {
                cell.configureFor(notification: notif)
                cell.closeAction = { [weak self] in self?.dismiss(notification: notification) }
            }
        case .questInvite:
            if let cell = cell as? QuestInviteNotificationCell, let notif = notification as? NotificationQuestInviteProtocol {
                if let quest = try? inventoryRepository.getQuest(key: notif.questKey ?? "").first()?.get() {
                    cell.configureFor(quest: quest)
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
                cell.acceptAction = { [weak self] in self?.socialRepository.joinGroup(groupID: notif.groupID ?? "", isParty: notif.isParty).observeCompleted {
                    self?.dismiss(notification: notification)
                    }
                }
                disposable.add(socialRepository.getMember(userID: notif.inviterID ?? "", retrieveIfNotFound: true)
                    .on(value: { member in
                        cell.setTitleFor(groupName: notif.groupName ?? "", inviterName: member?.username, isPartyInvitation: notif.isParty)
                    })
                    .start())
            }
        case .itemReceived:
            if let cell = cell as? ItemReceivedNotificationCell, let notif = notification as? NotificationItemReceivedProtocol {
                cell.configureFor(notification: notif)
            }
        default:
            if notification.achievementKey != nil {
                if let cell = cell as? AchievementNotificationCell {
                    cell.configureFor(notification: notification)
                }
            } else {
                cell.textLabel?.text = notification.id
            }
        }
        
        return cell
    }
    
    func didSelectedNotificationAt(indexPath: IndexPath) {
        if let notification = item(at: indexPath) {
            openNotification(notification: notification)
        }
    }
    
    private func dismiss(notification: NotificationProtocol) {
        disposable.add(userRepository.readNotification(notification: notification).observeCompleted { })
    }
    
    @objc
    private func dismissAll() {
        let dismissableNotifications = sections[0].items.filter { (notification) -> Bool in
            if !notification.isValid {
                return false
            }
            return notification.isDismissable
        }
        disposable.add(userRepository.readNotifications(notifications: dismissableNotifications).observeCompleted {})
    }
    
    private func openNotification(notification: NotificationProtocol) {
        // This could be handled better
        var url: String?
        switch notification.type {
        case .groupInvite:
            if let notif = notification as? NotificationGroupInviteProtocol {
                url = "/profile/\(notif.inviterID ?? "")"

            }
        case .newChatMessage:
            if let notif = notification as? NotificationNewChatProtocol {
                if notif.groupID == partyID {
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
        case .itemReceived:
            let itemReceivedNotification = notification as? NotificationItemReceivedProtocol
            if itemReceivedNotification?.openDestination?.starts(with: "/") == true {
                url = itemReceivedNotification?.openDestination
                break
            }
            switch itemReceivedNotification?.openDestination {
            case "equipment":
                url = "/inventory/equipment"
            case "customization":
                url = "/user/avatar"
            case "stable", "pets", "mounts":
                url = "/inventory/stable"
            default:
                url = "/inventory/items"
            }
        default:
            break
        }
        if let url = url {
            viewController?.dismiss(animated: true) {
                RouterHandler.shared.handle(urlString: url)
            }
        }
    }
}
