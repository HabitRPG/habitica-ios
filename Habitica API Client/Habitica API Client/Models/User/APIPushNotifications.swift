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
    var unsubscribeFromAll: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case giftedGems
        case giftedSubscription
        case invitedGuild
        case invitedParty
        case invitedQuest
        case hasNewPM = "newPM"
        case questStarted
        case wonChallenge
        case unsubscribeFromAll
    }
}
