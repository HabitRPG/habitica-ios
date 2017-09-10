//
//  Task.swift
//  Habitica
//
//  Created by Phillip on 10.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Task: Object {

    dynamic var text = ""
    dynamic var notes = ""
    dynamic var attribute = ""
    dynamic var challengeID = ""
    dynamic var completed = false
    dynamic var dateCreated: Date?
    dynamic var down = false
    dynamic var duedate: Date?
    dynamic var everyX = 1
    dynamic var frequency = ""
    dynamic var friday = false
    dynamic var id = ""
    dynamic var monday = false
    dynamic var order = 0
    dynamic var priority: Float = 1.0
    dynamic var saturday = false
    dynamic var startDate: Date?
    dynamic var streak = 0
    dynamic var sunday = false
    dynamic var thursday = false
    dynamic var tuesday = false
    dynamic var type = ""
    dynamic var up = false
    dynamic var value = 0.0
    dynamic var wednesday = false
    dynamic var isDue = false
    dynamic var yesterdaily = false
    dynamic var counterUp = 0
    dynamic var counterDown = 0
    dynamic var nextDue: Date?
    dynamic var currentlyChecking = false
    
    convenience init(json: JSON) {
        self.init()
        id = json["id"].stringValue
        text = json["text"].stringValue
        notes = json["notes"].stringValue
        type = json["type"].stringValue
        completed = json["completed"].boolValue
        attribute = json["attribute"].string ?? ""
        challengeID = json["challenge"]["id"].string ?? ""
        //dateCreated = json["dateCreated"].date
        down = json["down"].bool ?? false
        everyX = json["everyX"].int ?? 0
        frequency = json["frequency"].string ?? ""
        monday = json["repeat.m"].bool ?? false
        tuesday = json["repeat.t"].bool ?? false
        wednesday = json["repeat.w"].bool ?? false
        thursday = json["repeat.th"].bool ?? false
        friday = json["repeat.f"].bool ?? false
        saturday = json["repeat.s"].bool ?? false
        sunday = json["repeat.su"].bool ?? false
        priority = json["priority"].floatValue
        streak = json["streak"].int ?? 0
        up = json["up"].bool ?? false
        value = json["value"].doubleValue
        isDue = json["isDue"].bool ?? false
        yesterdaily = json["yesterdaily"].bool ?? false
        counterUp = json["counterUp"].int ?? 0
        counterDown = json["counterDown"].int ?? 0
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
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
