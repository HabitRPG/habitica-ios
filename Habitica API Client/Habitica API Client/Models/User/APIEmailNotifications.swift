//
//  APIEmailNotifications.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 05.02.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIEmailNotifications: EmailNotificationsProtocol, Decodable {
    var giftedGems: Bool = false
    var giftedSubscription: Bool = false
    var invitedGuild: Bool = false
    var invitedParty: Bool = false
    var invitedQuest: Bool = false
    var hasNewPM: Bool = false
    var questStarted: Bool = false
    var wonChallenge: Bool = false
    var majorUpdates: Bool = false
    var unsubscribeFromAll: Bool = false
    var kickedGroup: Bool = false
    var subscriptionReminders: Bool = false
    var contentRelease: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case giftedGems
        case giftedSubscription
        case invitedGuild
        case invitedParty
        case invitedQuest
        case hasNewPM = "newPM"
        case questStarted
        case wonChallenge
        case majorUpdates
        case unsubscribeFromAll
        case kickedGroup
        case subscriptionReminders
        case contentRelease
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        giftedGems = (try? values.decode(Bool.self, forKey: .giftedGems)) ?? false
        giftedSubscription = (try? values.decode(Bool.self, forKey: .giftedSubscription)) ?? false
        invitedGuild = (try? values.decode(Bool.self, forKey: .invitedGuild)) ?? false
        invitedParty = (try? values.decode(Bool.self, forKey: .invitedParty)) ?? false
        invitedQuest = (try? values.decode(Bool.self, forKey: .invitedQuest)) ?? false
        hasNewPM = (try? values.decode(Bool.self, forKey: .hasNewPM)) ?? false
        questStarted = (try? values.decode(Bool.self, forKey: .questStarted)) ?? false
        wonChallenge = (try? values.decode(Bool.self, forKey: .wonChallenge)) ?? false
        majorUpdates = (try? values.decode(Bool.self, forKey: .majorUpdates)) ?? false
        unsubscribeFromAll = (try? values.decode(Bool.self, forKey: .unsubscribeFromAll)) ?? false
        kickedGroup = (try? values.decode(Bool.self, forKey: .kickedGroup)) ?? false
        subscriptionReminders = (try? values.decode(Bool.self, forKey: .subscriptionReminders)) ?? false
        contentRelease = (try? values.decode(Bool.self, forKey: .contentRelease)) ?? false
    }
}
