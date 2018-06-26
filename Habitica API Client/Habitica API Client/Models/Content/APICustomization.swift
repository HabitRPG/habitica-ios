//
//  APICustomization.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APICustomization: CustomizationProtocol, Decodable {
    var key: String?
    var type: String?
    var group: String?
    var price: Float
    var set: CustomizationSetProtocol?
    
    enum CodingKeys: String, CodingKey {
        case key
        case price
        case set
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try? values.decode(String.self, forKey: .key)
        price = (try? values.decode(Float.self, forKey: .price)) ?? 0
        set = try? values.decode(APICustomizationSet.self, forKey: .set)
    }
}
