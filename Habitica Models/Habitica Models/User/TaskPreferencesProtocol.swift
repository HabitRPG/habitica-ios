//
//  TaskPreferencesProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 29.08.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol TaskPreferencesProtocol {
    var confirmScoreNotes: Bool { get set }
    var groupByChallenge: Bool { get set }
    var mirrorGroupTasks: [String]? { get set }
}
