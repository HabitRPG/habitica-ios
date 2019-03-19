//
//  APIPurchased.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 23.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIPurchased: PurchasedProtocol, Decodable {
    var hair: [OwnedCustomizationProtocol]
    var skin: [OwnedCustomizationProtocol]
    var shirt: [OwnedCustomizationProtocol]
    var background: [OwnedCustomizationProtocol]
    var subscriptionPlan: SubscriptionPlanProtocol?
    
    enum CodingKeys: String, CodingKey {
        case hair
        case skin
        case shirt
        case background
        case subscriptionPlan = "plan"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let hairDict = try?values.decode([String: [String: Bool]].self, forKey: .hair)
        hair = (hairDict?.map({ (hairGroup) -> [OwnedCustomizationProtocol] in
            return hairGroup.value.map({ (key, isOwned) -> OwnedCustomizationProtocol in
                return APIOwnedCustomization(key: key, type: "hair", group: hairGroup.key, isOwned: isOwned)
            })
        })).map({ (ownedHair) -> [OwnedCustomizationProtocol] in
            var ownedList = [OwnedCustomizationProtocol]()
            ownedHair.forEach({ (group) in
                ownedList.append(contentsOf: group)
            })
            return ownedList
        }) ?? []
        let skinDict = try?values.decode([String: Bool].self, forKey: .skin)
        skin = (skinDict?.map({ (skinItem) -> OwnedCustomizationProtocol in
            return APIOwnedCustomization(key: skinItem.key, type: "skin", group: nil, isOwned: skinItem.value)
        })) ?? []
        let shirtDict = try?values.decode([String: Bool].self, forKey: .shirt)
        shirt = (shirtDict?.map({ shirtItem -> OwnedCustomizationProtocol in
            return APIOwnedCustomization(key: shirtItem.key, type: "shirt", group: nil, isOwned: shirtItem.value)
        })) ?? []
        let backgroundDict = try?values.decode([String: Bool].self, forKey: .background)
        background = (backgroundDict?.map({ backgroundItem -> OwnedCustomizationProtocol in
            return APIOwnedCustomization(key: backgroundItem.key, type: "background", group: nil, isOwned: backgroundItem.value)
        })) ?? []
        
        subscriptionPlan = try? values.decode(APISubscriptionPlan.self, forKey: .subscriptionPlan)
    }
}
