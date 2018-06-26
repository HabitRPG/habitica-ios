//
//  ShopProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol ShopProtocol {
    var identifier: String? { get set }
    var text: String? { get set }
    var notes: String? { get set }
    var imageName: String? { get set }
    var categories: [ShopCategoryProtocol] { get set }
    var hasNew: Bool { get set }
}

@objc
public class Shops: NSObject {
    @objc public static let MarketKey = "market"
    @objc public static let GearMarketKey = "market-gear"
    @objc public static let QuestShopKey = "questShop"
    @objc public static let TimeTravelersShopKey = "timeTravelersShop"
    @objc public static let SeasonalShopKey = "seasonalShop"
}
