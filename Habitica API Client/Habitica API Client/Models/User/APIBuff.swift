//
//  APIBuff.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIBuff: BuffProtocol, Codable {
    var shinySeed: Bool = false
    var snowball: Bool = false
    var seafoam: Bool = false
    var streaks: Bool = false
    var stealth: Int = 0
    var spookySparkles: Bool = false
    var strength: Int = 0
    var intelligence: Int = 0
    var constitution: Int = 0
    var perception: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case strength = "str"
        case intelligence = "int"
        case constitution = "con"
        case perception = "per"
        case shinySeed
        case snowball
        case seafoam
        case spookySparkles
        case streaks
        case stealth
    }
}
