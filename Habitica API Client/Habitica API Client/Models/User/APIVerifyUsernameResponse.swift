//
//  APIVerifyUsernameResponse.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.10.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIVerifyUsernameResponse: Decodable, VerifyUsernameResponse {
    var isUsable: Bool = false
    var issues: [String]? = []
}
