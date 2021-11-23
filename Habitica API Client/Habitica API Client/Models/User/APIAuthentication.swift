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
    var emails: [[String: String]]?
    var id: String?
    
    func toSocialAuthenticationObject() -> SocialAuthenticationProtocol {
        let object  = APISocialAuthentication()
        object.id = id
        emails?.forEach({ email in
            if let emailValue = email["value"] {
                object.emails.append(emailValue)
            }
        })
        return object
    }
}

class APIAuthentication: AuthenticationProtocol, Decodable {
    var timestamps: AuthenticationTimestampsProtocol?
    var local: LocalAuthenticationProtocol?
    var facebook: SocialAuthenticationProtocol?
    var google: SocialAuthenticationProtocol?
    var apple: SocialAuthenticationProtocol?
    
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
        facebook = (try? values.decode(SocialAuth.self, forKey: .facebook))?.toSocialAuthenticationObject()
        google = (try? values.decode(SocialAuth.self, forKey: .google))?.toSocialAuthenticationObject()
        apple = (try? values.decode(SocialAuth.self, forKey: .apple))?.toSocialAuthenticationObject()
    }
}
