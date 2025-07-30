//
//  TaskResponseQuestProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 29.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol TaskResponseQuestProtocol {
    var progressDelta: Float { get set }
    var collection: Int? { get set }
}
