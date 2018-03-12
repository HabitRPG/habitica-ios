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
    var hp: Int { get set }
    var str: Float { get set }
    var def: Float { get set }
}
