//
//  Route.swift
//  Habitica
//
//  Created by Phillip Thelen on 19.08.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//


import Foundation
import Habitica_Models
import Habitica_API_Client

enum Route {
    case achievements
    case market
    case questShop
    case seasonalShop
    case timeTravelers
    case subscription
    case purchaseGems
    case giftSubscription(username: String)
    case customizationShop
    
    case equipment
    
    case customizations(type: String, group: String? = nil)
    
    case promoInfo
    
    var url: String {
        switch self {
        case .achievements:
            return "/user/achievements"
        case .market:
            return "/inventory/market"
        case .questShop:
            return "/inventory/quests"
        case .customizationShop:
            return "/inventory/customizations"
        case .seasonalShop:
            return "/inventory/seasonal"
        case .timeTravelers:
            return "/inventory/time"
        case .subscription:
            return "/user/settings/subscription"
        case .purchaseGems:
            return "/user/settings/gems"
        case .giftSubscription(let username):
            return "/user/settings/subscription/gift/\(username)"
        case .equipment:
            return "/inventory/equipment"
        case .customizations(let type, let group):
            if let group = group {
                return "/inventory/customizations/\(type)/\(group)"
            } else {
                return "/inventory/customizations/\(type)"
            }
        case .promoInfo:
            return "/promo/info"
        }
    }
}
