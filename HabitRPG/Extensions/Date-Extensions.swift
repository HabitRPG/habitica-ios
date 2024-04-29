//
//  Date-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

extension Date {
    static func with(year: Int, month: Int, day: Int, timezone: TimeZone? = nil) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.timeZone = timezone ?? TimeZone.current
        dateComponents.hour = 0
        dateComponents.minute = 0

        // Create date from components
        let userCalendar = Calendar.current // user calendar
        return userCalendar.date(from: dateComponents) ?? Date()
    }
    
func getShortRemainingString() -> String {
        let diff = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: self)
        var string = "\(diff.minute ?? 0)m"
        if let hours = diff.hour, hours > 0 {
            string = "\(hours)h \(string)"
        }
        if let days = diff.day, days > 0 {
            string = "\(days)d \(string)"
        }
        if let seconds = diff.second, diff.hour == 0 && diff.day == 0 {
            string = "\(string) \(seconds)s"
        }
        return string
    }
    
    func getImpreciseRemainingString() -> String {
        let diff = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: self)
        if let days = diff.day, days > 0 {
            if days == 1 {
                return L10n._1Day
            } else {
                return L10n.xDays(days)
            }
        }
        if let hours = diff.hour, hours > 0 {
            if hours == 1 {
                return L10n._1Hour
            } else {
                return L10n.xHours(hours)
            }
        }
        if let minutes = diff.day, minutes > 0 {
            if minutes == 1 {
                return L10n._1Minute
            } else {
                return L10n.xMinutes(minutes)
            }
        }
        return L10n._1Minute
    }
}
