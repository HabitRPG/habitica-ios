//
//  APISkill.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APISkill: SkillProtocol, Codable {
    var key: String?
    var text: String?
    var notes: String?
    var mana: Int = 0
    var level: Int = 0
    var target: String?
    var habitClass: String?
    var value: Float = 0
    var immediateUse: Bool = false
    var silent: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case key
        case text
        case notes
        case mana
        case level = "lvl"
        case target
        case value
        case immediateUse
        case silent
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try? values.decode(String.self, forKey: .key)
        text = try? values.decode(String.self, forKey: .text)
        notes = try? values.decode(String.self, forKey: .notes)
        mana = (try? values.decode(Int.self, forKey: .mana)) ?? 0
        level = (try? values.decode(Int.self, forKey: .level)) ?? 0
        target = try? values.decode(String.self, forKey: .target)
        value = (try? values.decode(Float.self, forKey: .value)) ?? 0
        immediateUse = (try? values.decode(Bool.self, forKey: .immediateUse)) ?? false
        silent = (try? values.decode(Bool.self, forKey: .silent)) ?? false
    }
}
