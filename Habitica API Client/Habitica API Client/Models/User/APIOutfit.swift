//
//  APIOutfit.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIOutfit: OutfitProtocol, Codable {
    var back: String?
    var body: String?
    var armor: String?
    var eyewear: String?
    var headAccessory: String?
    var head: String?
    var weapon: String?
    var shield: String?
}
