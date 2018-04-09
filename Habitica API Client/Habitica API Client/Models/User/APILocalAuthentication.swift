//
//  APILocalAuthentication.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APILocalAuthentication: LocalAuthenticationProtocol, Decodable {
    var email: String?
    var username: String?
    var lowerCaseUsername: String?
}
