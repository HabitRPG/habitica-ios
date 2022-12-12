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
    var facebook: SocialAuthenticationProtocol? { get set }
    var google: SocialAuthenticationProtocol? { get set }
    var apple: SocialAuthenticationProtocol? { get set }
    
    var blocked: Bool { get set }
}

public extension AuthenticationProtocol {
    var hasLocalAuth: Bool {
        return local?.hasPassword == true
    }
    
    var hasAppleAuth: Bool {
        return apple?.id != nil || apple?.emails.isEmpty == false
    }
    var hasGoogleAuth: Bool {
        return google?.id != nil || google?.emails.isEmpty == false
    }
    var hasFacebookAuth: Bool {
        return facebook?.id != nil || facebook?.emails.isEmpty == false
    }
}
