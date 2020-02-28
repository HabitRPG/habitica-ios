//
//  APIAuthentication.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class SocialAuth: Decodable {
    var id: String?
}

class APIAuthentication: AuthenticationProtocol, Decodable {
    var timestamps: AuthenticationTimestampsProtocol?
    var local: LocalAuthenticationProtocol?
    var facebookID: String?
    var googleID: String?
    var appleID: String?
    
    enum CodingKeys: String, CodingKey {
        case timestamps
        case local
        case facebook
        case google
        case apple
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        timestamps = try? values.decode(APIAuthenticationTimestamps.self, forKey: .timestamps)
        local = try? values.decode(APILocalAuthentication.self, forKey: .local)
        facebookID = (try? values.decode(SocialAuth.self, forKey: .facebook))?.id
        googleID = (try? values.decode(SocialAuth.self, forKey: .google))?.id
        appleID = (try? values.decode(SocialAuth.self, forKey: .apple))?.id
    }
}
