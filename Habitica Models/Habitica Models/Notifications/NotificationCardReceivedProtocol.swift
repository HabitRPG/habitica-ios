//
//  NotificationCardReceivedProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 17.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol NotificationCardReceivedProtocol: NotificationProtocol {
    var cardKey: String? { get set }
    var cardSenderID: String? { get set }
    var cardSenderName: String? { get set }
}
