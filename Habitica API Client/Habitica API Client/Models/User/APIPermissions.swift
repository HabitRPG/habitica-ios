//
//  APIPermissions.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.12.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIPermissions: PermissionsProtocol, Codable {
    var isValid: Bool = true
    var isManaged: Bool = false
    
    var fullAccess: Bool = false
    var userSupport: Bool = false
    var moderator: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case fullAccess
        case userSupport
        case moderator
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fullAccess = (try? values.decode(Bool.self, forKey: .fullAccess)) ?? false
        userSupport = (try? values.decode(Bool.self, forKey: .userSupport)) ?? false
        moderator = (try? values.decode(Bool.self, forKey: .moderator)) ?? false
    }
}
