//
//  ReminderProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol ReminderProtocol {
    var id: String? { get set }
    var startDate: Date? { get set }
    var time: Date? { get set }
    var task: TaskProtocol? { get }
}
