//
//  SkillResponseProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 29.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol SkillResponseProtocol {
    var user: UserProtocol? { get set }
    var task: TaskProtocol? { get set }
}
