//
//  RealmTask.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

class RealmTask: Object, TaskProtocol {
    @objc dynamic var id: String?
    @objc dynamic var text: String?
    @objc dynamic var notes: String?
    @objc dynamic var type: String?
    @objc dynamic var value: Float = 0
    @objc dynamic var attribute: String?
    @objc dynamic var completed: Bool = false
    @objc dynamic var down: Bool = false
    @objc dynamic var up: Bool = false
    @objc dynamic var order: Int = 0
    @objc dynamic var priority: Float = 0
    @objc dynamic var counterUp: Int = 0
    @objc dynamic var counterDown: Int = 0
    @objc dynamic var duedate: Date?
    @objc dynamic var isDue: Bool = false
    @objc dynamic var streak: Int = 0
    @objc dynamic var frequency: String?
    @objc dynamic var everyX: Int = 1
    @objc dynamic var challengeID: String?
    @objc dynamic var createdAt: Date?
    @objc dynamic var updatedAt: Date?
    @objc dynamic var startDate: Date?
    @objc dynamic var yesterDaily: Bool = true
    var tags: [TagProtocol] {
        get {
            return realmTags.map({ (tag) -> TagProtocol in
                return tag
            })
        }
        set {
            realmTags.removeAll()
            newValue.forEach { (tag) in
                if let realmTag = tag as? RealmTag {
                    realmTags.append(realmTag)
                } else {
                    realmTags.append(RealmTag(tag))
                }
            }
        }
    }
    var realmTags = List<RealmTag>()
    var checklist: [ChecklistItemProtocol] {
        get {
            return realmChecklist.map({ (tag) -> ChecklistItemProtocol in
                return tag
            })
        }
        set {
            realmChecklist.removeAll()
            newValue.forEach { (checklistItem) in
                if let realmChecklistItem = checklistItem as? RealmChecklistItem {
                    realmChecklist.append(realmChecklistItem)
                } else {
                    realmChecklist.append(RealmChecklistItem(checklistItem))
                }
            }
        }
    }
    var realmChecklist = List<RealmChecklistItem>()
    var reminders: [ReminderProtocol] {
        get {
            return realmReminders.map({ (tag) -> ReminderProtocol in
                return tag
            })
        }
        set {
            realmReminders.removeAll()
            newValue.forEach { (reminder) in
                if let realmReminder = reminder as? RealmReminder {
                    realmReminders.append(realmReminder)
                } else {
                    realmReminders.append(RealmReminder(reminder))
                }
            }
        }
    }
    var realmReminders = List<RealmReminder>()
    var weekRepeat: WeekRepeatProtocol? {
        get {
            return realmWeekRepeat
        }
        set {
            if let newRepeat = newValue as? RealmWeekRepeat {
                realmWeekRepeat = newRepeat
                return
            }
            if let newRepeat = newValue, let id = self.id {
                realmWeekRepeat = RealmWeekRepeat(id: id, weekRepeat: newRepeat)
            }
        }
    }
    @objc dynamic var realmWeekRepeat: RealmWeekRepeat? = RealmWeekRepeat()
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["tags", "checklist", "reminders"]
    }
    
    convenience init(_ taskProtocol: TaskProtocol, tags: Results<RealmTag>?) {
        self.init()
        id = taskProtocol.id
        text = taskProtocol.text
        notes = taskProtocol.notes
        type = taskProtocol.type
        value = taskProtocol.value
        attribute = taskProtocol.attribute
        completed = taskProtocol.completed
        down = taskProtocol.down
        up = taskProtocol.up
        order = taskProtocol.order
        priority = taskProtocol.priority
        counterUp = taskProtocol.counterUp
        counterDown = taskProtocol.counterDown
        duedate = taskProtocol.duedate
        isDue = taskProtocol.isDue
        streak = taskProtocol.streak
        frequency = taskProtocol.frequency
        everyX = taskProtocol.everyX
        challengeID = taskProtocol.challengeID
        startDate = taskProtocol.startDate
        createdAt = taskProtocol.createdAt
        updatedAt = taskProtocol.updatedAt
        yesterDaily = taskProtocol.yesterDaily
        
        if tags != nil {
            realmTags.removeAll()
            for tag in taskProtocol.tags {
                let foundTag = tags?.first(where: { (realmTag) -> Bool in
                    return realmTag.id == tag.id
                })
                if let foundTag = foundTag {
                    self.realmTags.append(foundTag)
                }
            }
        } else {
            self.tags = taskProtocol.tags
        }
        checklist = taskProtocol.checklist
        reminders = taskProtocol.reminders
        weekRepeat = taskProtocol.weekRepeat
    }
}
