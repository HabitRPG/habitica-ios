//
//  HRPGTask.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/18/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

public class HRPGTask: NSObject {
    var text = ""
    var notes = ""
    var attribute = ""
    var challengeID = ""
    var completed = false
    var dateCreated: Date?
    var down = false
    var duedate: Date?
    var everyX = 1
    var frequency = ""
    var friday = false
    var id = ""
    var monday = false
    var order = 0
    var priority: Float = 1.0
    var saturday = false
    var startDate: Date?
    var streak = 0
    var sunday = false
    var thursday = false
    var tuesday = false
    var type = ""
    var up = false
    var value = 0.0
    var wednesday = false
    var isDue = false
    var yesterdaily = false
    var counterUp = 0
    var counterDown = 0
    var nextDue: Date?
    var currentlyChecking = false
    
    var checklist = [HRPGChecklistItem]()
    
    public func taskColor() -> UIColor {
        if value < -20 {
            return UIColor.darkRed10()
        } else if value < -10 {
            return UIColor.red10()
        } else if value < -1 {
            return UIColor.orange10()
        } else if value < 1 {
            return UIColor.yellow10()
        } else if value < 5 {
            return UIColor.green10()
        } else if value < 10 {
            return UIColor.teal10()
        } else {
            return UIColor.blue10()
        }
    }
    
    public func lightTaskColor() -> UIColor {
        if value < -20 {
            return UIColor.darkRed100()
        } else if value < -10 {
            return UIColor.red100()
        } else if value < -1 {
            return UIColor.orange100()
        } else if value < 1 {
            return UIColor.yellow100()
        } else if value < 5 {
            return UIColor.green100()
        } else if value < 10 {
            return UIColor.teal100()
        } else {
            return UIColor.blue100()
        }
    }
}
