//
//  GearSetProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 24.10.24.
//  Copyright © 2024 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol GearSetProtocol {
    var key: String? { get set }
    var text: String? { get set }
    var start: Date? { get set }
    var end: Date? { get set }
}
