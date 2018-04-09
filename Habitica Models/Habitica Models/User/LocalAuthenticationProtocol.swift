//
//  LocalAuthenticationProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol LocalAuthenticationProtocol {
    var email: String? { get set }
    var username: String? { get set }
    var lowerCaseUsername: String? { get set }
}
