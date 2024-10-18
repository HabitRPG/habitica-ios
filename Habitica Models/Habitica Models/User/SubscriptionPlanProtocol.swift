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
    var perkMonthCount: Int { get set }
    var dateTerminated: Date? { get set }
    var dateUpdated: Date? { get set }
    var dateCreated: Date? { get set }
    var planId: String? { get set }
    var customerId: String? { get set }
    var paymentMethod: String? { get set }
    var consecutive: SubscriptionConsecutiveProtocol? { get set }
    var mysteryItems: [String] { get set }
    var hourglassPromoReceived: Date? { get set }
    var extraMonths: Int { get set }
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
    
    var isGroupPlanSub: Bool {
        return customerId == "group-plan"
    }
    
    var gemCapTotal: Int {
        return 24 + (consecutive?.gemCapExtra ?? 0)
    }
    
    var gemsRemaining: Int {
        return gemCapTotal - gemsBought
    }
    
    private var isMonthlyRenewal: Bool {
        if planId == "basic_earned" || planId == "group_monthly" {
            return true
        } else {
            return false
        }
    }
    
    var monthsUntilNextHourglass: Int {
        if isMonthlyRenewal {
            return 3 - perkMonthCount
        } else {
            return (consecutive?.offset ?? 0) + 1
        }
    }
    
    var isEligableForHourglassPromo: Bool {
        return hourglassPromoReceived == nil
    }
}

public class PreviewSubscriptionPlan: SubscriptionPlanProtocol {
    public init() {}
    public var quantity: Int = 0
    public var gemsBought: Int = 0
    public var perkMonthCount: Int = 0
    public var dateTerminated: Date?
    public var dateUpdated: Date?
    public var dateCreated: Date?
    public var planId: String?
    public var customerId: String?
    public var paymentMethod: String?
    public var consecutive: SubscriptionConsecutiveProtocol?
    public var mysteryItems: [String] = []
    public var hourglassPromoReceived: Date?
    public var extraMonths: Int = 0
}
