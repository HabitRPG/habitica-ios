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
    
    func headerView(forSection section: Int, frame: CGRect) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 54))
        view.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        if sections[0].items.count == 0 {
            return view
        }
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 14)
        label.textColor = ThemeService.shared.theme.secondaryTextColor
        label.text = L10n.Titles.notifications.uppercased()
        view.addSubview(label)
        label.pin.start(16).sizeToFit().vCenter()
        let pillLabel = UILabel()
        pillLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
        pillLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        pillLabel.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
        pillLabel.textAlignment = .center
        pillLabel.text = "\(sections[0].items.count)"
        view.addSubview(pillLabel)
        pillLabel.pin.after(of: label).marginStart(8).sizeToFit().wrapContent(padding: 8)
        pillLabel.pin.width(pillLabel.frame.size.width + 12).height(pillLabel.frame.size.height + 4).vCenter()
        pillLabel.cornerRadius = pillLabel.frame.size.height/2
        
        let button = UIButton()
        button.setTitle(L10n.Notifications.dismissAll, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(ThemeService.shared.theme.tintColor, for: .normal)
        view.addSubview(button)
        button.pin.top().bottom().sizeToFit(.height).end(16)
        button.addTarget(self, action: #selector(dismissAll), for: .touchUpInside)
        
        let separator = UIView()
        separator.backgroundColor = ThemeService.shared.theme.tableviewSeparatorColor
        view.addSubview(separator)
        separator.pin.start().end().bottom().height(1)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let notification = item(at: indexPath) else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: notification.type.rawValue, for: indexPath)
        cell.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        
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
        disposable.inner.add(userRepository.readNotification(notification: notification).observeCompleted { })
    }
    
    @objc
    private func dismissAll() {
        let dismissableNotifications = sections[0].items.filter { (notification) -> Bool in
            return notification.isDismissable
        }
        disposable.inner.add(userRepository.readNotifications(notifications: dismissableNotifications).observeCompleted {})
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
                    if !notif.isPublicGuild {
                        return
                    }
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
