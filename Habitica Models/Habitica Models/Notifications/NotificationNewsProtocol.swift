//
//  HabiticaNotificationNewsProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 23.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol NotificationNewsProtocol: NotificationProtocol {
    var title: String? { get set }
}
