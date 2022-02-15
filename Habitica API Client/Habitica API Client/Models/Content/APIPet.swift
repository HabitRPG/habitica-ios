//
//  APIPet.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIPet: PetProtocol, Decodable {
    var key: String?
    var egg: String?
    var potion: String?
    var type: String?
    var text: String?
    var isValid: Bool = true
    public var isManaged: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case key
        case egg
        case potion
        case type
        case text
    }
}
