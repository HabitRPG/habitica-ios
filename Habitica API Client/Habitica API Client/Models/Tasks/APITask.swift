//
//  APITask.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

private struct ChallengeHelper: Decodable {
    var taskId: String?
    var id: String?
    var shortName: String?
}

public class APITask: TaskProtocol, Codable {
    public var id: String?
    public var text: String?
    public var notes: String?
    public var type: String?
    public var value: Float = 0
    public var attribute: String?
    public var completed: Bool = false
    public var down: Bool = false
    public var up: Bool = false
    public var order: Int = 0
    public var priority: Float = 0
    public var counterUp: Int = 0
    public var counterDown: Int = 0
    public var duedate: Date?
    public var isDue: Bool = false
    public var streak: Int = 0
    public var frequency: String?
    public var everyX: Int = 0
    public var challengeID: String?
    public var tags: [TagProtocol] = []
    public var checklist: [ChecklistItemProtocol] = []
    public var reminders: [ReminderProtocol] = []
    public var createdAt: Date?
    public var updatedAt: Date?
    public var startDate: Date?
    public var yesterDaily: Bool = true
    public var weekRepeat: WeekRepeatProtocol?
    public var isSynced: Bool = true
    public var isSyncing: Bool = false
    public var isNewTask: Bool = false
    public var nextDue: [Date] = []
    public var daysOfMonth: [Int] = []
    public var weeksOfMonth: [Int] = []
    public var isValid: Bool {
        return true
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case text
        case notes
        case type
        case value
        case attribute
        case completed
        case down
        case up
        case order
        case priority
        case counterUp
        case counterDown
        case duedate = "date"
        case isDue
        case streak
        case frequency
        case everyX
        case challenge
        case createdAt
        case updatedAt
        case startDate
        case yesterDaily
        case tags
        case checklist
        case reminders
        case weekRepeat = "repeat"
        case nextDue
        case daysOfMonth
        case weeksOfMonth
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(String.self, forKey: .id)
        text = try? values.decode(String.self, forKey: .text)
        notes = try? values.decode(String.self, forKey: .notes)
        type = try? values.decode(String.self, forKey: .type)
        value = try values.decode(Float.self, forKey: .value)
        attribute = try? values.decode(String.self, forKey: .attribute)
        completed = (try? values.decode(Bool.self, forKey: .completed)) ?? false
        down = (try? values.decode(Bool.self, forKey: .down)) ?? false
        up = (try? values.decode(Bool.self, forKey: .up)) ?? false
        priority = (try? values.decode(Float.self, forKey: .priority)) ?? 0
        counterUp = (try? values.decode(Int.self, forKey: .counterUp)) ?? 0
        counterDown = (try? values.decode(Int.self, forKey: .counterDown)) ?? 0
        if let dateString = try? values.decode(String.self, forKey: .duedate), dateString.isEmpty == false {
            duedate = try? values.decode(Date.self, forKey: .duedate)
        }
        isDue = (try? values.decode(Bool.self, forKey: .isDue)) ?? false
        streak = (try? values.decode(Int.self, forKey: .streak)) ?? 0
        frequency = try? values.decode(String.self, forKey: .frequency)
        everyX = (try? values.decode(Int.self, forKey: .everyX)) ?? 0
        let challengeHelper = try? values.decode(ChallengeHelper.self, forKey: .challenge)
        challengeID = challengeHelper?.id
        createdAt = try? values.decode(Date.self, forKey: .createdAt)
        updatedAt = try? values.decode(Date.self, forKey: .updatedAt)
        startDate = try? values.decode(Date.self, forKey: .startDate)
        yesterDaily = (try? values.decode(Bool.self, forKey: .yesterDaily)) ?? true
        let tagList = try? values.decode([String].self, forKey: .tags)
        tags = tagList?.map { key -> APITag in
            return APITag(key)
            } ?? []
        checklist = (try? values.decode([APIChecklistItem].self, forKey: .checklist)) ?? []
        reminders = (try? values.decode([APIReminder].self, forKey: .reminders)) ?? []
        weekRepeat = try? values.decode(APIWeekRepeat.self, forKey: .weekRepeat)
        daysOfMonth = (try? values.decode([Int].self, forKey: .daysOfMonth)) ?? []
        weeksOfMonth = (try? values.decode([Int].self, forKey: .weeksOfMonth)) ?? []
        nextDue = (try? values.decode([Date].self, forKey: .nextDue)) ?? []
    }
    
    public init(_ taskProtocol: TaskProtocol) {
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
        checklist = taskProtocol.checklist.map({ (item) -> APIChecklistItem in return APIChecklistItem(item) })
        reminders = taskProtocol.reminders.map({ (reminder) -> APIReminder in return APIReminder(reminder) })
        tags = taskProtocol.tags.map({ (tag) -> APITag in return APITag(tag) })
        if let thisRepeat = taskProtocol.weekRepeat {
            weekRepeat = APIWeekRepeat(thisRepeat)
        }
        nextDue = taskProtocol.nextDue
        daysOfMonth = taskProtocol.daysOfMonth
        weeksOfMonth = taskProtocol.weeksOfMonth
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let taskID = id, UUID(uuidString: taskID) != nil {
            try? container.encode(id, forKey: .id)
        }
        try? container.encode(text, forKey: .text)
        try? container.encode(notes, forKey: .notes)
        try? container.encode(type, forKey: .type)
        try? container.encode(attribute, forKey: .attribute)
        try? container.encode(completed, forKey: .completed)
        try? container.encode(up, forKey: .up)
        try? container.encode(down, forKey: .down)
        try? container.encode(order, forKey: .order)
        try? container.encode(priority, forKey: .priority)
        try? container.encode(counterUp, forKey: .counterUp)
        try? container.encode(counterDown, forKey: .counterDown)
        try? container.encode(duedate, forKey: .duedate)
        try? container.encode(isDue, forKey: .isDue)
        try? container.encode(streak, forKey: .streak)
        try? container.encode(frequency, forKey: .frequency)
        try? container.encode(everyX, forKey: .everyX)
        try? container.encode(startDate, forKey: .startDate)
        try? container.encode(createdAt, forKey: .createdAt)
        try? container.encode(updatedAt, forKey: .updatedAt)
        try? container.encode(yesterDaily, forKey: .yesterDaily)
        try? container.encode(checklist as? [APIChecklistItem], forKey: .checklist)
        try? container.encode(reminders as? [APIReminder], forKey: .reminders)
        try? container.encode(tags.map({ (tag) -> String? in return tag.id }), forKey: .tags)
        try? container.encode(weekRepeat as? APIWeekRepeat, forKey: .weekRepeat)
        try? container.encode(daysOfMonth, forKey: .daysOfMonth)
        try? container.encode(weeksOfMonth, forKey: .weeksOfMonth)
        try? container.encode(value, forKey: .value)
    }
}
