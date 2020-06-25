//
//  NotificationFirstDropProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 25.06.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol NotificationFirstDropProtocol: NotificationProtocol {
    var egg: String? { get set }
    var potion: String? { get set }
}
