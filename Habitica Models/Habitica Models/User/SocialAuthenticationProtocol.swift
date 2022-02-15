//
//  SocialAuthenticationProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 23.11.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol SocialAuthenticationProtocol {
    var emails: [String] { get set }
    var id: String? { get set }
}
