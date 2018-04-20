//
//  APIHair.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIHair: HairProtocol, Decodable {
    var color: String?
    var bangs: Int = 0
    var base: Int = 0
    var beard: Int = 0
    var mustache: Int = 0
    var flower: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case color
        case bangs
        case base
        case beard
        case mustache
        case flower
    }
}
