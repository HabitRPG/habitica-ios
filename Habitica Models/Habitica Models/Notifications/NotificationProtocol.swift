//
//  HabiticaNotification.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 23.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol NotificationProtocol {
    
    var id: String { get set }
    var type: HabiticaNotificationType { get set }
    var seen: Bool { get set }
}
