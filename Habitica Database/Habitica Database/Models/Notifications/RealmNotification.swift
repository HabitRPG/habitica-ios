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
    NotificationQuestInvitationProtocol {
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
    @objc dynamic var questID: String?
    @objc dynamic var questName: String?
    @objc dynamic var points: Int = 0
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(_ id: String, userID: String, type: HabiticaNotificationType) {
        self.init()
        self.id = id
        self.userID = userID
        self.type = type
    }
}
