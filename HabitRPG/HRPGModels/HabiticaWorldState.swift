//
//  HabiticaWorldState.swift
//  Habitica
//
//  Created by Phillip Thelen on 05.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

class HabiticaWorldState: NSObject {
    
    public var worldBossActive: Bool = false
    public var worldBossKey: String?
    public var worldBossHealth: Int?
    public var worldBossRage: Int?
}
