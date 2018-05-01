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
    @objc dynamic var id: String?
     @objc dynamic var userID: String?
     @objc dynamic var startDate: Date?
     @objc dynamic var time: Date?
    var task: TaskProtocol? {
        return realmTask.first
    }
    var realmTask = LinkingObjects(fromType: RealmTask.self, property: "realmReminders")
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(userID: String?, reminderProtocol: ReminderProtocol) {
        self.init()
        id = reminderProtocol.id
        self.userID = userID
        startDate = reminderProtocol.startDate
        time = reminderProtocol.time
    }
}
