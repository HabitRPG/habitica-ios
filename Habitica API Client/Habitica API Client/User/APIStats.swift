//
//  APIStats.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIStats: StatsProtocol, Codable {
    public var health: Float = 0
    public var maxHealth: Float = 50
    public var mana: Float = 0
    public var maxMana: Float = 0
    public var experience: Float = 0
    public var toNextLevel: Float = 0
    public var level: Int = 0
    public var strength: Int = 0
    public var intelligence: Int = 0
    public var constitution: Int = 0
    public var perception: Int = 0
    public var points: Int = 0
    public var habitClass: String?
    public var gold: Float = 0
    public var buffs: BuffProtocol?
    
    enum CodingKeys: String, CodingKey {
        case health = "hp"
        case maxHealth = "maxHealth"
        case mana = "mp"
        case maxMana = "maxMP"
        case experience = "exp"
        case toNextLevel
        case level = "lvl"
        case strength = "str"
        case intelligence = "int"
        case constitution = "con"
        case perception = "per"
        case points
        case habitClass = "class"
        case gold = "gp"
        case buffs
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        health = (try? values.decode(Float.self, forKey: .health)) ?? 0
        maxHealth = (try? values.decode(Float.self, forKey: .maxHealth)) ?? 0
        mana = (try? values.decode(Float.self, forKey: .mana)) ?? 0
        maxMana = (try? values.decode(Float.self, forKey: .maxMana)) ?? 0
        experience = (try? values.decode(Float.self, forKey: .experience)) ?? 0
        toNextLevel = (try? values.decode(Float.self, forKey: .toNextLevel)) ?? 0
        level = (try? values.decode(Int.self, forKey: .level)) ?? 0
        strength = (try? values.decode(Int.self, forKey: .strength)) ?? 0
        intelligence = (try? values.decode(Int.self, forKey: .intelligence)) ?? 0
        constitution = (try? values.decode(Int.self, forKey: .constitution)) ?? 0
        perception = (try? values.decode(Int.self, forKey: .perception)) ?? 0
        points = (try? values.decode(Int.self, forKey: .points)) ?? 0
        habitClass = try? values.decode(String.self, forKey: .habitClass)
        gold = (try? values.decode(Float.self, forKey: .gold)) ?? 0
        buffs = try? values.decode(APIBuff.self, forKey: .buffs)
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
