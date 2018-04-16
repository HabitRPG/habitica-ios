//
//  APIUserItems.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIUserItems: UserItemsProtocol, Decodable {
    var gear: UserGearProtocol?
    var currentMount: String?
    var currentPet: String?
    var ownedQuests: [OwnedItemProtocol]
    var ownedFood: [OwnedItemProtocol]
    var ownedHatchingPotions: [OwnedItemProtocol]
    var ownedEggs: [OwnedItemProtocol]
    
    var ownedPets: [OwnedPetProtocol]
    var ownedMounts: [OwnedMountProtocol]
    
    enum CodingKeys: String, CodingKey {
        case gear
        case currentMount
        case currentPet
        case ownedQuests = "quests"
        case ownedFood = "food"
        case ownedHatchingPotions = "hatchingPotions"
        case ownedEggs = "eggs"
        case ownedPets = "pets"
        case ownedMounts = "mounts"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        gear = try? values.decode(APIUserGear.self, forKey: .gear)
        currentPet = try? values.decode(String.self, forKey: .currentPet)
        currentMount = try? values.decode(String.self, forKey: .currentMount)
        let questsDict = try?values.decode([String: Int].self, forKey: .ownedQuests)
        ownedQuests = (questsDict?.map({ (key, numberOwned) -> OwnedItemProtocol in
            return APIOwnedItem(key: key, numberOwned: numberOwned, itemType: ItemType.quests.rawValue)
        })) ?? []
        let foodDict = try?values.decode([String: Int].self, forKey: .ownedFood)
        ownedFood = (foodDict?.map({ (key, numberOwned) -> OwnedItemProtocol in
            return APIOwnedItem(key: key, numberOwned: numberOwned, itemType: ItemType.food.rawValue)
        })) ?? []
        let hatchingPotionsDict = try?values.decode([String: Int].self, forKey: .ownedHatchingPotions)
        ownedHatchingPotions = (hatchingPotionsDict?.map({ (key, numberOwned) -> OwnedItemProtocol in
            return APIOwnedItem(key: key, numberOwned: numberOwned, itemType: ItemType.hatchingPotions.rawValue)
        })) ?? []
        let eggsDict = try?values.decode([String: Int].self, forKey: .ownedEggs)
        ownedEggs = (eggsDict?.map({ (key, numberOwned) -> OwnedItemProtocol in
            return APIOwnedItem(key: key, numberOwned: numberOwned, itemType: ItemType.eggs.rawValue)
        })) ?? []
        
        let petsDict = try?values.decode([String: Int].self, forKey: .ownedPets)
        ownedPets = (petsDict?.map({ (key, trained) -> OwnedPetProtocol in
            return APIOwnedPet(key: key, trained: trained)
        })) ?? []
        let mountsDict = try?values.decode([String: Bool].self, forKey: .ownedMounts)
        ownedMounts = (mountsDict?.map({ (key, owned) -> APIOwnedMount in
            return APIOwnedMount(key: key, owned: owned)
        })) ?? []
    }
}
