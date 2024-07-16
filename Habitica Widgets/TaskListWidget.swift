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
    let taskType: TaskType
    
    init(taskType: TaskType) {
        self.taskType = taskType
    }
    
    func placeholder(in context: Context) -> TaskListEntry {
        TaskListEntry(widgetFamily: context.family, taskType: taskType)
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskListEntry) -> Void) {
        let entry = TaskListEntry(widgetFamily: context.family, taskType: taskType)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskListEntry>) -> Void) {
        var entries: [TaskListEntry] = []
        TaskManager.shared.getUser().zip(with: TaskManager.shared.getTasks(predicate: NSPredicate(format: taskType == .daily ? "completed == false && type == 'daily' && isDue == true": "completed == false && type == 'todo'")))
        .on(value: { (user, tasks) in
            let entry = TaskListEntry(widgetFamily: context.family, taskType: taskType, tasks: tasks.value, needsCron: user.needsCron)
            entries.append(entry)

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }).take(first: 1).start()
    }
}

struct TaskListEntry: TimelineEntry {
    var date: Date = Date()
    var widgetFamily: WidgetFamily
    var taskType: TaskType
    var tasks: [TaskProtocol] = []
    var needsCron = false
}

struct TaskListWidgetView: View {
    var entry: TaskListEntry

    var body: some View {
        GeometryReader { geometry in
            if entry.widgetFamily == .systemMedium {
                HStack {
                    VStack(alignment: .leading) {
                        Text(entry.taskType == .daily ? "Dailies" : "To Do's").font(.system(size: 13, weight: .semibold)).foregroundColor(.widgetTextSecondary).padding(.top, 4)
                        Text("\(entry.tasks.count)").font(Font.system(size: 34)).foregroundColor(Color("taskListSecondaryText"))
                        Spacer()
                        if let addURL = entry.taskType == .daily ? URL(string: "/user/tasks/daily/add") : URL(string: "/user/tasks/todo/add") {
                            Link(destination: addURL, label: {
                                Image("Add").foregroundColor(Color("taskListSecondaryText"))
                            }).padding(.bottom, 7)
                        }
                    }.frame(width: 60, alignment: .leading)
                    MainWidgetContent(entry: entry)
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                    .padding(widgetPadding())
                .widgetBackground(Color.widgetBackground)
            } else {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Text(entry.taskType == .daily ? "Today's Dailies" : "Your To Do's").font(.system(size: 20, weight: .semibold)).foregroundColor(Color("taskListPrimaryText"))
                        Spacer()
                        
                        if let addURL = entry.taskType == .daily ? URL(string: "/user/tasks/daily/add") : URL(string: "/user/tasks/todo/add") {
                            Link(destination: addURL, label: {
                                Image("Add").foregroundColor(Color("taskListSecondaryText"))
                            })
                        }
                    }.padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
                    MainWidgetContent(entry: entry)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                .padding(widgetPadding())
                .widgetBackground(Color.widgetBackground)
            }
        }
        .widgetURL(URL(string: entry.taskType == .daily ? "/user/tasks/daily" : "/user/tasks/todo"))
    }
}

struct MainWidgetContent: View {
    var entry: TaskListEntry
    
    var body: some View {
        if entry.needsCron && entry.taskType == .daily {
            StartDayView(showSpacer: false).frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.widgetBackgroundSecondary.opacity(0.1))
                .cornerRadius(6)
        } else if entry.tasks.isEmpty {
            VStack {
                Image("Sparkles")
                Text(entry.taskType == .daily ? "All done today!" : "All done!").foregroundColor(.widgetText).font(.body)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.widgetBackgroundSecondary.opacity(0.1))
                .cornerRadius(6)
        } else {
            TaskListView(taskType: entry.taskType, tasks: entry.tasks, isLarge: entry.widgetFamily == .systemLarge)
        }
    }
}

struct TaskListView: View {
    var taskType: TaskType
    var tasks: [TaskProtocol]
    var isLarge: Bool
    
    func heighWithBodyFont() -> CGFloat {
            return UIFont.preferredFont(forTextStyle: .body).pointSize
    }
    
