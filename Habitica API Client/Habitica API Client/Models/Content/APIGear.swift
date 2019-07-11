//
//  APIGear.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIGear: GearProtocol, Codable {
    public var key: String?
    public var text: String?
    public var notes: String?
    public var value: Float = 0
    public var type: String?
    public var set: String?
    public var gearSet: String?
    public var habitClass: String?
    public var specialClass: String?
    public var index: String?
    public var twoHanded: Bool = false
    public var strength: Int = 0
    public var intelligence: Int = 0
    public var perception: Int = 0
    public var constitution: Int = 0
    
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
