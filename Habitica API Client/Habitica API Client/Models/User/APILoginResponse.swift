//
//  File.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APILoginResponse: LoginResponseProtocol, Decodable {
    public var id: String = ""
    public var apiToken: String = ""
    public var newUser: Bool = false
}