    var body: some View {
        GeometryReader { reader in
            let font = Font.body
            let maxCount = Int(reader.size.height / (heighWithBodyFont() + 14))
            let remaining = tasks.count - maxCount + 1
            let last = (min(tasks.count, maxCount - (isLarge ? 1 : 0))) - 1
            VStack(alignment: .leading, spacing: 0) {
                ForEach((0...last), id: \.self) { index in
                    let task = tasks[index]
                    TaskListItem(task: task, showChecklistCount: isLarge, font: font).padding(.vertical, 6)
                    if index != last || (tasks.count > maxCount && isLarge) {
                        Rectangle().fill(Color.separator.opacity(0.3)).frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1).padding(.leading, 12)
                    }
                }
                Spacer()
                if tasks.count > maxCount && isLarge {
                    Text(taskType == .daily ? (remaining == 1 ?
                        "1 more unfinished Daily" :
                                                "\(remaining) more unfinished Dailies") : (remaining == 1 ?
                                                                                           "1 more unfinished To Do" :
                                                                                           "\(remaining) more unfinished To Do's"))
                        .foregroundColor(.dailiesWidgetPurple)
                        .font(.caption)
                        .padding(.leading, 12)
                        .padding(.top, 6)
                }
            }.frame(height: reader.size.height)
        }
    }
}

struct TaskListItem: View {
    var task: TaskProtocol
    var showChecklistCount: Bool
    var font: Font
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color(UIColor.forTaskValue(task.value)))
                .frame(width: 4, height: 18)
            Text(task.text ?? "").font(font).foregroundColor(Color("taskListTaskText")).lineLimit(2)
            let completedCount = task.checklist.filter { $0.completed }.count
            if showChecklistCount && !task.checklist.isEmpty {
                Spacer()
                Text("\(completedCount)/\(task.checklist.count)")
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .foregroundColor(completedCount == task.checklist.count ? Color.widgetTextSecondary : Color.white)
                    .background(completedCount == task.checklist.count ? Color.checklistBackgroundDone : Color.checklistBackground)
                    .cornerRadius(4)
            }
        }
    }
}

struct DailyTaskListWidget: Widget {
    let kind: String = "TaskListWidget"
    
    private var families: [WidgetFamily] = {
        var families: [WidgetFamily] = [.systemMedium, .systemLarge]
        if #available(iOSApplicationExtension 15.0, *) {
            families.append(.systemExtraLarge)
        }
        return families
    }()

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskListProvider(taskType: .daily)) { entry in
            TaskListWidgetView(entry: entry)
        }
        .configurationDisplayName("Your Dailies")
        .description("View your Habitica Dailies due today")
        .supportedFamilies(families)
    }
}

struct TodoTaskListWidget: Widget {
    let kind: String = "TodoTaskListWidget"
    
    private var families: [WidgetFamily] = {
        var families: [WidgetFamily] = [.systemMedium, .systemLarge]
        if #available(iOSApplicationExtension 15.0, *) {
            families.append(.systemExtraLarge)
        }
        return families
    }()

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskListProvider(taskType: .todo)) { entry in
            TaskListWidgetView(entry: entry)
        }
        .configurationDisplayName("Your To Do's")
        .description("View your Habitica To Do's")
        .supportedFamilies(families)
    }
}

struct TaskListWidgetPreview: PreviewProvider {
    static var previews: some View {
        Group {
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, taskType: .daily, tasks: makePreviewDailies().dropLast(8), needsCron: true))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, taskType: .daily, tasks: makePreviewDailies().dropLast(8), needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, taskType: .daily, tasks: makePreviewDailies(), needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, taskType: .daily, tasks: makePreviewDailies(), needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, taskType: .daily, tasks: [], needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .environment(\.colorScheme, .dark)
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, taskType: .daily, tasks: [], needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, taskType: .daily, tasks: [], needsCron: true))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, taskType: .daily, tasks: makePreviewDailies().dropLast(6), needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            if #available(iOSApplicationExtension 15.0, *) {
                TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, taskType: .daily, tasks: makePreviewDailies().dropLast(6), needsCron: false))
                    .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
            }
        }
        Group {
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, taskType: .todo, tasks: makePreviewDailies().dropLast(8), needsCron: true))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, taskType: .todo, tasks: makePreviewDailies().dropLast(8), needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, taskType: .todo, tasks: makePreviewDailies(), needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, taskType: .todo, tasks: makePreviewDailies(), needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, taskType: .todo, tasks: [], needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .environment(\.colorScheme, .dark)
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, taskType: .todo, tasks: [], needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, taskType: .todo, tasks: [], needsCron: true))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, taskType: .todo, tasks: makePreviewDailies().dropLast(6), needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            if #available(iOSApplicationExtension 15.0, *) {
                TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, taskType: .todo, tasks: makePreviewDailies().dropLast(6), needsCron: false))
                    .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
            }
        }
    }
}

private func makePreviewDailies() -> [TaskProtocol] {
    var tasks = [TaskProtocol]()
    for index in 1...10 {
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
