//
//  APIFood.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIFood: FoodProtocol, Codable {
    var key: String?
    var text: String?
    var notes: String?
    var value: Float = 0
    var target: String?
    var canDrop: Bool = false
    var itemType: String?
}
