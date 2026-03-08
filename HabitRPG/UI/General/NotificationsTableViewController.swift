//
//  NotificationsTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import SwiftUI
import ReactiveSwift
import Kingfisher

class NotificationsViewModel: ViewModel {
    var onDismiss: ((@escaping () -> Void) -> Void)?
    
    private let userRepository = UserRepository()
    private let socialRepository = SocialRepository()
    private let inventoryRepository = InventoryRepository()
    @Published var notifications: [NotificationProtocol] = []
    @Published var partyID: String?
    @Published var inviterNames: [String: String?] = [:]
    @Published var quests: [String: QuestProtocol?] = [:]
    
    override init() {
        super.init()
        disposable.add(userRepository.getNotifications()
            .on(value: {[weak self] (entries, _) in
            if self?.notifications.isEmpty == true {
                self?.notifications = entries
            } else {
                withAnimation {
                    self?.notifications = entries
                }
            }
            entries.forEach { notification in
                if notification.type == .groupInvite {
                    if let groupInvite = notification as? NotificationGroupInviteProtocol, let id = groupInvite.inviterID {
                        if self?.inviterNames.keys.contains(id) != true {
                            self?.getInviter(id: id)
                        }
                    }
                } else if notification.type == .questInvite {
                    if let questInvite = notification as? NotificationQuestInviteProtocol, let key = questInvite.questKey {
                        if self?.quests.keys.contains(key) != true {
                            self?.getQuest(key: key)
                        }
                    }
                }
            }
            }).start())
        disposable.add(userRepository.getUser().map { $0.party?.id }.skipRepeats()
                        .on(value: {[weak self] partyID in
                            self?.partyID = partyID
                        }).start())
    }
    
    func dismiss(notification: NotificationProtocol) {
        disposable.add(userRepository.readNotification(notification: notification).observeCompleted {})
    }
    
    func dismissAllNotifications() {
        let dismissableNotifications = notifications.filter { (notification) -> Bool in
            if !notification.isValid {
                return false
            }
            return notification.isDismissable
        }
        disposable.add(userRepository.readNotifications(notifications: dismissableNotifications).observeCompleted {})
    }
    
    func updateNotifications() {
        disposable.add(userRepository.retrieveUser(forced: true).observeCompleted {
        })
    }
    
    func decline(notification: NotificationProtocol) {
        if notification.type == .groupInvite, let notification = notification as? NotificationGroupInviteProtocol {
            socialRepository.rejectGroupInvitation(groupID: notification.groupID ?? "").observeCompleted {
                self.updateNotifications()
            }
        } else if notification.type == .questInvite && notification is NotificationQuestInviteProtocol {
            socialRepository.rejectQuestInvitation(groupID: "party").observeCompleted {
                self.updateNotifications()
            }
        }
    }
    
    func accept(notification: NotificationProtocol) {
        if notification.type == .groupInvite, let notification = notification as? NotificationGroupInviteProtocol {
            socialRepository.joinGroup(groupID: notification.groupID ?? "", isParty: notification.isParty).observeCompleted {
                self.updateNotifications()
            }
        } else if notification.type == .questInvite && notification is NotificationQuestInviteProtocol {
            socialRepository.acceptQuestInvitation(groupID: "party").observeCompleted {
                self.updateNotifications()
            }
            
        }
    }
    
    func openNotification(notification: NotificationProtocol) {
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
            url = openItemReceivedNotification(notification: notification as? NotificationItemReceivedProtocol)
        default:
            break
        }
        if let url = url, let onDismiss = onDismiss {
            onDismiss {
                RouterHandler.shared.handle(urlString: url)
            }
        }
    }
    
    private func openItemReceivedNotification(notification: NotificationItemReceivedProtocol?) -> String? {
        let url: String?
        if notification?.openDestination?.starts(with: "/") == true {
            url = notification?.openDestination
        } else {
            switch notification?.openDestination {
            case "equipment":
                url = "/inventory/equipment"
            case "customization":
                url = "/user/avatar"
            case "stable", "pets", "mounts":
                url = "/inventory/stable"
            default:
                url = "/inventory/items"
            }
        }
        return url
    }
    
    private func getInviter(id: String) {
        inviterNames[id] = nil
        disposable.add(socialRepository.retrieveMember(userID: id).observeValues({[weak self] member in
            if let name = member?.profile?.name ?? member?.username {
                self?.inviterNames[id] = name
            }
        }))
    }
    
    private func getQuest(key: String) {
        quests[key] = nil
        disposable.add(inventoryRepository.getQuest(key: key).take(first: 1).on(value: {[weak self] quest in
            self?.quests[key] = quest
        }).start())
    }
}

