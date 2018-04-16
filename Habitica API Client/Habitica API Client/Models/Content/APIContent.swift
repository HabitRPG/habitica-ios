//
//  APIContent.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

private class APIGearWrapper: Decodable {
    var flat: [String: APIGear]?
}

private class APIFAQWrapper: Decodable {
    var questions: [APIFAQEntry]?
}

public class APIContent: ContentProtocol, Decodable {
    public var food: [FoodProtocol]?
    public var eggs: [EggProtocol]?
    public var hatchingPotions: [HatchingPotionProtocol]?
    public var gear: [GearProtocol]?
    public var skills: [SkillProtocol]?
    public var quests: [QuestProtocol]?
    public var faq: [FAQEntryProtocol]?
    public var pets: [PetProtocol]?
    public var mounts: [MountProtocol]?
    
    enum CodingKeys: String, CodingKey {
        case food
        case eggs
        case hatchingPotions
        case gear
        case skills = "spells"
        case quests
        case faq
        case pets = "petInfo"
        case mounts = "mountInfo"
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
        let parsedSkills = (try? values.decode([String: [String: APISkill]].self, forKey: .skills)) ?? [:]
        skills = []
        for skillSection in parsedSkills {
            for skill in skillSection.value {
                skill.value.habitClass = skillSection.key
                skills?.append(skill.value)
            }
        }
        self.pets = try? values.decode([String: APIPet].self, forKey: .pets).map({ (key, value) in
            return value
        })
        self.mounts = try? values.decode([String: APIMount].self, forKey: .mounts).map({ (key, value) in
            return value
        })
    }
}
