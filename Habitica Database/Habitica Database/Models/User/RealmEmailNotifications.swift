//
//  RealmEmailNotifications.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 05.02.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmEmailNotifications: Object, EmailNotificationsProtocol {
    @objc dynamic var id: String?
    @objc dynamic var giftedGems: Bool = false
    @objc dynamic var giftedSubscription: Bool = false
    @objc dynamic var invitedGuild: Bool = false
    @objc dynamic var invitedParty: Bool = false
    @objc dynamic var invitedQuest: Bool = false
    @objc dynamic var hasNewPM: Bool = false
    @objc dynamic var questStarted: Bool = false
    @objc dynamic var wonChallenge: Bool = false
    @objc dynamic var majorUpdates: Bool = false
    @objc dynamic var unsubscribeFromAll: Bool = false
    @objc dynamic var kickedGroup: Bool = false
    @objc dynamic var subscriptionReminders: Bool = false
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(id: String?, pnProtocol: EmailNotificationsProtocol) {
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
        majorUpdates = pnProtocol.majorUpdates
        unsubscribeFromAll = pnProtocol.unsubscribeFromAll
        kickedGroup = pnProtocol.kickedGroup
        subscriptionReminders = pnProtocol.subscriptionReminders
    }
}
