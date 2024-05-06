//
//  APIShopCategories.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIShopCategory: ShopCategoryProtocol, Decodable {
    var identifier: String?
    var text: String?
    var notes: String?
    var path: String?
    var purchaseAll: Bool = false
    var pinType: String?
    var items: [InAppRewardProtocol] = []
    var endDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case text
        case notes
        case path
        case purchaseAll
        case pinType
        case items
        case event
        case endDate = "end"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try? values.decode(String.self, forKey: .identifier)
        text = try? values.decode(String.self, forKey: .text)
        notes = try? values.decode(String.self, forKey: .notes)
        path = try? values.decode(String.self, forKey: .path)
        purchaseAll = (try? values.decode(Bool.self, forKey: .purchaseAll)) ?? false
        pinType = try? values.decode(String.self, forKey: .pinType)
        items = (try? values.decode([APIInAppReward].self, forKey: .items)) ?? []
        let event = try? values.decode(APIEvent.self, forKey: .event)
        if let end = try? values.decode(Date.self, forKey: .endDate) {
            endDate = end
        } else {
            
        }
        items.forEach { item in
            if item.endDate != nil && endDate == nil {
                endDate = item.endDate
            }
            if let start = event?.start {
                item.eventStart = start
            }
            if let end = event?.end {
                item.eventEnd = end
            }
            
            if item.path?.starts(with: "hair.") == true {
                item.key = item.path
            }
        }
    }
    
    init() {
    }
}
