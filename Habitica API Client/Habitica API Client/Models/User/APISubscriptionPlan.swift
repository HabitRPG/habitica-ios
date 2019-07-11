//
//  APISubscriptionPlan.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 23.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APISubscriptionPlan: SubscriptionPlanProtocol, Decodable {
    var quantity: Int
    var gemsBought: Int
    var dateTerminated: Date?
    var dateUpdated: Date?
    var dateCreated: Date?
    var planId: String?
    var customerId: String?
    var paymentMethod: String?
    var consecutive: SubscriptionConsecutiveProtocol?
    var mysteryItems: [String]
    
    enum CodingKeys: String, CodingKey {
        case quantity
        case dateTerminated
        case dateUpdated
        case dateCreated
        case gemsBought
        case planId
        case customerId
        case paymentMethod
        case consecutive
        case mysteryItems
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        quantity = (try? values.decode(Int.self, forKey: .quantity)) ?? 0
        gemsBought = (try? values.decode(Int.self, forKey: .gemsBought)) ?? 0
        dateTerminated = try? values.decode(Date.self, forKey: .dateTerminated)
        dateUpdated = try? values.decode(Date.self, forKey: .dateUpdated)
        dateCreated = try? values.decode(Date.self, forKey: .dateCreated)
        planId = try? values.decode(String.self, forKey: .planId)
        customerId = try? values.decode(String.self, forKey: .customerId)
        paymentMethod = try? values.decode(String.self, forKey: .paymentMethod)
        consecutive = try? values.decode(APISubscriptionConsecutive.self, forKey: .consecutive)
        mysteryItems = (try? values.decode([String].self, forKey: .mysteryItems)) ?? []
    }
}
