//
//  APICustomizationSet.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APICustomizationSet: CustomizationSetProtocol, Decodable {
    var key: String?
    var text: String?
    var availableFrom: Date?
    var availableUntil: Date?
    var setPrice: Float = 0
}
