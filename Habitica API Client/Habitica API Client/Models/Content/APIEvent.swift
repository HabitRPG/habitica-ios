//
//  APIEvent.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 29.03.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation

class APIEvent: Decodable {
    var start: Date?
    var end: Date?
    
    enum CodingKeys: String, CodingKey {
        case start
        case end
    }
}
