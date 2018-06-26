//
//  BuffProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol BuffProtocol: BaseStatsProtocol {
    var shinySeed: Bool { get set }
    var snowball: Bool { get set }
    var seafoam: Bool { get set }
    var streaks: Bool { get set }
    var stealth: Int { get set }
    var spookySparkles: Bool { get set }
}
