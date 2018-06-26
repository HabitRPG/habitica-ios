//
//  AuthenticationProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol AuthenticationProtocol {
    var timestamps: AuthenticationTimestampsProtocol? { get set }
    var local: LocalAuthenticationProtocol? { get set }
}
