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
    var message: String?
    var modalText: String?
}

public class APINotification: NotificationProtocol, NotificationNewsProtocol, NotificationNewChatProtocol, NotificationUnallocatedStatsProtocol, NotificationFirstDropProtocol, NotificationLoginIncentiveProtocol, Decodable {
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
    public var achievementMessage: String?
    public var achievementModalText: String?
    public var egg: String?
    public var hatchingPotion: String?
    public var nextRewardAt: Int = 0
    public var message: String?
    public var rewardKey: String?
    public var rewardText: String?
    
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
        case .firstDrop:
            let data = try? values.decode(APINotificationFirstDropData.self, forKey: .data)
            egg = data?.egg
            hatchingPotion = data?.hatchingPotion
        case .loginIncentive:
            let data = try? values.decode(APILoginIncentiveData.self, forKey: .data)
            nextRewardAt = data?.nextRewardAt ?? 0
            message = data?.message
            rewardKey = data?.rewardKey
            rewardText = data?.rewardText
        default:
            break
        }
        
        if type.rawValue.contains("ACHIEVEMENT") {
            let data = try? values.decode(APINotificationAchievementData.self, forKey: .data)
            achievementKey = data?.achievement
            achievementMessage = data?.message
            achievementModalText = data?.modalText
        }
    }
}
