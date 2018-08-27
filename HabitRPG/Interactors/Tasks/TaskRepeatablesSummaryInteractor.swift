//
//  TaskRepeatablesSummaryInteractor.swift
//  Habitica
//
//  Created by Phillip Thelen on 20/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Habitica_Models

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
    var daysOfMonth = [Int]()
    var weeksOfMonth = [Int]()

    init(task: TaskProtocol) {
        self.frequency = task.frequency
        self.everyX = task.everyX
        self.monday = task.weekRepeat?.monday ?? false
        self.tuesday = task.weekRepeat?.tuesday ?? false
        self.wednesday = task.weekRepeat?.wednesday ?? false
        self.thursday = task.weekRepeat?.thursday ?? false
        self.friday = task.weekRepeat?.friday ?? false
        self.saturday = task.weekRepeat?.saturday ?? false
        self.sunday = task.weekRepeat?.sunday ?? false
        self.startDate = task.startDate
        self.daysOfMonth = task.daysOfMonth
        self.weeksOfMonth = task.weeksOfMonth
    }

    init(frequency: String?,
         everyX: Int?,
         monday: Bool?,
         tuesday: Bool?,
         wednesday: Bool?,
         thursday: Bool?,
         friday: Bool?,
         saturday: Bool?,
         sunday: Bool?,
         startDate: Date?,
         daysOfMonth: [Int]?,
         weeksOfMonth: [Int]?) {
        self.frequency = frequency
        self.everyX = everyX ?? 1
        self.monday = monday ?? false
        self.tuesday = tuesday ?? false
        self.wednesday = wednesday ?? false
        self.thursday = thursday ?? false
        self.friday = friday ?? false
        self.saturday = saturday ?? false
        self.sunday = sunday ?? false
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
    func repeatablesSummary(frequency: String?,
                            everyX: Int?,
                            monday: Bool?,
                            tuesday: Bool?,
                            wednesday: Bool?,
                            thursday: Bool?,
                            friday: Bool?,
                            saturday: Bool?,
                            sunday: Bool?,
                            startDate: Date?,
                            daysOfMonth: [Int]?,
                            weeksOfMonth: [Int]?) -> String {
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
    func repeatablesSummary(_ task: TaskProtocol) -> String {
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
                    days.append(String(day))
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
