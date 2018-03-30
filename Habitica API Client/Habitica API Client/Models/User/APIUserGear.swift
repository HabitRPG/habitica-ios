//
//  APIUserGear.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIUserGear: UserGearProtocol, Codable {
    var equipped: OutfitProtocol?
    var costume: OutfitProtocol?
    
    enum CodingKeys: String, CodingKey {
        case equipped
        case costume
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        equipped = try? values.decode(APIOutfit.self, forKey: .equipped)
        costume = try? values.decode(APIOutfit.self, forKey: .costume)
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
