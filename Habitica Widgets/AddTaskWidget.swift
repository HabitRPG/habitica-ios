//
//  AddTaskWidget.swift
//  Habitica WidgetsExtension
//
//  Created by Phillip Thelen on 08.10.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import WidgetKit
import SwiftUI

struct AddTaskSingleProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> AddTaskEntry {
        AddTaskEntry(widgetFamily: context.family, taskType: HRPGTaskType.none)
    }

    func getSnapshot(for configuration: HRPGAddTaskSingleIntent, in context: Context, completion: @escaping (AddTaskEntry) -> ()) {
        let entry = AddTaskEntry(widgetFamily: context.family, taskType: configuration.taskType)
        completion(entry)
    }

    func getTimeline(for configuration: HRPGAddTaskSingleIntent, in context: Context, completion: @escaping (Timeline<AddTaskEntry>) -> ()) {
        var entries: [AddTaskEntry] = []
        let entry = AddTaskEntry(widgetFamily: context.family, taskType: configuration.taskType)
        entries.append(entry)
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct AddTaskProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> AddTaskEntry {
        AddTaskEntry(widgetFamily: context.family, taskType: HRPGTaskType.none)
    }

    func getSnapshot(for configuration: HRPGAddTaskIntent, in context: Context, completion: @escaping (AddTaskEntry) -> ()) {
        let entry = AddTaskEntry(widgetFamily: context.family, showLabels: (configuration.showLabel?.boolValue == true))
        completion(entry)
    }

    func getTimeline(for configuration: HRPGAddTaskIntent, in context: Context, completion: @escaping (Timeline<AddTaskEntry>) -> ()) {
        var entries: [AddTaskEntry] = []
        let entry = AddTaskEntry(widgetFamily: context.family, showLabels: (configuration.showLabel?.boolValue == true))
        entries.append(entry)
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct AddTaskEntry: TimelineEntry {
    var date: Date = Date()
    var widgetFamily: WidgetFamily
    
    var taskType: HRPGTaskType?
    var showLabels = false
}

struct AddTaskWidgetView : View {
    var entry: AddTaskProvider.Entry
    
    var taskIdentifier: String? {
        switch entry.taskType {
        case .habit:
            return "habit"
        case .daily:
            return "daily"
        case .todo:
            return "todo"
        case .reward:
            return "reward"
        default:
            return nil
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            if (entry.widgetFamily == .systemSmall) {
                if let identifier = taskIdentifier {
                    AddView(taskType: entry.taskType ?? HRPGTaskType.none, isSingle: true, showLabel: true).widgetURL(URL(string: "/user/tasks/\(identifier)/add"))
                } else {
                    AddView(taskType: nil, isSingle: true, showLabel: true)
                }
            } else {
                VStack(alignment: .center) {
                    if let habitURL = URL(string: "/user/tasks/habit/add") {
                        Link(destination: habitURL, label: {
                            AddView(taskType: .habit, showLabel: entry.showLabels).padding(EdgeInsets(top: 0, leading: 0, bottom: 9, trailing: 0))
                        })
                    }
                    
                    if let todoURL = URL(string: "/user/tasks/todo/add") {
                        Link(destination: todoURL, label: {
                            AddView(taskType: .todo, showLabel: entry.showLabels)
                        })
                    }
                }.padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 0))
                VStack(alignment: .center) {
                    if let dailyURL = URL(string: "/user/tasks/daily/add") {
                        Link(destination: dailyURL, label: {
                            AddView(taskType: .daily, showLabel: entry.showLabels).padding(EdgeInsets(top: 0, leading: 0, bottom: 9, trailing: 0))
                        })
                    }
                    
                    if let rewardURL = URL(string: "/user/tasks/reward/add") {
                        Link(destination: rewardURL, label: {
                            AddView(taskType: .reward, showLabel: entry.showLabels)
                        })
                    }
                }.padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 12))
            }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        .background(Color.widgetBackground)
            }
}

struct AddView: View {
    var taskType: HRPGTaskType?
    var isSingle: Bool = false
    var showLabel: Bool = false
    
    var iconName: String {
        if (isSingle && showLabel) {
            switch taskType {
            case .habit:
                return "AddHabitText"
            case .daily:
                return "AddDailyText"
            case .todo:
                return "AddToDoText"
            case .reward:
                return "AddRewardText"
            default:
                return "Settings"
            }
        } else if (showLabel) {
            switch taskType {
            case .habit:
                return "AddHabitSmall"
            case .daily:
                return "AddDailySmall"
            case .todo:
                return "AddToDoSmall"
            case .reward:
                return "AddRewardSmall"
            default:
                return "Settings"
            }
        } else {
            switch taskType {
            case .habit:
                return "AddHabit"
            case .daily:
                return "AddDaily"
            case .todo:
                return "AddToDo"
            case .reward:
                return "AddReward"
            default:
                return "Settings"
            }
        }
    }
    
    var taskName: String {
        switch taskType {
        case .habit:
            return "Habit"
        case .daily:
            return "Daily"
        case .todo:
            return "To Do"
        case .reward:
            return "Reward"
        default:
            return ""
        }
    }
    
    var taskColor: Color {
        switch taskType {
        case .habit:
            return Color.barRed
        case .daily:
            return Color.barYellow
        case .todo:
            return Color.barBlue
        case .reward:
            return Color.barGreen
        default:
            return Color.barGray
        }
    }
    
    var body: some View {
        VStack(alignment: showLabel ? .leading : .center) {
            if (showLabel) { Spacer() }
            Image(iconName)
            if (showLabel) { Text(taskType == nil ? "Edit to select a task type" : "Add new\n\(taskName)")
                .foregroundColor(taskType == nil ? Color.gray500 : Color(white: 0, opacity: 0.6))
                .font(.system(size: isSingle ? (taskType == nil ? 17 : 22) : 15, weight: .semibold))
                .padding(.top, isSingle ? -4 : -6)
            }
        }
        .padding(EdgeInsets(top: 0, leading: showLabel ? (isSingle ? 20 : 14) : 0, bottom: showLabel ? (isSingle ? 16 : 10) : 0, trailing: showLabel ? (isSingle ? 20 : 14) : 0))
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: showLabel ? .leading : .center)
        .background(taskColor)
        .cornerRadius(16)
    }
}

struct AddTaskWidgetSingle: Widget {
    let kind: String = "AddTaskWidgetSingle"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: HRPGAddTaskSingleIntent.self, provider: AddTaskSingleProvider()) { entry in
            AddTaskWidgetView(entry: entry)
        }
        .configurationDisplayName("Add Task")
        .description("Add a new Task to Habitica" )
            .supportedFamilies([.systemSmall])
    }
}

struct AddTaskWidget: Widget {
    let kind: String = "AddTaskWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: HRPGAddTaskIntent.self, provider: AddTaskProvider()) { entry in
            AddTaskWidgetView(entry: entry)
        }
        .configurationDisplayName("Add Tasks")
        .description("Add new Tasks to Habitica" )
            .supportedFamilies([.systemMedium])
    }
}

struct AddTaskWidgetPreview: PreviewProvider {
    static var previews: some View {
        AddTaskWidgetView(entry: AddTaskEntry(date: Date(), widgetFamily: .systemSmall, taskType: HRPGTaskType.todo))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
