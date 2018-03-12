//
//  APIHatchingPotion.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIHatchingPotion: APIItem, HatchingPotionProtocol {
    var premium: Bool = false
    var limited: Bool = false
}
