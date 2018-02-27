//
//  HRPGTask.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/18/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

public class HRPGTask: NSObject, HRPGTaskProtocol {
    @objc public var text: String? = ""
    @objc public var notes: String? = ""
    @objc public var attribute: String? = ""
    @objc var challengeID = ""
    @objc public var completed: NSNumber? = false
    @objc var dateCreated: Date?
    @objc public var down: NSNumber? = false
    @objc var duedate: Date?
    @objc var everyX = 1
    @objc var frequency = ""
    @objc var friday = false
    @objc public var id: String? = ""
    @objc var monday = false
    @objc public var order: NSNumber? = 0
    @objc public var priority: NSNumber? = 1.0
    @objc var saturday = false
    @objc var startDate: Date?
    @objc var streak = 0
    @objc var sunday = false
    @objc var thursday = false
    @objc var tuesday = false
    @objc public var type: String? = ""
    @objc public var up: NSNumber? = false
    @objc public var value: NSNumber? = 0.0
    @objc var wednesday = false
    @objc var isDue = false
    @objc var yesterdaily = false
    @objc var counterUp = 0
    @objc var counterDown = 0
    @objc var nextDue: Date?
    @objc var currentlyChecking = false
    
    @objc var checklist = [HRPGChecklistItem]()
}
