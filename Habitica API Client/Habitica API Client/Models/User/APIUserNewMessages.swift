//
//  File.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIUserNewMessages: UserNewMessagesProtocol, Decodable {
    
    var id: String?
    var name: String?
    var hasNewMessages: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case name
        case hasNewMessages = "value"
    }
}
