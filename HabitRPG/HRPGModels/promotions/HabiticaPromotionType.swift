//
//  HabiticaPromotionType.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.08.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//


import UIKit

public enum HabiticaPromotionType {
    case gemsAmount
    case gemsPrice
    case subscription
    case survey
    
    static func getPromoFromKey(key: String, startDate: Date?, endDate: Date?) -> HabiticaPromotion? {
        switch key {
        case "fall_extra_gems", "fall2020", "testfall2020", "fallExtraGems":
            return FallExtraGemsPromotion(startDate: startDate, endDate: endDate)
        case "spooky_extra_gems", "fall2020SecondPromo", "testfall2020SecondPromo", "spookyExtraGems":
            return SpookyExtraGemsPromotion(startDate: startDate, endDate: endDate)
        case "g1g1", "g1g1Sale":
            return GiftOneGetOnePromotion(startDate: startDate, endDate: endDate)
        case "survey2021":
            let url = ConfigRepository.shared.string(variable: .surveyURL)
            return Survey2021Promotion(url: url)
        default:
            return nil
        }
    }
}
