//
//  APITaskPreferences.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 29.08.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APITaskPreferences: TaskPreferencesProtocol, Decodable {
    var confirmScoreNotes: Bool = false
    var groupByChallenge: Bool = false
    var mirrorGroupTasks: [String]?
}
