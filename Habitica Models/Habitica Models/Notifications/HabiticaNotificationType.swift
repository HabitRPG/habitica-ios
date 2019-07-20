//
//  HabiticaNotificationType.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 23.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

public enum HabiticaNotificationType: String, EquatableStringEnumProtocol {
    case generic = ""
    case newStuff = "NEW_STUFF"
    case newChatMessage = "NEW_CHAT_MESSAGE"
    case newMysteryItem = "NEW_MYSTERY_ITEMS"
    case unallocatedStatsPoints = "UNALLOCATED_STATS_POINTS"
    case questInvite = "QUEST_INVITE"
    case groupInvite = "GROUP_INVITE"

    public var priority: Int {
        get {
            switch self {
            case .newStuff:
                return 1
            case .groupInvite:
                return 2
            case .questInvite:
                return 3
            case .unallocatedStatsPoints:
                return 4
            case .newMysteryItem:
                return 5
            case .newChatMessage:
                return 6
            default:
                return 100
            }
        }
    }
}
