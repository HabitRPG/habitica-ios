//
//  Date-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

extension Date {
    static func with(year: Int, month: Int, day: Int, timezone: TimeZone?) -> Date {
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
}
