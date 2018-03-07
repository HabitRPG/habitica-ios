//
//  TaskResponse.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public struct TaskResponse: Codable {
    
    public var delta: Float?
    public var level: Int?
    public var gold: Float?
    public var experience: Float?
    public var health: Float?
    public var magic: Float?

    enum CodingKeys: String, CodingKey {
        case delta
        case level = "lvl"
        case gold = "gp"
        case experience = "exp"
        case health = "hp"
        case magic = "mp"
    }
}
