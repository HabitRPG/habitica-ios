//
//  APIProfile.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIProfile: ProfileProtocol, Codable {
    var photoUrl: String?
    var name: String?
    var blurb: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case blurb
        case photoUrl = "imageUrl"
    }
}
