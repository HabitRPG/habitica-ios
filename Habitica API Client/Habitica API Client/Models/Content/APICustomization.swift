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
    var text: String?
    var notes: String?
    var group: String?
    var price: Float
    var set: CustomizationSetProtocol?
    var isValid: Bool = false
    public var isManaged: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case key
        case price
        case text
        case notes
        case set
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try? values.decode(String.self, forKey: .key)
        price = (try? values.decode(Float.self, forKey: .price)) ?? 0
        text = try? values.decode(String.self, forKey: .text)
        notes = try? values.decode(String.self, forKey: .notes)
        set = try? values.decode(APICustomizationSet.self, forKey: .set)
    }
}
