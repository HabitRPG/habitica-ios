//
//  SkillProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol SkillProtocol {
    var key: String? { get set }
    var text: String? { get set }
    var notes: String? { get set }
    var mana: Int { get set }
    var level: Int { get set }
    var target: String? { get set }
    var habitClass: String? { get set }
    var value: Float { get set }
    var immediateUse: Bool { get set }
    var silent: Bool { get set }
}
