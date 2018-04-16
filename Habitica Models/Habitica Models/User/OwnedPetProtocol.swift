//
//  OwnedPetProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol OwnedPetProtocol {
    var key: String? { get set }
    var trained: Int { get set }
}
