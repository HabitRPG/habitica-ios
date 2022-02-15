//
//  APISocialAuthentication.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 23.11.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APISocialAuthentication: SocialAuthenticationProtocol, Decodable {
    var emails: [String] = []
    var id: String?
}
