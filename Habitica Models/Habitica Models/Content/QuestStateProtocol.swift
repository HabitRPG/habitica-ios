//
//  QuestStateProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol QuestStateProtocol {
    var active: Bool { get set }
    var key: String? { get set }
    var rsvpNeeded: Bool { get set }
    var completed: String? { get set }
    var progress: QuestProgressProtocol? { get set }
}
