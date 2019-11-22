//
//  SubscriptionPlanProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 23.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol SubscriptionPlanProtocol {
    var quantity: Int { get set }
    var gemsBought: Int { get set }
    var dateTerminated: Date? { get set }
    var dateUpdated: Date? { get set }
    var dateCreated: Date? { get set }
    var planId: String? { get set }
    var customerId: String? { get set }
    var paymentMethod: String? { get set }
    var consecutive: SubscriptionConsecutiveProtocol? { get set }
    var mysteryItems: [String] { get set }
}

public extension SubscriptionPlanProtocol {
    var isActive: Bool {
        if let dateTerminated = dateTerminated {
            if dateTerminated < Date() {
                return false
            }
        }
        return customerId != nil
    }
    
    var isGifted: Bool {
        return customerId == "Gift"
    }
    
    var gemCapTotal: Int {
        return 25 + (consecutive?.gemCapExtra ?? 0)
    }
    
    var gemsRemaining: Int {
        return gemCapTotal - gemsBought
    }
}
