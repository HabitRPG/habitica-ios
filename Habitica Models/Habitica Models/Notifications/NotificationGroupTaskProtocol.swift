//
//  NotificationGroupTaskProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 13.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import Foundation

public protocol NotificationGroupTaskProtocol: NotificationProtocol {
    var groupID: String? { get set }
}
