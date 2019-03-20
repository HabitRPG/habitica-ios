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
    var items: [InAppRewardProtocol] = []
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case text
        case notes
        case items
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try? values.decode(String.self, forKey: .identifier)
        text = try? values.decode(String.self, forKey: .text)
        notes = try? values.decode(String.self, forKey: .notes)
        items = (try? values.decode([APIInAppReward].self, forKey: .items)) ?? []
    }
    
    init() {
    }
}
