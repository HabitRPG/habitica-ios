//
//  APIInAppReward.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 17.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIInAppReward: InAppRewardProtocol, Decodable {
    var category: ShopCategoryProtocol?
    var key: String?
    var availableUntil: Date?
    var currency: String?
    var isSuggested: Bool = false
    var lastPurchased: Date?
    var locked: Bool = false
    var path: String?
    var pinType: String?
    var purchaseType: String?
    var imageName: String?
    var text: String?
    var notes: String?
    var type: String?
    var value: Float = 0
    var isSubscriberItem: Bool = false
    
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
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try? values.decode(String.self, forKey: .key)
        availableUntil = try? values.decode(Date.self, forKey: .availableUntil)
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
    }
    
    init() {
    }
}
