//
//  APIBaseNotification.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 02.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

private class APINotificationAchievementData: Decodable {
    var achievement: String
}

public class APINotification: NotificationProtocol, NotificationNewsProtocol, NotificationNewChatProtocol, NotificationUnallocatedStatsProtocol, NotificationFirstDropProtocol, Decodable {
    public var isValid: Bool = true
    
    public var id: String = ""
    public var type: HabiticaNotificationType = .generic
    public var seen: Bool = false
    public var groupID: String?
    public var groupName: String?
    public var isParty: Bool = false
    public var title: String?
    public var points: Int = 0
    public var achievementKey: String?
    public var egg: String?
    public var potion: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case data
        case seen
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? values.decode(String.self, forKey: .id)) ?? ""
        type = HabiticaNotificationType(rawValue: (try? values.decode(String.self, forKey: .type)) ?? "") ?? .generic
        seen = (try? values.decode(Bool.self, forKey: .seen)) ?? false
        switch type {
        case .newChatMessage:
            let data = try? values.decode(APINotificationNewChatData.self, forKey: .data)
            groupID = data?.groupID
            groupName = data?.groupName
        case .newStuff:
            let data = try? values.decode(APINotificationNewStuffData.self, forKey: .data)
            title = data?.title
        case .unallocatedStatsPoints:
            let data = try? values.decode(APINotificationUnallocatedStatsData.self, forKey: .data)
            points = data?.points ?? 0
        case .achievementGeneric:
            let data = try? values.decode(APINotificationAchievementData.self, forKey: .data)
            achievementKey = data?.achievement
        case .firstDrop:
            let data = try? values.decode(APINotificationFirstDropData.self, forKey: .data)
            egg = data?.egg
            potion = data?.potion
        default:
            break
        }
    }
}
