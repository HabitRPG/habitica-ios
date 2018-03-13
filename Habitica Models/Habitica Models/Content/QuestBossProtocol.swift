//
//  File.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol QuestBossProtocol {
    var name: String? { get set }
    var health: Int { get set }
    var strength: Float { get set }
    var defense: Float { get set }
}
