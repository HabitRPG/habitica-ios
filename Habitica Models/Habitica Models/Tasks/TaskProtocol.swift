//
//  TaskProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

protocol TaskProtocol {
    var id: String
    var text: String
    var notes: String
    var type: String
    var value: Float
    var attribute: String
    var completed: Bool
    var down: Bool
    var up: Bool
    var order: Int
    var priority: Float
}
