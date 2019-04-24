//
//  NotificationQuestInvitationProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 23.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol NotificationQuestInvitationProtocol: NotificationProtocol {
    var questID: String? { get set }
    var questName: String? { get set }
}
