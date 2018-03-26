//
//  APIWeekRepeat.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 26.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIWeekRepeat: WeekRepeatProtocol, Codable {
    var monday: Bool = true
    var tuesday: Bool = true
    var wednesday: Bool = true
    var thursday: Bool = true
    var friday: Bool = true
    var saturday: Bool = true
    var sunday: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case monday = "m"
        case tuesday = "t"
        case wednesday = "w"
        case thursday = "th"
        case friday = "f"
        case saturday = "s"
        case sunday = "su"
    }
}
