//
//  APIUserItems.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIUserItems: UserItemsProtocol, Codable {
    var gear: UserGearProtocol?
    var currentMount: String?
    var currentPet: String?
    
    enum CodingKeys: String, CodingKey {
        case gear
        case currentMount
        case currentPet
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        gear = try? values.decode(APIUserGear.self, forKey: .gear)
        currentPet = try? values.decode(String.self, forKey: .currentPet)
        currentMount = try? values.decode(String.self, forKey: .currentMount)
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
