//
//  APIAuthentication.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIAuthentication: AuthenticationProtocol, Decodable {
    var timestamps: AuthenticationTimestampsProtocol?
    var local: LocalAuthenticationProtocol?
    
    enum CodingKeys: String, CodingKey {
        case timestamps
        case local
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        timestamps = try? values.decode(APIAuthenticationTimestamps.self, forKey: .timestamps)
        local = try? values.decode(APILocalAuthentication.self, forKey: .local)
    }
}
