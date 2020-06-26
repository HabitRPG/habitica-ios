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

class RealmNotification: Object,
    NotificationNewsProtocol,
    NotificationUnallocatedStatsProtocol,
    NotificationNewChatProtocol,
    NotificationQuestInviteProtocol,
    NotificationGroupInviteProtocol,
    NotificationNewMysteryItemProtocol,
NotificationFirstDropProtocol {
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

    @objc dynamic var title: String?
    @objc dynamic var groupID: String?
    @objc dynamic var groupName: String?
    @objc dynamic var inviterID: String?
    @objc dynamic var isParty: Bool = false
    @objc dynamic var isPublicGuild: Bool = false
    @objc dynamic var questKey: String?
    @objc dynamic var points: Int = 0
    @objc dynamic var achievementKey: String?
    @objc dynamic var egg: String?
    @objc dynamic var potion: String?
    
    var isValid: Bool {
        return !isInvalidated
    }
    
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
        achievementKey = protocolObject.achievementKey
    }
}
