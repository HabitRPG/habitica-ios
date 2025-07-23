//
//  APIVerifyUsernameResponse.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.10.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APICheckEmailResponse: Decodable, CheckEmailResponse {
    public var email: String?
    public var valid: Bool = false
    public var error: String?
}
