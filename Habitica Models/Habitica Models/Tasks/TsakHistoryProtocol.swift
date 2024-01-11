//
//  TsakHistoryProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 24.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol TaskHistoryProtocol: BaseModelProtocol {
    var taskID: String? { get set }
    var timestamp: Date? { get set }
    var value: Float { get set }
    var scoredUp: Int { get set }
    var scoredDown: Int { get set }
    var isDue: Bool { get set }
    var completed: Bool { get set }
}
