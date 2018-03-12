//
//  APIQuestBoss.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIQuestBoss: QuestBossProtocol, Codable {
    var name: String?
    var hp: Int = 0
    var str: Float = 0
    var def: Float = 0
}
