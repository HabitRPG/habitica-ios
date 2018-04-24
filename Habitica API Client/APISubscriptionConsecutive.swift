//
//  APISubscriptionConsecutive.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 23.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APISubscriptionConsecutive: SubscriptionConsecutiveProtocol, Decodable {
    var hourglasses: Int = 0
    var gemCapExtra: Int = 0
    var gemsPurchased: Int = 0
    var offset: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case hourglasses = "trinkets"
        case gemCapExtra
        case gemsPurchased = "count"
        case offset
    }
}
