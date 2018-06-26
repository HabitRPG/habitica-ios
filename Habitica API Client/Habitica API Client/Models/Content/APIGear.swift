//
//  APIGear.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIGear: GearProtocol, Codable {
    var key: String?
    var text: String?
    var notes: String?
    var value: Float = 0
    var type: String?
    var set: String?
    var gearSet: String?
    var habitClass: String?
    var specialClass: String?
    var index: String?
    var twoHanded: Bool = false
    var strength: Int = 0
    var intelligence: Int = 0
    var perception: Int = 0
    var constitution: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case key
        case text
        case notes
        case value
        case type
        case set
        case gearSet
        case habitClass = "klass"
        case specialClass
        case index
        case twoHanded
        case strength = "str"
        case intelligence = "int"
        case perception = "per"
        case constitution = "con"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try? values.decode(String.self, forKey: .key)
        text = try? values.decode(String.self, forKey: .text)
        notes = try? values.decode(String.self, forKey: .notes)
        value = (try? values.decode(Float.self, forKey: .value)) ?? 0
        type = try? values.decode(String.self, forKey: .type)
        set = try? values.decode(String.self, forKey: .set)
        gearSet = try? values.decode(String.self, forKey: .gearSet)
        habitClass = try? values.decode(String.self, forKey: .habitClass)
        specialClass = try? values.decode(String.self, forKey: .specialClass)
        index = try? values.decode(String.self, forKey: .index)
        twoHanded = (try? values.decode(Bool.self, forKey: .twoHanded)) ?? false
        strength = (try? values.decode(Int.self, forKey: .strength)) ?? 0
        intelligence = (try? values.decode(Int.self, forKey: .intelligence)) ?? 0
        constitution = (try? values.decode(Int.self, forKey: .constitution)) ?? 0
        perception = (try? values.decode(Int.self, forKey: .perception)) ?? 0
    }
}
