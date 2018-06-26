//
//  PushNotificationsProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 03.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol PushNotificationsProtocol {
    
    var giftedGems: Bool { get set }
    var giftedSubscription: Bool { get set }
    var invitedGuild: Bool { get set }
    var invitedParty: Bool { get set }
    var invitedQuest: Bool { get set }
    var hasNewPM: Bool { get set }
    var questStarted: Bool { get set }
    var wonChallenge: Bool { get set }
    var unsubscribeFromAll: Bool { get set }
}
