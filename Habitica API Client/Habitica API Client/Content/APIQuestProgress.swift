//
//  File.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIQuestProgress: QuestProgressProtocol, Codable {
    var health: Float = 0
    var rage: Float = 0
}
