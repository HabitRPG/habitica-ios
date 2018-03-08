//
//  TaskResponse.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol TaskResponseProtocol {
    var delta: Float? { get set }
    var level: Int? { get set }
    var gold: Float? { get set }
    var experience: Float? { get set }
    var health: Float? { get set }
    var magic: Float? { get set }
}
