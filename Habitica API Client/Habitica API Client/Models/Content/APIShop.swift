//
//  APIShop.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

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
    }
}
