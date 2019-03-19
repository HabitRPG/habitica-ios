//
//  APIMemberGear.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 18.03.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIMemberGear: UserGearProtocol, Decodable {
    var equipped: OutfitProtocol?
    var costume: OutfitProtocol?
    var owned: [OwnedGearProtocol] = []
    
    enum CodingKeys: String, CodingKey {
        case equipped
        case costume
        case owned
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        equipped = try? values.decode(APIOutfit.self, forKey: .equipped)
        costume = try? values.decode(APIOutfit.self, forKey: .costume)
    }
}
