//
//  RealmTaskHistory.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 24.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmTaskHistory: Object, TaskHistoryProtocol {
    @objc dynamic var combinedID: String?
    @objc dynamic var taskID: String?
    @objc dynamic var timestamp: Date?
    @objc dynamic var value: Float = 0
    @objc dynamic var scoredUp: Bool = false
    @objc dynamic var scoredDown: Bool = false
    
    var isValid: Bool {
        return !isInvalidated
    }
    
    override static func primaryKey() -> String {
        return "combinedID"
    }
    
    convenience init(taskID: String, historyProtocol: TaskHistoryProtocol) {
        self.init()
        combinedID = taskID + String(historyProtocol.timestamp?.timeIntervalSince1970 ?? 0)
        self.taskID = taskID
        timestamp = historyProtocol.timestamp
        value = historyProtocol.value
        scoredUp = historyProtocol.scoredUp
        scoredDown = historyProtocol.scoredDown
    }
}
