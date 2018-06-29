//
//  APIBuff.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIBuff: BuffProtocol, Decodable {
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
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        strength = (try? values.decode(Int.self, forKey: .strength)) ?? 0
        intelligence = (try? values.decode(Int.self, forKey: .intelligence)) ?? 0
        constitution = (try? values.decode(Int.self, forKey: .constitution)) ?? 0
        perception = (try? values.decode(Int.self, forKey: .perception)) ?? 0
        stealth = (try? values.decode(Int.self, forKey: .stealth)) ?? 0
        streaks = (try? values.decode(Bool.self, forKey: .streaks)) ?? false
        shinySeed = (try? values.decode(Bool.self, forKey: .shinySeed)) ?? false
        seafoam = (try? values.decode(Bool.self, forKey: .seafoam)) ?? false
        snowball = (try? values.decode(Bool.self, forKey: .snowball)) ?? false
        spookySparkles = (try? values.decode(Bool.self, forKey: .spookySparkles)) ?? false
    }
}
