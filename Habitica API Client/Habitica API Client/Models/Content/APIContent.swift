//
//  APIContent.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

private struct APIGearWrapper: Decodable {
    var flat: [String: APIGear]?
}

private struct APIFAQWrapper: Decodable {
    var questions: [APIFAQEntry]?
}

private struct APIHairCustomizationWrapper: Decodable {
    var beard: [String: APICustomization]
    var bangs: [String: APICustomization]
    var mustache: [String: APICustomization]
    var base: [String: APICustomization]
    var color: [String: APICustomization]
    var flower: [String: APICustomization]
    
    func asList() -> [CustomizationProtocol] {
        var customizations = [CustomizationProtocol]()
        beard.forEach { (_, value) in
            value.type = "hair"
            value.group = "beard"
            customizations.append(value)
        }
        bangs.forEach { (_, value) in
            value.type = "hair"
            value.group = "bangs"
            customizations.append(value)
        }
        mustache.forEach { (_, value) in
            value.type = "hair"
            value.group = "mustache"
            customizations.append(value)
        }
        base.forEach { (_, value) in
            value.type = "hair"
            value.group = "base"
            customizations.append(value)
        }
        color.forEach { (_, value) in
            value.type = "hair"
            value.group = "color"
            customizations.append(value)
        }
        flower.forEach { (_, value) in
            value.type = "hair"
            value.group = "flower"
            customizations.append(value)
        }
        return customizations
    }
}

private struct APICustomizationsWrapper: Decodable {
    var hair: APIHairCustomizationWrapper?
    var shirt: [String: APICustomization]
    var chair: [String: APICustomization]
    var background: [String: APICustomization]
    var skin: [String: APICustomization]
    
    func asList() -> [CustomizationProtocol] {
        var customizations = hair?.asList() ?? []
        shirt.forEach { (_, value) in
            value.type = "shirt"
            customizations.append(value)
        }
        chair.forEach { (_, value) in
            value.type = "chair"
            customizations.append(value)
        }
        background.forEach { (_, value) in
            value.type = "background"
            customizations.append(value)
        }
        skin.forEach { (_, value) in
            value.type = "skin"
            customizations.append(value)
        }
        return customizations
    }
}

public class APIContent: ContentProtocol, Decodable {
    public var food: [FoodProtocol]?
    public var eggs: [EggProtocol]?
    public var special: [SpecialItemProtocol]?
    public var hatchingPotions: [HatchingPotionProtocol]?
    public var gear: [GearProtocol]?
    public var skills: [SkillProtocol]?
    public var quests: [QuestProtocol]?
    public var faq: [FAQEntryProtocol]?
    public var pets: [PetProtocol]?
    public var mounts: [MountProtocol]?
    public var customizations: [CustomizationProtocol]
    
    enum CodingKeys: String, CodingKey {
        case food
        case eggs
        case hatchingPotions
        case special
        case gear
        case skills = "spells"
        case quests
        case faq
        case pets = "petInfo"
        case mounts = "mountInfo"
        case customizations = "appearances"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        food = try? values.decode([String: APIFood].self, forKey: .food).map({ (_, value) in
            return value
        })
        eggs = try? values.decode([String: APIEgg].self, forKey: .eggs).map({ (_, value) in
            return value
        })
        hatchingPotions = try? values.decode([String: APIHatchingPotion].self, forKey: .hatchingPotions).map({ (_, value) in
            return value
        })
        special = try? values.decode([String: APISpecialItem].self, forKey: .special).map({ (_, value) in
            return value
        })
        let gearWrapper = try? values.decode(APIGearWrapper.self, forKey: .gear)
        gear = gearWrapper?.flat?.map({ (_, value) in
            return value
        })
        quests = try? values.decode([String: APIQuest].self, forKey: .quests).map({ (_, value) in
            return value
        })
        faq = try? values.decode(APIFAQWrapper.self, forKey: .faq).questions?.enumerated().map({ (index, entry) in
            entry.index = index
            return entry
        }) ?? []
        let parsedSkills = (try? values.decode([String: [String: APISkill]].self, forKey: .skills)) ?? [:]
        skills = []
        for skillSection in parsedSkills {
            for skill in skillSection.value {
                skill.value.habitClass = skillSection.key
                skills?.append(skill.value)
            }
        }
        self.pets = try? values.decode([String: APIPet].self, forKey: .pets).map({ (_, value) in
            return value
        })
        self.mounts = try? values.decode([String: APIMount].self, forKey: .mounts).map({ (_, value) in
            return value
        })
        let customizationsWrapper = try? values.decode(APICustomizationsWrapper.self, forKey: .customizations)
        customizations = customizationsWrapper?.asList() ?? []
    }
}
