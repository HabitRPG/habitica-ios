//
//  NotificationGroupInviteProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 02.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol NotificationGroupInviteProtocol: NotificationProtocol {
    var groupID: String? { get set }
    var groupName: String? { get set }
    var inviterID: String? { get set }
    var isParty: Bool { get set }
    var isPublicGuild: Bool { get set }
}
