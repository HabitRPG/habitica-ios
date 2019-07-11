//
//  EquatableStringEnumProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 13.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol EquatableStringEnumProtocol {
    var rawValue: String { get }
}

public func == (lhs: String, rhs: EquatableStringEnumProtocol) -> Bool {
    return lhs == rhs.rawValue
}

public func == (lhs: String?, rhs: EquatableStringEnumProtocol) -> Bool {
    return lhs == rhs.rawValue
}

public func != (lhs: String, rhs: EquatableStringEnumProtocol) -> Bool {
    return lhs != rhs.rawValue
}

public func != (lhs: String?, rhs: EquatableStringEnumProtocol) -> Bool {
    return lhs != rhs.rawValue
}

public func == (lhs: EquatableStringEnumProtocol, rhs: String) -> Bool {
    return lhs.rawValue == rhs
}

public func == (lhs: EquatableStringEnumProtocol, rhs: String?) -> Bool {
    return lhs.rawValue == rhs
}

public func != (lhs: EquatableStringEnumProtocol, rhs: String) -> Bool {
    return lhs.rawValue != rhs
}

public func != (lhs: EquatableStringEnumProtocol, rhs: String?) -> Bool {
    return lhs.rawValue != rhs
}
