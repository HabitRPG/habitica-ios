//
//  APIInAppReward.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 17.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

private struct APIUnlockCondition: Decodable {
    var reason: String?
    var incentiveThreshold: Int = 0
}

public class APIInAppReward: InAppRewardProtocol, Decodable {
    public var category: ShopCategoryProtocol?
    public var key: String?
    public var eventStart: Date?
    public var eventEnd: Date?
    public var currency: String?
    public var isSuggested: Bool = false
    public var lastPurchased: Date?
    public var locked: Bool = false
    public var path: String?
    public var pinType: String?
    public var purchaseType: String?
    public var imageName: String?
    public var text: String?
    public var notes: String?
    public var type: String?
    public var value: Float = 0
    public var isSubscriberItem: Bool = false
    public var isValid: Bool { return true }
    public var unlockConditionReason: String?
    public var unlockConditionIncentiveThreshold: Int = 0
    public var previous: String?
    public var level: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case key
        case availableUntil
        case currency
        case isSuggested
        case lastPurchased
        case locked
        case path
        case pinType
        case purchaseType
        case imageName = "class"
        case text
        case notes
        case type
        case value
        case unlockCondition
        case previous
        case level
        case event
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try? values.decode(String.self, forKey: .key)
        isSuggested = (try? values.decode(Bool.self, forKey: .isSuggested)) ?? false
        lastPurchased = try? values.decode(Date.self, forKey: .lastPurchased)
        locked = (try? values.decode(Bool.self, forKey: .locked)) ?? false
        path = try? values.decode(String.self, forKey: .path)
        pinType = try? values.decode(String.self, forKey: .pinType)
        purchaseType = try? values.decode(String.self, forKey: .purchaseType)
        imageName = try? values.decode(String.self, forKey: .imageName)
        text = try? values.decode(String.self, forKey: .text)
        notes = try? values.decode(String.self, forKey: .notes)
        type = try? values.decode(String.self, forKey: .type)
        value = (try? values.decode(Float.self, forKey: .value)) ?? 0
        currency = try? values.decode(String.self, forKey: .currency)
        let unlockCondition = try? values.decode(APIUnlockCondition.self, forKey: .unlockCondition)
        unlockConditionReason = unlockCondition?.reason
        unlockConditionIncentiveThreshold = unlockCondition?.incentiveThreshold ?? 0
        previous = try? values.decode(String.self, forKey: .previous)
        level = (try? values.decode(Int.self, forKey: .level)) ?? 0
        let event = try? values.decode(APIEvent.self, forKey: .event)
        eventStart = event?.start
        eventEnd = event?.end
    }
    
    init() {
    }
}