struct NotificationImage<Content: View>: View {
    let content: Content
    
    var body: some View {
        Group {
            content
        }.frame(width: 56)
    }
}

extension NotificationImage where Content == Spacer {
    init() {
        self.content = Spacer()
    }
}

struct NotificationTexts<Title: View, Description: View>: View {
    let title: Title
    let description: Description
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            title.scaledFont(size: 15, weight: .semibold)
            description.scaledFont(size: 15)
        }.lineSpacing(5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
    }
}

extension NotificationTexts where Title == EmptyView {
    init (description: Description) {
        self.title = EmptyView()
        self.description = description
    }
}

extension NotificationTexts where Description == EmptyView {
    init (title: Title) {
        self.title = title
        self.description = EmptyView()
    }
}

struct NotificationMainContent<Content: View>: View {
    var onDismiss: (() -> Void)?
    @ViewBuilder let content: () -> Content
    
    @State private var isDismissing = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            HStack(spacing: 8) {
                content()
            }
            if let onDismiss = onDismiss {
                Group {
                    if isDismissing {
                        ProgressView().habiticaProgressStyle(strokeWidth: 4)
                            .frame(width: 20, height: 20)
                            .frame(width: 40, height: 40)
                    } else {
                        Image(.notificationsClose)
                            .frame(width: 40, height: 40)
                            .onTapGesture {
                                isDismissing = true
                                
                                onDismiss()
                            }
                    }
                }.frame(maxHeight: .infinity, alignment: .top)
            }
        }.fixedSize(horizontal: false, vertical: true)
    }
}

struct NotificationResponseView: View {
    var onDecline: (() -> Void)
    var onAccept: (() -> Void)
    
    var body: some View {
        HStack(spacing: 12) {
            HabiticaButtonUI(label: Image(systemName: .xmark).foregroundStyle(.red1), color: .red100, size: .small, onTap: {
                onDecline()
            })
            HabiticaButtonUI(label: Image(systemName: .checkmark).foregroundStyle(.green1), color: .green100, size: .small, onTap: {
                onAccept()
            })
        }.scaledFont(size: 17, weight: .medium)
    }
}

struct BasicNotificationView: View {
    let notification: NotificationProtocol
    let onDismiss: () -> Void
    
    var body: some View {
        NotificationMainContent(onDismiss: onDismiss) {
            NotificationImage()
            NotificationTexts(description: Text(notification.id))
        }
    }
}

struct CardReceivedNotificationView: View {
    let notification: NotificationCardReceivedProtocol
    let onDismiss: () -> Void
    
    var body: some View {
        NotificationMainContent(onDismiss: onDismiss) {
            NotificationImage(content: PixelArtView(name: "notif_inventory_special_\(notification.cardKey ?? "")").frame(width: 28, height: 28))
            NotificationTexts(description: Text(markdown: "\(notification.cardSenderName ?? "") sent you a **\(notification.cardKey?.localizedCapitalized ?? "") Card!**"))
        }
    }
}

struct UnallocatedStatsNotificationView: View {
    let notification: NotificationUnallocatedStatsProtocol
    let onDismiss: () -> Void

    var body: some View {
        NotificationMainContent(onDismiss: onDismiss) {
            NotificationImage(content: Image(.notificationsStats))
            NotificationTexts(description: Text(markdown: L10n.Notifications.unallocatedStatPoints(notification.points)))
        }
    }
}

struct NewStuffNotificationView: View {
    let notification: NotificationNewsProtocol
    let onDismiss: () -> Void

    var body: some View {
        NotificationMainContent(onDismiss: onDismiss) {
            NotificationImage(content: Image(.notificationsBailey))
            NotificationTexts(title: Text(L10n.Notifications.newBailey), description: Text(markdown: notification.title ?? ""))
        }
    }
}

struct NewChatMessageNotificationView: View {
    let notification: NotificationNewChatProtocol
    let partyID: String?
    let onDismiss: () -> Void

    var body: some View {
        NotificationMainContent(onDismiss: onDismiss) {
            NotificationImage(content: Image(Asset.notificationParty.name).frame(width: 32, height: 32))
            if partyID == notification.groupID {
                NotificationTexts(description: Text(markdown: L10n.Notifications.unreadPartyMessage(notification.groupName?.unicodeEmoji ?? "")))
            } else {
                NotificationTexts(description: Text(markdown: L10n.Notifications.unreadGuildMessage(notification.groupName?.unicodeEmoji ?? "")))
            }
        }
    }
}

struct ItemReceivedNotificationView: View {
    let notification: NotificationItemReceivedProtocol
    let onDismiss: () -> Void

