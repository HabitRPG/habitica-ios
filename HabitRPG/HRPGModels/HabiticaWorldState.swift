//
//  HabiticaWorldState.swift
//  Habitica
//
//  Created by Phillip Thelen on 05.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

class HabiticaWorldState: NSObject {
    
    @objc public var worldBossActive: Bool = false
    @objc public var worldBossKey: String = ""
    @objc public var worldBossHealth: Int = 0
    @objc public var worldBossRage: Int = 0
}
