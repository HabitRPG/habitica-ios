//
//  APIUserGear.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIUserGear: UserGearProtocol, Decodable {
    var equipped: OutfitProtocol?
    var costume: OutfitProtocol?
    var owned: [OwnedGearProtocol]
    
    enum CodingKeys: String, CodingKey {
        case equipped
        case costume
        case owned
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        equipped = try? values.decode(APIOutfit.self, forKey: .equipped)
        costume = try? values.decode(APIOutfit.self, forKey: .costume)
        let gearDict = try?values.decode([String: Bool].self, forKey: .owned)
        owned = (gearDict?.map({ (key, isOwned) -> OwnedGearProtocol in
            return APIOwnedGear(key: key, isOwned: isOwned)
        })) ?? []
    }
}
