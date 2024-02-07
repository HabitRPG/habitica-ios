//
//  APIPushNotifications.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 03.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIPushNotifications: PushNotificationsProtocol, Decodable {
    var giftedGems: Bool = false
    var giftedSubscription: Bool = false
    var invitedGuild: Bool = false
    var invitedParty: Bool = false
    var invitedQuest: Bool = false
    var hasNewPM: Bool = false
    var questStarted: Bool = false
    var wonChallenge: Bool = false
    var majorUpdates: Bool = false
    var partyActivity: Bool = false
    var mentionParty: Bool = false
    var mentionJoinedGuild: Bool = false
    var mentionUnjoinedGuild: Bool = false
    var unsubscribeFromAll: Bool = false
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
        case partyActivity
        case mentionParty
        case mentionJoinedGuild
        case mentionUnjoinedGuild
        case unsubscribeFromAll
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
        partyActivity = (try? values.decode(Bool.self, forKey: .partyActivity)) ?? false
        mentionParty = (try? values.decode(Bool.self, forKey: .mentionParty)) ?? false
        mentionJoinedGuild = (try? values.decode(Bool.self, forKey: .mentionJoinedGuild)) ?? false
        mentionUnjoinedGuild = (try? values.decode(Bool.self, forKey: .mentionUnjoinedGuild)) ?? false
        unsubscribeFromAll = (try? values.decode(Bool.self, forKey: .unsubscribeFromAll)) ?? false
        contentRelease = (try? values.decode(Bool.self, forKey: .contentRelease)) ?? false
    }
}
