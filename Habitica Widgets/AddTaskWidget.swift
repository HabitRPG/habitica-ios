//
//  AddTaskWidget.swift
//  Habitica WidgetsExtension
//
//  Created by Phillip Thelen on 08.10.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import WidgetKit
import SwiftUI

struct AddTaskProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> AddTaskEntry {
        AddTaskEntry(widgetFamily: context.family, taskType: HRPGTaskType.todo)
    }

    func getSnapshot(for configuration: HRPGAddTaskIntent, in context: Context, completion: @escaping (AddTaskEntry) -> ()) {
        let entry = AddTaskEntry(widgetFamily: context.family, taskType: configuration.taskType)
        completion(entry)
    }

    func getTimeline(for configuration: HRPGAddTaskIntent, in context: Context, completion: @escaping (Timeline<AddTaskEntry>) -> ()) {
        var entries: [AddTaskEntry] = []
        let entry = AddTaskEntry(widgetFamily: context.family, taskType: configuration.taskType)
        entries.append(entry)
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct AddTaskEntry: TimelineEntry {
    var date: Date = Date()
    var widgetFamily: WidgetFamily
    
    var taskType: HRPGTaskType
}

struct AddTaskWidgetView : View {
    var entry: AddTaskProvider.Entry
    
    var taskIdentifier: String {
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
            return ""
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            if (entry.widgetFamily == .systemSmall) {
                AddView(taskType: entry.taskType).widgetURL(URL(string: "/user/tasks/\(taskIdentifier)/add"))
            } else {
                Link(destination: URL(string: "/user/tasks/habit/add")!, label: {
                    AddView(taskType: .habit)
                })
                Link(destination: URL(string: "/user/tasksdaily/add")!, label: {
                    AddView(taskType: .daily)
                })
                Link(destination: URL(string: "/user/tasks/todo/add")!, label: {
                    AddView(taskType: .todo)
                })
                Link(destination: URL(string: "/user/tasks/reward/add")!, label: {
                    AddView(taskType: .reward)
                })
            }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        .background(Color.widgetBackground)
            }
}

struct AddView: View {
    var taskType: HRPGTaskType
    
    var iconName: String {
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
            return ""
        }
    }
    
    var taskName: String {
        switch taskType {
        case .habit:
            return "Habit"
        case .daily:
            return "Daily"
        case .todo:
            return "ToDo"
        case .reward:
            return "Reward"
        default:
            return ""
        }
    }
    
    var taskColor: Color {
        switch taskType {
        case .habit:
            return Color.barBlue
        case .daily:
            return Color.barYellow
        case .todo:
            return Color.barRed
        case .reward:
            return Color.barGreen
        default:
            return Color.barOrange
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image(iconName).foregroundColor(Color.widgetText).frame(width: 60, height: 60, alignment: .center).background(Circle().fill(taskColor))
            Text("Add\n\(taskName)").foregroundColor(Color.widgetText).font(Font.system(size: 14, weight: .semibold)).multilineTextAlignment(.center)
        }
    }
}

struct AddTaskWidget: Widget {
    let kind: String = "AddTaskWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: HRPGAddTaskIntent.self, provider: AddTaskProvider()) { entry in
            AddTaskWidgetView(entry: entry)
        }
        .configurationDisplayName("Add Task")
        .description("Add a new Task to Habitica" )
            .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct AddTaskWidgetPreview: PreviewProvider {
    static var previews: some View {
        AddTaskWidgetView(entry: AddTaskEntry(date: Date(), widgetFamily: .systemSmall, taskType: HRPGTaskType.todo))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
