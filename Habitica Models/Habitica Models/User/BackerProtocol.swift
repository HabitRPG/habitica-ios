//
//  BackerProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 11.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol BackerProtocol {
    var tier: Int { get set }
    var npc: String? { get set }
}
