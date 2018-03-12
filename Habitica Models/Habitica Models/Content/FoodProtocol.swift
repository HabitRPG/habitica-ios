//
//  FoodProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol FoodProtocol: ItemProtocol {
    var target: String? { get set }
    var canDrop: Bool { get set }
}
