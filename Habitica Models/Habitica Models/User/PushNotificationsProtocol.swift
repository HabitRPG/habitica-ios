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
    var majorUpdates: Bool { get set }
    var partyActivity: Bool { get set }
    var mentionParty: Bool { get set }
    var mentionJoinedGuild: Bool { get set }
    var mentionUnjoinedGuild: Bool { get set }
    var unsubscribeFromAll: Bool { get set }
    var contentRelease: Bool { get set }
}

public extension PushNotificationsProtocol {
    func mapOfKeys() -> [String: Bool] {
        return [
            "giftedGems": giftedGems,
            "giftedSubscription": giftedSubscription,
            "invitedGuild": invitedGuild,
            "invitedParty": invitedParty,
            "invitedQuest": invitedQuest,
            "hasNewPM": hasNewPM,
            "questStarted": questStarted,
            "wonChallenge": wonChallenge,
            "majorUpdates": majorUpdates,
            "partyActivity": partyActivity,
            "mentionParty": mentionParty,
            "mentionJoinedGuild": mentionJoinedGuild,
            "mentionUnjoinedGuild": mentionUnjoinedGuild,
            "unsubscribeFromAll": unsubscribeFromAll,
            "contentRelease": contentRelease
        ]
    }
}