    var body: some View {
        NotificationMainContent(onDismiss: onDismiss) {
            NotificationImage(content: PixelArtView(name: notification.icon ?? "").frame(width: 28, height: 28))
            NotificationTexts(title: Text(markdown: notification.title ?? ""), description: Text(markdown: notification.message ?? ""))
        }
    }
}

extension Text {
    init(markdown: String) {
        self.init(LocalizedStringKey(markdown.unicodeEmoji))
    }
}

struct NewMysteryItemNotificationView: View {
    let notification: NotificationNewMysteryItemProtocol
    let onDismiss: () -> Void

    var body: some View {
        NotificationMainContent(onDismiss: onDismiss) {
            let month = Calendar.current.component(.month, from: Date())
            let monthString = month < 10 ? "0\(month)" : "\(month)"
            NotificationImage(content: PixelArtView(name: "notif_inventory_present_\(monthString)").frame(width: 28, height: 28))
            NotificationTexts(description: Text(markdown: L10n.Notifications.newMysteryItem))
        }
    }
}

struct QuestInviteNotificationView: View {
    let notification: NotificationQuestInviteProtocol
    let quest: QuestProtocol?
    let onDecline: () -> Void
    let onAccept: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            if let quest = quest {
                NotificationMainContent(content: {
                    NotificationImage(content: Image(.notificationsQuest))
                    NotificationTexts(description: Text(markdown: L10n.Notifications.questInvite(quest.text ?? "")))
                })
                VStack(spacing: 12) {
                    HStack {
                        if let boss = quest.boss {
                            Text(L10n.boss)
                            Spacer()
                            HStack(spacing: 4) {
                                Text("\(boss.health)").foregroundStyle(.red1)
                                Image(uiImage: HabiticaIcons.imageOfHeartLightBg)
                            }.padding(.horizontal, 11)
                                .padding(.vertical, 6)
                                .background(.red500)
                                .cornerRadius(UIConstants.mediumCornerRadius)
                        } else if let collect = quest.collect {
                            Text(L10n.collect)
                            Spacer()
                            HStack(spacing: 2) {
                                ForEach(collect, id: \.key) { item in
                                    KFImage(ImageManager.buildImageUrl(name: "quest_\(quest.key ?? "")_\(item.key ?? "")"))
                                        .resizable()
                                        .interpolation(.none)
                                        .frame(width: 25, height: 25)
                                }
                                let sum = collect.map { $0.count }.reduce(0, +)
                                Text("\(sum)")
                                    .padding(4)
                                    .background(Color(ThemeService.shared.theme.offsetBackgroundColor))
                                    .cornerRadius(UIConstants.mediumCornerRadius)
                            }
                        }
                    }
                    HStack {
                        Text(L10n.difficulty)
                        Spacer()
                        Image(uiImage: HabiticaIcons.imageOfDifficultyStars(difficulty: CGFloat(quest.boss?.strength ?? 1)))
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(Color(ThemeService.shared.theme.offsetBackgroundColor))
                            .cornerRadius(UIConstants.mediumCornerRadius)
                    }
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                .padding(11)
                .background(Color(ThemeService.shared.theme.contentBackgroundColor))
                .cornerRadius(UIConstants.mediumCornerRadius)
                    
                }
            NotificationResponseView(onDecline: onDecline, onAccept: onAccept)
        }
    }
}

struct GroupInviteNotificationView: View {
    let notification: NotificationGroupInviteProtocol
    let inviterName: String?
    let onDecline: () -> Void
    let onAccept: () -> Void

    func getTitleFor(groupName: String, inviterName: String?, isPartyInvitation: Bool) -> String {
        var unformattedString = ""
        if isPartyInvitation {
            if let inviterName = inviterName {
                unformattedString = L10n.Party.invitationInvitername(inviterName, groupName)
            } else {
                unformattedString = L10n.Party.invitationNoInvitername(groupName)
            }
        } else {
            if let inviterName = inviterName {
                unformattedString = L10n.Groups.guildInvitationInvitername(inviterName, groupName)
            } else {
                unformattedString = L10n.Groups.guildInvitationNoInvitername(groupName)
            }
        }
        return unformattedString
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NotificationMainContent {
                NotificationImage(content: Image(.notificationsGuild))
                NotificationTexts(description: Text(markdown: getTitleFor(groupName: notification.groupName ?? "", inviterName: inviterName, isPartyInvitation: notification.isParty)))
            }
            NotificationResponseView(onDecline: onDecline, onAccept: onAccept)
        }
    }
}

struct AchievementNotificationView: View {
    let notification: NotificationProtocol
    let onDismiss: () -> Void

