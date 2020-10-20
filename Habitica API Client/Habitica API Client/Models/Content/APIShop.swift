//
//  APIShop.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import Shared

public class APIShop: ShopProtocol, Decodable {
    public var identifier: String?
    public var text: String?
    public var notes: String?
    public var imageName: String?
    public var hasNew: Bool = false
    public var categories: [ShopCategoryProtocol]
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case text
        case notes
        case imageName
        case categories
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try? values.decode(String.self, forKey: .identifier)
        text = try? values.decode(String.self, forKey: .text)
        notes = try? values.decode(String.self, forKey: .notes)
        imageName = try? values.decode(String.self, forKey: .imageName)
        categories = (try? values.decode([APIShopCategory].self, forKey: .categories)) ?? []
        
        if identifier == Constants.MarketKey {
            addGemPurchaseItem()
        }
    }
    
    private func addGemPurchaseItem() {
        var category: ShopCategoryProtocol = APIShopCategory()
        if let index = categories.firstIndex(where: { $0.identifier == "special" }) {
            category = categories.remove(at: index)
        } else {
            category.identifier = "special"
            category.text = "Special"
        }
        let gemItem = APIInAppReward()
        gemItem.key = "gem"
        gemItem.text = "Gem"
        gemItem.notes = "Because you subscribe to Habitica, you can purchase a number of Gems each month using Gold."
        gemItem.imageName = "gem_shop"
        gemItem.purchaseType = "gems"
        gemItem.currency = "gold"
        gemItem.value = 20
        gemItem.isSubscriberItem = true
        gemItem.pinType = "gem"
        gemItem.path = "special.gems"
        category.items.append(gemItem)
        
        if !category.items.contains(where: { $0.key == "fortify" }) {
            let fortify = APIInAppReward()
            fortify.key = "fortify"
            fortify.text = "Fortify Potion"
            fortify.notes = "Return all tasks to neutral value (yellow color), and restore all lost Health"
            fortify.imageName = "inventory_special_fortify"
            fortify.purchaseType = "fortify"
            fortify.currency = "gems"
            fortify.value = 4
            fortify.path = "special.fortify"
            category.items.append(fortify)
        }
        categories.append(category)
    }
}
