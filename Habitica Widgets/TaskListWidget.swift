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
import URLImage


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
}

struct TaskListWidgetView : View {
    var entry: TaskListProvider.Entry

    var body: some View {
        GeometryReader { geometry in
            let maxCount = (Int(geometry.size.height) - 70) / 20
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center) {
                Text("Your Tasks").font(.headline)
                Spacer()
                if (entry.tasks.count > maxCount) {
                    Text("+\(entry.tasks.count - maxCount)").font(.system(size: 13)).foregroundColor(.black).padding(4).background(Color.barYellow).cornerRadius(6)
                }
            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            if (entry.tasks.isEmpty) {
                CompletedView().frame(maxWidth: .infinity, alignment: .center)
            } else {
                TaskListView(tasks: entry.tasks, maxCount: maxCount)
            }
            if (entry.tasks.count < maxCount) {
                Spacer()
            }
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .padding()
        .background(Color.widgetBackground)
            }
    }
}
struct TaskListView: View {
    var tasks: [TaskProtocol]
    var maxCount: Int
    
    var body: some View {
        VStack(spacing: 4) {
            let last = (min(tasks.count-1, maxCount))
            ForEach((1...last), id: \.self) { index in
                let task = tasks[index]
                Text(task.text ?? "").font(.body).foregroundColor(Color.widgetText).lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
                if (index != last) {
                    Rectangle().fill(Color.widgetText.opacity(0.25)).frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                }
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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TaskListWidgetPreview: PreviewProvider {
    static var previews: some View {
        Group {
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemSmall, tasks: makePreviewTasks()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, tasks: makePreviewTasks()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, tasks: makePreviewTasks()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, tasks: makePreviewTasks()))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }

    }
}

private func makePreviewTasks() -> [TaskProtocol] {
    var tasks = [TaskProtocol]()
    for index in 0...10 {
        let task = PreviewTask()
        task.text = "Test task with a long title \(index)"
        task.id = "\(index)"
        task.type = "daily"
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
