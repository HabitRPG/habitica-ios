//
//  TaskRepeatablesSummaryInteractor.swift
//  Habitica
//
//  Created by Phillip Thelen on 20/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift

private enum RepeatType {
    case never
    case daily
    case weekly
    case monthly
    case yearly

    func string(_ everyX: Int) -> String {
        if self == .never {
            return NSLocalizedString("never", comment: "")
        }
        if everyX == 1 {
            return self.everyName()
        } else {
            return NSLocalizedString("every \(everyX) \(self.repeatName())", comment: "")
        }
    }

    private func everyName() -> String {
        switch self {
        case .daily:
            return NSLocalizedString("daily", comment: "As in 'repeats daily'")
        case .weekly:
            return NSLocalizedString("weekly", comment: "As in 'repeats weekly'")
        case .monthly:
            return NSLocalizedString("monthly", comment: "As in 'repeats monthly'")
        case .yearly:
            return NSLocalizedString("yearly", comment: "As in 'repeats yearly'")
        default:
            return ""
        }
    }

    private func repeatName() -> String {
        switch self {
        case .daily:
            return NSLocalizedString("days", comment: "")
        case .weekly:
            return NSLocalizedString("weeks", comment: "")
        case .monthly:
            return NSLocalizedString("months", comment: "")
        case .yearly:
            return NSLocalizedString("years", comment: "")
        default:
            return ""
        }
    }
}

struct RepeatableTask {
    var frequency: String?
    var everyX = 1
    var monday = false
    var tuesday = false
    var wednesday = false
    var thursday = false
    var friday = false
    var saturday = false
    var sunday = false
    var startDate: Date?
    var daysOfMonth = Set<NSNumber>()
    var weeksOfMonth = Set<NSNumber>()

    init(task: Task) {
        self.frequency = task.frequency
        self.everyX = task.everyX?.intValue ?? 1
        self.monday = task.monday?.boolValue ?? false
        self.tuesday = task.tuesday?.boolValue ?? false
        self.wednesday = task.wednesday?.boolValue ?? false
        self.thursday = task.thursday?.boolValue ?? false
        self.friday = task.friday?.boolValue ?? false
        self.saturday = task.saturday?.boolValue ?? false
        self.sunday = task.sunday?.boolValue ?? false
        self.startDate = task.startDate
        if let daysOfMonth = task.daysOfMonth {
            self.daysOfMonth = daysOfMonth
        }
        if let weeksOfMonth = task.weeksOfMonth {
            self.weeksOfMonth = weeksOfMonth
        }
    }

    init(frequency: String?,
         everyX: NSNumber?,
         monday: NSNumber?,
         tuesday: NSNumber?,
         wednesday: NSNumber?,
         thursday: NSNumber?,
         friday: NSNumber?,
         saturday: NSNumber?,
         sunday: NSNumber?,
         startDate: Date?,
         daysOfMonth: Set<NSNumber>?,
         weeksOfMonth: Set<NSNumber>?) {
        self.frequency = frequency
        self.everyX = everyX?.intValue ?? 1
        self.monday = monday?.boolValue ?? false
        self.tuesday = tuesday?.boolValue ?? false
        self.wednesday = wednesday?.boolValue ?? false
        self.thursday = thursday?.boolValue ?? false
        self.friday = friday?.boolValue ?? false
        self.saturday = saturday?.boolValue ?? false
        self.sunday = sunday?.boolValue ?? false
        self.startDate = startDate
        if let daysOfMonth = daysOfMonth {
            self.daysOfMonth = daysOfMonth
        }
        if let weeksOfMonth = weeksOfMonth {
            self.weeksOfMonth = weeksOfMonth
        }
    }

    func allWeekdaysInactive() -> Bool {
        return !monday && !tuesday && !wednesday && !thursday && !friday && !saturday && !sunday
    }
}

class TaskRepeatablesSummaryInteractor: NSObject {

    let dateFormatter: DateFormatter
    let yearlyFormat: String
    let monthlyFormat: String

    override init() {
        let yearlyTemplate = "ddMMMM"
        if let yearlyFormat = DateFormatter.dateFormat(fromTemplate: yearlyTemplate, options: 0, locale: NSLocale.current) {
            self.yearlyFormat = yearlyFormat
        } else {
            self.yearlyFormat = ""
        }
        let monthlyTemplate = "FEEEE"
        if let monthlyFormat = DateFormatter.dateFormat(fromTemplate: monthlyTemplate, options: 0, locale: NSLocale.current) {
            self.monthlyFormat = monthlyFormat
        } else {
            self.monthlyFormat = ""
        }
        self.dateFormatter = DateFormatter()
        super.init()
    }

