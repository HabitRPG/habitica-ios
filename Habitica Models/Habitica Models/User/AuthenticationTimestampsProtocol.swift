//
//  AuthenticationTimestampsProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol AuthenticationTimestampsProtocol {
    var createdAt: Date? { get set }
    var loggedIn: Date? { get set }
}
