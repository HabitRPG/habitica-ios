//
//  APIQuestBossRage.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIQuestBossRage: QuestBossRageProtocol, Decodable {
    var title: String?
    var rageDescription: String?
    var value: Int = 0
}
