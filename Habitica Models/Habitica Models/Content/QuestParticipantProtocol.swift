//
//  QuestParticipantProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 03.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol QuestParticipantProtocol {
    var userID: String? { get set }
    var groupID: String? { get set }
    var accepted: Bool { get set }
    var responded: Bool { get set }
}
