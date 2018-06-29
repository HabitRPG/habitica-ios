//
//  TaskResponse.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public struct TaskResponse: TaskResponseProtocol, Decodable {
    public var delta: Float?
    public var level: Int?
    public var gold: Float?
    public var experience: Float?
    public var health: Float?
    public var magic: Float?
    public var temp: TaskResponseTempProtocol?
    
    enum CodingKeys: String, CodingKey {
        case delta
        case level = "lvl"
        case gold = "gp"
        case experience = "exp"
        case health = "hp"
        case magic = "mp"
        case temp = "_tmp"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        delta = try? values.decode(Float.self, forKey: .delta)
        level = try? values.decode(Int.self, forKey: .level)
        gold = try? values.decode(Float.self, forKey: .gold)
        experience = try? values.decode(Float.self, forKey: .experience)
        health = try? values.decode(Float.self, forKey: .health)
        magic = try? values.decode(Float.self, forKey: .magic)
        temp = try? values.decode(APITaskResponseTemp.self, forKey: .temp)
    }
}
