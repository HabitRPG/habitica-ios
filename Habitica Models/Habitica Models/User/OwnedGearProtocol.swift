//
//  OwnedGearProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 12.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol OwnedGearProtocol {
    var key: String? { get set }
    var isOwned: Bool { get set }
}
