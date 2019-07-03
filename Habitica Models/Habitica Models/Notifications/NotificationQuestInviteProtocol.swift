//
//  NotificationQuestInviteProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 02.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol NotificationQuestInviteProtocol: NotificationProtocol {
    var questKey: String? { get set }
}
