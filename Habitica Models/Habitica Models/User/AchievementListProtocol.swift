//
//  AchievementListProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 11.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol AchievementListProtocol {
    var achievements: [AchievementProtocol] { get set }
}
