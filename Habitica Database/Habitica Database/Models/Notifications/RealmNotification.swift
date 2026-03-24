//
//  RealmNotification.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 23.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmNotification: BaseModel,
    NotificationNewsProtocol,
    NotificationUnallocatedStatsProtocol,
    NotificationNewChatProtocol,
    NotificationQuestInviteProtocol,
    NotificationGroupInviteProtocol,
    NotificationNewMysteryItemProtocol,
    NotificationLoginIncentiveProtocol,
    NotificationFirstDropProtocol,
    NotificationItemReceivedProtocol,
    NotificationGroupTaskProtocol,
    NotificationCardReceivedProtocol {
    @objc dynamic var id: String = ""
    @objc dynamic var realmType: String = ""
    var type: HabiticaNotificationType {
        get {
            return HabiticaNotificationType(rawValue: realmType) ?? HabiticaNotificationType.generic
        }
        set {
            realmType = newValue.rawValue
            priority = newValue.priority
        }
    }
    @objc dynamic var seen: Bool = false
    @objc dynamic var userID: String = ""
    @objc dynamic var priority: Int = 0
    @objc dynamic var date: Date? = Date()
    @objc dynamic var notificationMessage: String?

    @objc dynamic var title: String?
    @objc dynamic var groupID: String?
    @objc dynamic var groupName: String?
    @objc dynamic var inviterID: String?
    @objc dynamic var isParty: Bool = false
    @objc dynamic var isPublicGuild: Bool = false
    @objc dynamic var questKey: String?
    @objc dynamic var points: Int = 0
    @objc dynamic var achievementKey: String?
    @objc dynamic var achievementMessage: String?
    @objc dynamic var achievementModalText: String?
    @objc dynamic var egg: String?
    @objc dynamic var hatchingPotion: String?
    
    @objc dynamic var cardKey: String?
    @objc dynamic var cardSenderID: String?
    @objc dynamic var cardSenderName: String?
    
    @objc dynamic var nextRewardAt: Int = -1
    @objc dynamic var message: String?
    @objc dynamic var rewardKey: [String] {
        get {
            return realmRewardKey.map({ (key) -> String in
                return key
            })
        }
        set {
            realmRewardKey.removeAll()
            newValue.forEach { (key) in
                realmRewardKey.append(key)
            }
        }
    }
    var realmRewardKey = List<String>()
    @objc dynamic var rewardText: String?
    
    @objc dynamic var openDestination: String?
    @objc dynamic var icon: String?

    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(_ id: String, userID: String, type: HabiticaNotificationType) {
        self.init()
        self.id = id
        self.userID = userID
        self.type = type
    }
    
    convenience init(userID: String?, protocolObject: NotificationProtocol) {
        self.init()
        self.userID = userID ?? ""
        self.id = protocolObject.id
        self.type = protocolObject.type
        self.notificationMessage = protocolObject.notificationMessage
        if let notification = protocolObject as? NotificationNewChatProtocol {
            groupID = notification.groupID
            groupName = notification.groupName
        }
        if let notification = protocolObject as? NotificationUnallocatedStatsProtocol {
            points = notification.points
        }
        if let notification = protocolObject as? NotificationNewsProtocol {
            title = notification.title
        }
        if let notification = protocolObject as? NotificationLoginIncentiveProtocol {
            nextRewardAt = notification.nextRewardAt
            message = notification.message
            rewardKey = notification.rewardKey
            rewardText = notification.rewardText
        }
        if let notification = protocolObject as? NotificationItemReceivedProtocol {
            title = notification.title
            message = notification.message
            icon = notification.icon
            openDestination = notification.openDestination
        }
        if let notification = protocolObject as? NotificationCardReceivedProtocol {
            cardKey = notification.cardKey
            cardSenderID = notification.cardSenderID
            cardSenderName = notification.cardSenderName
        }
        achievementKey = protocolObject.achievementKey
        achievementMessage = protocolObject.achievementMessage
        achievementModalText = protocolObject.achievementModalText
    }
}