    //swiftlint:disable function_parameter_count
    @objc
    func repeatablesSummary(frequency: String?,
                            everyX: NSNumber?,
                            monday: NSNumber?,
                            tuesday: NSNumber?,
                            wednesday: NSNumber?,
                            thursday: NSNumber?,
                            friday: NSNumber?,
                            saturday: NSNumber?,
                            sunday: NSNumber?,
                            startDate: Date?,
                            daysOfMonth: Set<NSNumber>?,
                            weeksOfMonth: Set<NSNumber>?) -> String {
        let task = RepeatableTask(frequency: frequency,
                                  everyX: everyX,
                                  monday: monday,
                                  tuesday: tuesday,
                                  wednesday: wednesday,
                                  thursday: thursday,
                                  friday: friday,
                                  saturday: saturday,
                                  sunday: sunday,
                                  startDate: startDate,
                                  daysOfMonth: daysOfMonth,
                                  weeksOfMonth: weeksOfMonth)
        return self.repeatablesSummary(task)
    }
    //swiftlint:enable function_parameter_count

    @objc
    func repeatablesSummary(_ task: Task) -> String {
        return self.repeatablesSummary(RepeatableTask(task: task))
    }

    func repeatablesSummary(_ task: RepeatableTask) -> String {
        let everyX = task.everyX

        var repeatType = RepeatType.daily
        var repeatOnString: String? = nil
        switch task.frequency ?? "" {
        case "daily":
            repeatType = .daily
        case "weekly":
            if task.allWeekdaysInactive() {
                repeatType = .never
            } else {
                repeatType = .weekly
            }
            repeatOnString = weeklyRepeatOn(task)
        case "monthly":
            repeatType = .monthly
            repeatOnString = monthlyRepeatOn(task)
        case "yearly":
            repeatType = .yearly
            repeatOnString = yearlyRepeatOn(task)
        default:
            break
        }

        if task.everyX == 0 {
            repeatType = .never
        }
        if let repeatOnString = repeatOnString, repeatType != .never {
            return NSLocalizedString("Repeats \(repeatType.string(everyX)) on \(repeatOnString)", comment: "")
        } else {
            return NSLocalizedString("Repeats \(repeatType.string(everyX))", comment: "")
        }
    }

    private func weeklyRepeatOn(_ task: RepeatableTask) -> String? {
        if task.allWeekdaysInactive() {
            return nil
        } else if task.monday &&
            task.tuesday  &&
            task.wednesday &&
            task.thursday &&
            task.friday &&
            task.saturday &&
            task.sunday {
            return NSLocalizedString("every day", comment: "")
        } else if task.monday &&
            task.tuesday  &&
            task.wednesday &&
            task.thursday &&
            task.friday &&
            !task.saturday &&
            !task.sunday {
            return NSLocalizedString("weekdays", comment: "")
        } else if !task.monday &&
            !task.tuesday  &&
            !task.wednesday &&
            !task.thursday &&
            !task.friday &&
            task.saturday &&
            task.sunday {
            return NSLocalizedString("weekends", comment: "")
        } else {
            return assembleActiveDaysString(task)
        }
    }

    private func assembleActiveDaysString(_ task: RepeatableTask) -> String {
        var repeatOnComponents = [String]()
        if task.monday {
            repeatOnComponents.append(NSLocalizedString("Monday", comment: ""))
        }
        if task.tuesday {
            repeatOnComponents.append(NSLocalizedString("Tuesday", comment: ""))
        }
        if task.wednesday {
            repeatOnComponents.append(NSLocalizedString("Wednesday", comment: ""))
        }
        if task.thursday {
            repeatOnComponents.append(NSLocalizedString("Thursday", comment: ""))
        }
        if task.friday {
            repeatOnComponents.append(NSLocalizedString("Friday", comment: ""))
        }
        if task.saturday {
            repeatOnComponents.append(NSLocalizedString("Saturday", comment: ""))
        }
        if task.sunday {
            repeatOnComponents.append(NSLocalizedString("Sunday", comment: ""))
        }
        return repeatOnComponents.joined(separator: ", ")
    }

    private func monthlyRepeatOn(_ task: RepeatableTask) -> String? {
            if task.daysOfMonth.count > 0 {
                var days = [String]()
                for day in task.daysOfMonth {
                    days.append(day.stringValue)
                }
                return NSLocalizedString("the \(days.joined(separator: ", "))", comment: "")
            }
            if task.weeksOfMonth.count > 0 {
                if let startDate = task.startDate {
                    self.dateFormatter.dateFormat = monthlyFormat
                    return NSLocalizedString("the \(dateFormatter.string(from: startDate))", comment: "")
                }
            }
        return nil
    }

    private func yearlyRepeatOn(_ task: RepeatableTask) -> String? {
        if let startDate = task.startDate {
            self.dateFormatter.dateFormat = yearlyFormat
            return dateFormatter.string(from: startDate)
        } else {
            return nil
        }
    }
}
