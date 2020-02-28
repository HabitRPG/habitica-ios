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
    var facebookID: String? { get set }
    var googleID: String? { get set }
    var appleID: String? { get set }
    
}

public extension AuthenticationProtocol {
    var hasLocalAuth: Bool {
        return local?.email != nil
    }
}
