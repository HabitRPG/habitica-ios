//
//  APIMemberItems.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 18.03.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIMemberItems: UserItemsProtocol, Decodable {
    public var gear: UserGearProtocol?
    public var currentMount: String?
    public var currentPet: String?
    public var ownedQuests: [OwnedItemProtocol] = []
    public var ownedFood: [OwnedItemProtocol] = []
    public var ownedHatchingPotions: [OwnedItemProtocol] = []
    public var ownedEggs: [OwnedItemProtocol] = []
    public var ownedSpecialItems: [OwnedItemProtocol] = []
    
    public var ownedPets: [OwnedPetProtocol]
    public var ownedMounts: [OwnedMountProtocol]
    
    enum CodingKeys: String, CodingKey {
        case gear
        case currentMount
        case currentPet
        case ownedPets = "pets"
        case ownedMounts = "mounts"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        gear = try? values.decode(APIMemberGear.self, forKey: .gear)
        currentPet = try? values.decode(String.self, forKey: .currentPet)
        currentMount = try? values.decode(String.self, forKey: .currentMount)
        
        let petsDict = try?values.decode([String: Int?].self, forKey: .ownedPets)
        ownedPets = (petsDict?.map({ (key, trained) -> OwnedPetProtocol in
            return APIOwnedPet(key: key, trained: trained ?? 0)
        })) ?? []
        let mountsDict = try?values.decode([String: Bool?].self, forKey: .ownedMounts)
        ownedMounts = (mountsDict?.map({ (key, owned) -> APIOwnedMount in
            return APIOwnedMount(key: key, owned: owned ?? false)
        })) ?? []
    }
}
