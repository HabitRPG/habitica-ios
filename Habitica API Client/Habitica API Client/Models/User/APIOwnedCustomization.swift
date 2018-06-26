//
//  APIOwnedCustomization.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 23.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIOwnedCustomization: OwnedCustomizationProtocol, Decodable {
    var key: String?
    var type: String?
    var group: String?
    var isOwned: Bool
    
    init(key: String, type: String, group: String?, isOwned: Bool) {
        self.key = key
        self.type = type
        self.group = group
        self.isOwned = isOwned
    }
}
