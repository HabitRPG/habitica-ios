//
//  DateDecodingStrategy-Extension.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Shared

extension JSONDecoder {
    
    func setHabiticaDateDecodingStrategy() {
        dateDecodingStrategy = .custom({ dateDecoder -> Date in
            let container = try dateDecoder.singleValueContainer()
            
            if let timestampNumber = try? container.decode(Double.self) {
                return Date(timeIntervalSince1970: timestampNumber)
            }
            
            let dateStr = try container.decode(String.self)
            
            if let date = ISO8601DateFormatter().date(from: dateStr) {
                return date
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            if let date = dateFormatter.date(from: dateStr) {
                return date
            }
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmzzz"
            if let date = dateFormatter.date(from: dateStr) {
                return date
            }
            
            //This is sometimes used for the `nextDue` dates
            var splitString = dateStr.split(separator: " ")
            if splitString.count == 6 {
                splitString[5] = splitString[5].trimmingCharacters(in: CharacterSet(charactersIn: "01234567890+").inverted).split(separator: " ")[0]
                dateFormatter.dateFormat = "E MMM dd yyyy HH:mm:ss Z"
                if let date = dateFormatter.date(from: splitString.joined(separator: " ")) {
                    return date
                }
            }
            
            //Various formats for just the day
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: dateStr) {
                return date
            }
            dateFormatter.dateFormat = "MM/dd/yyyy"
            if let date = dateFormatter.date(from: dateStr) {
                return date
            }
            dateFormatter.dateFormat = "dd/MM/yyyy"
            if let date = dateFormatter.date(from: dateStr) {
                return date
            }
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            if let date = dateFormatter.date(from: dateStr) {
                return date
            }
            
            dateFormatter.dateFormat = "dd MMM yyyy HH:mm zzz"
            if let date = dateFormatter.date(from: dateStr) {
                return date
            }
            
            RemoteLogger.shared.record(name: "DateParserException", reason: "Date \(dateStr) could not be parsed")
            
            return Date(timeIntervalSince1970: 0)
        })
    }
    
}
