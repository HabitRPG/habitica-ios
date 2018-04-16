//
//  APIOwnedPet.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIOwnedPet: OwnedPetProtocol, Decodable {
    var key: String?
    var trained: Int
    
    init(key: String, trained: Int) {
        self.key = key
        self.trained = trained
    }
}
