//
//  PermissionsProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 12.12.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation

public enum Permissions {
    case userSupport
    case moderator
}

@objc
public protocol PermissionsProtocol: BaseModelProtocol {
    var fullAccess: Bool { get set}
    
    var moderator: Bool { get set }
    var userSupport: Bool { get set }
}
