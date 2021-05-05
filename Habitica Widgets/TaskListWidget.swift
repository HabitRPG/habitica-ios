//
//  TaskListWidget.swift
//  Habitica WidgetsExtension
//
//  Created by Phillip Thelen on 08.10.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import WidgetKit
import SwiftUI
import Habitica_Models
import UIKit

struct TaskListProvider: TimelineProvider {
    func placeholder(in context: Context) -> TaskListEntry {
        TaskListEntry(widgetFamily: context.family)
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskListEntry) -> ()) {
        let entry = TaskListEntry(widgetFamily: context.family)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskListEntry>) -> ()) {
        var entries: [TaskListEntry] = []
        TaskManager.shared.getTasks(predicate: NSPredicate(format: "completed == false && (type == 'daily' && isDue == true)")).on(value: { tasks in
            let entry = TaskListEntry(widgetFamily: context.family, tasks: tasks.value)
            entries.append(entry)

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }).take(first: 1).start()
    }
}

struct TaskListEntry: TimelineEntry {
    var date: Date = Date()
    var widgetFamily: WidgetFamily
    var tasks: [TaskProtocol] = []
    var needsCron = false
}

struct TaskListWidgetView : View {
    var entry: TaskListProvider.Entry

    var body: some View {
        GeometryReader { geometry in
            let maxCount = (Int(geometry.size.height) - (entry.widgetFamily == .systemMedium ? 12 : 50)) / 30
            if entry.widgetFamily == .systemMedium {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Dailies").font(.body).foregroundColor(.widgetTextSecondary)
                        Text("\(entry.tasks.count)").font(Font.system(size: 41, weight: .semibold)).foregroundColor(.widgetText)
                        Spacer()
                        Link(destination: URL(string: "/user/tasks/daily/add")!, label: {
                            Image("Add").font(.system(size: 20)).foregroundColor(.widgetText)
                        })
                    }.frame(width: 70, alignment: .leading)
                    VStack {
                        MainWidgetContent(entry: entry, maxCount: maxCount)
                    }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                .padding()
                .background(Color.widgetBackground)
            } else {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Text("Today's Dailies").font(.headline).foregroundColor(.widgetText)
                        Spacer()
                        Link(destination: URL(string: "/user/tasks/daily/add")!, label: {
                            Image("Add").font(.system(size: 20)).foregroundColor(.widgetText)
                        })
                    }.padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
                    VStack {
                        MainWidgetContent(entry: entry, maxCount: maxCount)
                    }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                .padding()
                .background(Color.widgetBackground)
            }
        }
    }
}

struct MainWidgetContent: View {
    var entry: TaskListProvider.Entry
    var maxCount: Int
    
    var body: some View {
        if entry.needsCron {
            StartDayView(showSpacer: false).frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.widgetBackgroundSecondary.opacity(0.1))
                .cornerRadius(6)
        } else if (entry.tasks.isEmpty) {
            VStack {
                Image("Sparkles")
                Text("All done today!").foregroundColor(.widgetText)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.widgetBackgroundSecondary.opacity(0.1))
                .cornerRadius(6)
        } else {
            TaskListView(tasks: entry.tasks, maxCount: maxCount, isLarge: entry.widgetFamily == .systemLarge)
        }
        if (entry.tasks.count < maxCount) {
            Spacer()
        }
    }
}

struct TaskListView: View {
    var tasks: [TaskProtocol]
    var maxCount: Int
    var isLarge: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            let last = (min(tasks.count-1, maxCount))
            ForEach((1...last), id: \.self) { index in
                let task = tasks[index]
                TaskListItem(task: task, showChecklistCount: isLarge)
                if (index != last || (tasks.count <= maxCount || isLarge)) {
                    Rectangle().fill(Color.widgetText.opacity(0.20)).frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1).padding(.leading, 12)
                }
            }
            if tasks.count > maxCount && isLarge {
                Text("\(tasks.count - maxCount) more unfinished Dailies")
                    .foregroundColor(.dailiesWidgetPurple)
                    .font(.system(size: 12))
                    .padding(.leading, 12)
            }
        }
    }
}

struct TaskListItem: View {
    var task: TaskProtocol
    var showChecklistCount: Bool
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color(UIColor.forTaskValue(task.value)))
                .frame(width: 4)
            Text(task.text ?? "").font(.system(size: 13)).foregroundColor(Color.widgetText).lineLimit(2)
            let completedCount = task.checklist.filter { $0.completed }.count
            if showChecklistCount && task.checklist.count > 0 {
                Spacer()
                Text("\(completedCount)/\(task.checklist.count)")
                    .font(.system(size: 11))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .foregroundColor(completedCount == task.checklist.count ? Color.widgetTextSecondary : Color.white)
                    .background(completedCount == task.checklist.count ? Color.checklistBackgroundDone : Color.checklistBackground)
                    .cornerRadius(4)
            }
        }
    }
}

struct TaskListWidget: Widget {
    let kind: String = "TaskListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskListProvider()) { entry in
            TaskListWidgetView(entry: entry)
        }
        .configurationDisplayName("Your Tasks")
        .description("View your Habitica Tasks for the day")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct TaskListWidgetPreview: PreviewProvider {
    static var previews: some View {
        Group {
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, tasks: makePreviewTasks(), needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, tasks: makePreviewTasks(), needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, tasks: makePreviewTasks(), needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, tasks: [], needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .environment(\.colorScheme, .dark)
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, tasks: [], needsCron: true))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }

    }
}

private func makePreviewTasks() -> [TaskProtocol] {
    var tasks = [TaskProtocol]()
    for index in 0...10 {
        let task = PreviewTask()
        task.text = "Test task with a title \(String(repeating: "a", count: index))"
        task.id = "\(index)"
        task.type = "daily"
        task.value = Float.random(in: -10...10)
        if Bool.random() {
            task.checklist.append(PreviewChecklistItem())
            task.checklist.append(PreviewChecklistItem())
            task.checklist.append(PreviewChecklistItem())
        }
        tasks.append(task)
    }
    return tasks
}

private class PreviewTask: TaskProtocol {
    var challengeBroken: String?
    
    var history: [TaskHistoryProtocol] = []
    
    var isValid: Bool = true
    
    var nextDue: [Date] = []
    var weeksOfMonth: [Int] = []
    var daysOfMonth: [Int] = []

    var isNewTask: Bool = false
    var isSynced: Bool = true
    var isSyncing: Bool = false
    var createdAt: Date?
    var updatedAt: Date?
    var startDate: Date?
    var yesterDaily: Bool = true
    var weekRepeat: WeekRepeatProtocol?
    var frequency: String?
    var everyX: Int = 1
    var tags: [TagProtocol] = []
    var checklist: [ChecklistItemProtocol] = []
    var reminders: [ReminderProtocol] = []
    
    var id: String?
    var text: String?
    var notes: String?
    var type: String?
    var value: Float = 0
    var attribute: String?
    var completed: Bool = false
    var down: Bool = false
    var up: Bool = false
    var order: Int = 0
    var priority: Float = 0
    var counterUp: Int = 0
    var counterDown: Int = 0
    var duedate: Date?
    var isDue: Bool = false
    var streak: Int = 0
    var challengeID: String?
}

private class PreviewChecklistItem: ChecklistItemProtocol {
    var text: String?
    var completed: Bool = false
    var id: String?
}
