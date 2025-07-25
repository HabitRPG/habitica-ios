//
//  APIReminder.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIReminder: ReminderProtocol, Codable {
    var id: String?
    var startDate: Date?
    var time: Date?
    var task: TaskProtocol? {
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case startDate
        case time
    }
    
    // Encodes dates as local time with 'Z' suffix (handles timezone changes as well)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let startDate = startDate {
            try container.encode(formatter.string(from: startDate), forKey: .startDate)
        }
        
        if let time = time {
            try container.encode(formatter.string(from: time), forKey: .time)
        }
    }
    
    init(_ reminderProtocol: ReminderProtocol) {
        id = reminderProtocol.id
        startDate = reminderProtocol.startDate
        time = reminderProtocol.time
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        startDate = try decodeLocalTimeWithZSuffix(from: container, forKey: .startDate)
        time = try decodeLocalTimeWithZSuffix(from: container, forKey: .time)
    }
    
    private func decodeLocalTimeWithZSuffix(from container: KeyedDecodingContainer<CodingKeys>, 
                                           forKey key: CodingKeys) throws -> Date? {
        if let dateString = try? container.decode(String.self, forKey: key),
           dateString.hasSuffix("Z") && dateString.contains(".") {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            formatter.timeZone = TimeZone.current
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter.date(from: dateString.replacingOccurrences(of: "Z", with: ""))
        }
        
        return try container.decodeIfPresent(Date.self, forKey: key)
    }
    
    func detached() -> ReminderProtocol {
        return self
    }
    
    var isValid: Bool = true
    var isManaged: Bool = false
}
