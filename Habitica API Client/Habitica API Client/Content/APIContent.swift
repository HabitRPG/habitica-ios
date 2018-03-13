//
//  APIContent.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

private class APIGearWrapper: Codable {
    var flat: [String: APIGear]?
}

private class APIFAQWrapper: Codable {
    var questions: [APIFAQEntry]?
}

public class APIContent: ContentProtocol, Codable {
    public var food: [FoodProtocol]?
    public var eggs: [EggProtocol]?
    public var hatchingPotions: [HatchingPotionProtocol]?
    public var gear: [GearProtocol]?
    public var spells: [SpellProtocol]?
    public var quests: [QuestProtocol]?
    public var faq: [FAQEntryProtocol]?
    
    enum CodingKeys: String, CodingKey {
        case food
        case eggs
        case hatchingPotions
        case gear
        case spells
        case quests
        case faq
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        food = try? values.decode([String: APIFood].self, forKey: .food).map({ (key, value) in
            return value
        })
        eggs = try? values.decode([String: APIEgg].self, forKey: .eggs).map({ (key, value) in
            return value
        })
        hatchingPotions = try? values.decode([String: APIHatchingPotion].self, forKey: .hatchingPotions).map({ (key, value) in
            return value
        })
        let gearWrapper = try! values.decode(APIGearWrapper.self, forKey: .gear)
        gear = gearWrapper.flat?.map({ (key, value) in
            return value
        })
        quests = try! values.decode([String: APIQuest].self, forKey: .quests).map({ (key, value) in
            return value
        })
        faq = try! values.decode(APIFAQWrapper.self, forKey: .faq).questions?.enumerated().map({ (index, entry) in
            entry.index = index
            return entry
        })
        let parsedSpells = (try? values.decode([String: [String: APISpell]].self, forKey: .spells)) ?? [:]
        spells = []
        for spellSection in parsedSpells {
            for spell in spellSection.value {
                spell.value.habitClass = spellSection.key
                spells?.append(spell.value)
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
