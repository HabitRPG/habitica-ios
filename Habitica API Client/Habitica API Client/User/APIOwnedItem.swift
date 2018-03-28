//
//  APIOwnedItem.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 28.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIOwnedItem: OwnedItemProtocol, Codable {
    
    var key: String?
    var numberOwned: Int = 0
    
    init(key: String, numberOwned: Int) {
        self.key = key
        self.numberOwned = numberOwned
    }
}