    var body: some View {
        NotificationMainContent(onDismiss: onDismiss) {
            NotificationImage(content: Image(.notificationsStats))
            NotificationTexts(title: Text(markdown: notification.achievementModalText ?? ""),
                              description: Text(markdown: notification.achievementMessage ?? ""))
        }
    }
}

struct GroupTaskNotificationView: View {
    let notification: NotificationGroupTaskProtocol
    let onDismiss: () -> Void
    
    var body: some View {
        NotificationMainContent(onDismiss: onDismiss) {
            NotificationImage(content: Image(.notificationsGroupTask))
            if let formatted = try? HabiticaMarkdownHelper.toHabiticaAttributedString(notification.notificationMessage ?? "") {
                NotificationTexts(description: Text(AttributedString(formatted)))
            }
        }
    }
}

struct NotificationsPage: View {
    @ObservedObject var viewModel: NotificationsViewModel
    
    @ViewBuilder
    private func renderNotification(notification: NotificationProtocol) -> some View {
        let onNotificationDismiss: () -> Void = {
            viewModel.dismiss(notification: notification)
        }
        let type = notification.type
        if type == .unallocatedStatsPoints, let notification = notification as? NotificationUnallocatedStatsProtocol {
            UnallocatedStatsNotificationView(notification: notification, onDismiss: onNotificationDismiss)
        } else if type == .newStuff, let notification = notification as? NotificationNewsProtocol {
            NewStuffNotificationView(notification: notification, onDismiss: onNotificationDismiss)
        } else if type == .newChatMessage, let notification = notification as? NotificationNewChatProtocol {
            NewChatMessageNotificationView(notification: notification, partyID: viewModel.partyID, onDismiss: onNotificationDismiss)
        } else if type == .itemReceived, let notification = notification as? NotificationItemReceivedProtocol {
            ItemReceivedNotificationView(notification: notification, onDismiss: onNotificationDismiss)
        } else if type == .newMysteryItem, let notification = notification as? NotificationNewMysteryItemProtocol {
            NewMysteryItemNotificationView(notification: notification, onDismiss: onNotificationDismiss)
        } else if type == .questInvite, let notification = notification as? NotificationQuestInviteProtocol {
            QuestInviteNotificationView(notification: notification, quest: viewModel.quests[notification.questKey ?? ""] ?? nil, onDecline: {
                viewModel.decline(notification: notification)
            }, onAccept: {
                viewModel.accept(notification: notification)
            })
        } else if type == .groupInvite, let notification = notification as? NotificationGroupInviteProtocol {
            GroupInviteNotificationView(notification: notification, inviterName: viewModel.inviterNames[notification.inviterID ?? ""] ?? nil, onDecline: {
                viewModel.decline(notification: notification)
            }, onAccept: {
                viewModel.accept(notification: notification)
            })
        } else if notification.achievementKey != nil {
            AchievementNotificationView(notification: notification, onDismiss: onNotificationDismiss)
        } else if type.isGroupPlan, let notification = notification as? NotificationGroupTaskProtocol {
            GroupTaskNotificationView(notification: notification, onDismiss: onNotificationDismiss)
        } else if type == .cardReceived, let notification = notification as? NotificationCardReceivedProtocol {
            CardReceivedNotificationView(notification: notification, onDismiss: onNotificationDismiss)
        } else {
            BasicNotificationView(notification: notification, onDismiss: onNotificationDismiss)
        }
    }
    
    var body: some View {
        Group {
            if viewModel.notifications.isEmpty {
                NoContentView(icon: Image(Asset.emptyNotificationsIcon.name), title: Text(L10n.Empty.Notifications.title), content: Text(L10n.Empty.Notifications.description))
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.notifications, id: \.id) { notification in
                            if notification.isValid {
                                renderNotification(notification: notification)
                                    .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                                    .padding(8)
                                    .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                                    .cornerRadius(UIConstants.largeCornerRadius)
                                    .onTapGesture {
                                        viewModel.openNotification(notification: notification)
                                    }
                                    .padding(.horizontal, 17)
                            }
                        }
                    }
                }
            }
        }.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(viewModel.notifications.count)")
            }
            if !viewModel.notifications.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.dismissAllNotifications()
                    } label: {
                        Text(L10n.Notifications.dismissAll).foregroundStyle(.tint)
                    }
                }
            }
        }
    }
}

class NotificationsTableViewController: BaseHostingViewController<NotificationsPage> {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    private let viewModel = NotificationsViewModel()
    private var selectedIndex: Int?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: NotificationsPage(viewModel: viewModel))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = L10n.Titles.notifications
        viewModel.onDismiss = { [weak self] callback in
            self?.dismiss(animated: true, completion: {
                callback()
            })
        }
        hidesBottomBarWhenPushed = false
    }
}
