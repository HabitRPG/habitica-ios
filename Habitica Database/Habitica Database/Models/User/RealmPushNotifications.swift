//
//  RealmPushNotifications.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 03.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmPushNotifications: Object, PushNotificationsProtocol {
    @objc dynamic var id: String?
    @objc dynamic var giftedGems: Bool = false
    @objc dynamic var giftedSubscription: Bool = false
    @objc dynamic var invitedGuild: Bool = false
    @objc dynamic var invitedParty: Bool = false
    @objc dynamic var invitedQuest: Bool = false
    @objc dynamic var hasNewPM: Bool = false
    @objc dynamic var questStarted: Bool = false
    @objc dynamic var wonChallenge: Bool = false
    @objc dynamic var unsubscribeFromAll: Bool = false
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(id: String?, pnProtocol: PushNotificationsProtocol) {
        self.init()
        self.id = id
        giftedGems = pnProtocol.giftedGems
        giftedSubscription = pnProtocol.giftedSubscription
        invitedGuild = pnProtocol.invitedGuild
        invitedParty = pnProtocol.invitedParty
        invitedQuest = pnProtocol.invitedQuest
        hasNewPM = pnProtocol.hasNewPM
        questStarted = pnProtocol.questStarted
        wonChallenge = pnProtocol.wonChallenge
        unsubscribeFromAll = pnProtocol.unsubscribeFromAll
    }
}
