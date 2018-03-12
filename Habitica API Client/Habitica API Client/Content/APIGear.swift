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
    var habitClass: String?
    var index: String?
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
        case habitClass = "klass"
        case index
        case strength = "str"
        case intelligence = "int"
        case perception = "per"
        case constitution = "con"
    }
}
