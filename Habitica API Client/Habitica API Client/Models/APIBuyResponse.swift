//
//  APIBuyResponse.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 04.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIBuyResponse: BuyResponseProtocol, Decodable {
    public var health: Float?
    public var experience: Float?
    public var mana: Float?
    public var level: Int?
    public var gold: Float?
    public var strength: Int?
    public var intelligence: Int?
    public var constitution: Int?
    public var perception: Int?
    public var buffs: BuffProtocol?
    public var items: UserItemsProtocol?
    public var attributePoints: Int?
    public var armoire: ArmoireResponseProtocol?
    
    enum CodingKeys: String, CodingKey {
        case health = "hp"
        case experience = "exp"
        case mana = "mp"
        case level = "lvl"
        case gold = "gp"
        case strength = "str"
        case intelligence = "int"
        case constitution = "con"
        case perception = "per"
        case buffs
        case items
        case attributePoints = "points"
        case armoire
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        health = try? values.decode(Float.self, forKey: .health)
        experience = try? values.decode(Float.self, forKey: .experience)
        mana = try? values.decode(Float.self, forKey: .mana)
        level = try? values.decode(Int.self, forKey: .level)
        gold = try? values.decode(Float.self, forKey: .gold)
        strength = try? values.decode(Int.self, forKey: .strength)
        intelligence = try? values.decode(Int.self, forKey: .intelligence)
        constitution = try? values.decode(Int.self, forKey: .constitution)
        perception = try? values.decode(Int.self, forKey: .perception)
        buffs = try? values.decode(APIBuff.self, forKey: .buffs)
        items = try? values.decode(APIUserItems.self, forKey: .items)
        attributePoints = try? values.decode(Int.self, forKey: .attributePoints)
        armoire = try? values.decode(APIArmoireResponse.self, forKey: .armoire)
    }
}
