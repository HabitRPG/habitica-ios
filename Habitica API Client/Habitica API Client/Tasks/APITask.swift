//
//  APITask.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

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
    public var challengeID: String?
    public var tags: [TagProtocol]
    public var checklist: [ChecklistItemProtocol]
    public var reminders: [ReminderProtocol]
    
    enum CodingKeys: String, CodingKey {
        case id
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
        case duedate
        case isDue
        case streak
        case challengeID
        case tags
        case checklist
        case reminders
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
        duedate = try? values.decode(Date.self, forKey: .duedate)
        isDue = (try? values.decode(Bool.self, forKey: .isDue)) ?? false
        streak = (try? values.decode(Int.self, forKey: .streak)) ?? 0
        challengeID = try? values.decode(String.self, forKey: .challengeID)
        let tagList = try! values.decode([String].self, forKey: .tags)
        tags = tagList.map { (key) -> APITag in
            return APITag(key)
        }
        checklist = (try? values.decode([APIChecklistItem].self, forKey: .checklist)) ?? []
        reminders = (try! values.decode([APIReminder].self, forKey: .reminders)) ?? []
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
