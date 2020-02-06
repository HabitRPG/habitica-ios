//
//  EmailNotificationsProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 05.02.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol EmailNotificationsProtocol {
    
    var giftedGems: Bool { get set }
    var giftedSubscription: Bool { get set }
    var invitedGuild: Bool { get set }
    var invitedParty: Bool { get set }
    var invitedQuest: Bool { get set }
    var hasNewPM: Bool { get set }
    var questStarted: Bool { get set }
    var wonChallenge: Bool { get set }
    var majorUpdates: Bool { get set }
    var unsubscribeFromAll: Bool { get set }
    var kickedGroup: Bool { get set }
    var subscriptionReminders: Bool { get set }
}
