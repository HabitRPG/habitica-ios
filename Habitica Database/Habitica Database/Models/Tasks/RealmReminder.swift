//
//  RealmReminder.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

class RealmReminder: Object, ReminderProtocol {
    var id: String?
    var startDate: Date?
    var time: Date?
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(_ reminderProtocol: ReminderProtocol) {
        self.init()
        id = reminderProtocol.id
        startDate = reminderProtocol.startDate
        time = reminderProtocol.time
    }
}
