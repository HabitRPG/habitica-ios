//
//  APIUserItems.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIUserItems: UserItemsProtocol, Decodable {
    public var gear: UserGearProtocol?
    public var currentMount: String?
    public var currentPet: String?
    public var ownedQuests: [OwnedItemProtocol]
    public var ownedFood: [OwnedItemProtocol]
    public var ownedHatchingPotions: [OwnedItemProtocol]
    public var ownedEggs: [OwnedItemProtocol]
    public var ownedSpecialItems: [OwnedItemProtocol]
    
    public var ownedPets: [OwnedPetProtocol]
    public var ownedMounts: [OwnedMountProtocol]
    
    enum CodingKeys: String, CodingKey {
        case gear
        case currentMount
        case currentPet
        case ownedQuests = "quests"
        case ownedFood = "food"
        case ownedHatchingPotions = "hatchingPotions"
        case ownedEggs = "eggs"
        case ownedSpecialItems = "special"
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
        let specialDict = try? values.decode([String: Any].self, forKey: .ownedSpecialItems)
        ownedSpecialItems = (specialDict?.filter({ (_, value) -> Bool in
            return (value as? Int) != nil
        }).map({ (key, numberOwned) -> OwnedItemProtocol in
            return APIOwnedItem(key: key, numberOwned: numberOwned as? Int ?? 0, itemType: ItemType.special.rawValue)
        })) ?? []
        
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
