//
//  EggProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol EggProtocol: ItemProtocol {
    var adjective: String? { get set }
}
