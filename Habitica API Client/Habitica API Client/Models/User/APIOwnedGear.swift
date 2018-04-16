//
//  APIOwnedGear.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIOwnedGear: OwnedGearProtocol, Codable {
    
    var key: String?
    var isOwned: Bool
    
    init(key: String, isOwned: Bool) {
        self.key = key
        self.isOwned = isOwned
    }
}
