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
        TaskManager.shared.getUser().zip(with: TaskManager.shared.getTasks(predicate: NSPredicate(format: "completed == false && type == 'daily' && isDue == true")))
        .on(value: { (user, tasks) in
            let entry = TaskListEntry(widgetFamily: context.family, tasks: tasks.value, needsCron: user.needsCron)
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
            let maxCount = min(8, (Int(geometry.size.height) - (entry.widgetFamily == .systemMedium ? 12 : 60)) / 30)
            if entry.widgetFamily == .systemMedium {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Dailies").font(.system(size: 13, weight: .semibold)).foregroundColor(.widgetTextSecondary).padding(.top, 4)
                        Text("\(entry.tasks.count)").font(Font.system(size: 34)).foregroundColor(Color("taskListSecondaryText"))
                        Spacer()
                        if let dailyURL = URL(string: "/user/tasks/daily/add") {
                            Link(destination: dailyURL, label: {
                                Image("Add").foregroundColor(Color("taskListSecondaryText"))
                            }).padding(.bottom, 7)
                        }
                    }.frame(width: 60, alignment: .leading)
                    MainWidgetContent(entry: entry, maxCount: maxCount)
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.widgetBackground)
            } else {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Text("Today's Dailies").font(.system(size: 20, weight: .semibold)).foregroundColor(Color("taskListPrimaryText"))
                        Spacer()
                        
                        if let dailyURL = URL(string: "/user/tasks/daily/add") {
                            Link(destination: dailyURL, label: {
                                Image("Add").foregroundColor(Color("taskListSecondaryText"))
                            })
                        }
                    }.padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
                    VStack {
                        MainWidgetContent(entry: entry, maxCount: maxCount)
                    }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                .padding(20)
                .background(Color.widgetBackground)
            }
        }
        .widgetURL(URL(string: "/user/tasks/daily"))
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
                Text("All done today!").foregroundColor(.widgetText).font(.system(size: 13))
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
    
    var remaining: Int {
        return tasks.count - maxCount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let last = (min(tasks.count, maxCount))-1
            ForEach((0...last), id: \.self) { index in
                let task = tasks[index]
                TaskListItem(task: task, showChecklistCount: isLarge).frame(height: 29)
                if (index != last || (tasks.count > maxCount && isLarge)) {
                    Rectangle().fill(Color.separator.opacity(0.3)).frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1).padding(.leading, 12)
                }
            }
            if tasks.count > maxCount && isLarge {
                Text(remaining == 1 ?
                    "1 more unfinished Daily" :
                    "\(remaining) more unfinished Dailies")
                    .foregroundColor(.dailiesWidgetPurple)
                    .font(.system(size: 12))
                    .padding(.leading, 12)
                    .padding(.top, 6)
            }
            Spacer()
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
                .frame(width: 4, height: 18)
            Text(task.text ?? "").font(.system(size: 13)).foregroundColor(Color("taskListTaskText")).lineLimit(2)
            let completedCount = task.checklist.filter { $0.completed }.count
            if showChecklistCount && !task.checklist.isEmpty {
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
    
    private var families: [WidgetFamily] = {
        var families: [WidgetFamily] = [.systemMedium, .systemLarge]
        if #available(iOSApplicationExtension 15.0, *) {
            families.append(.systemExtraLarge)
        }
        return families
    }()

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskListProvider()) { entry in
            TaskListWidgetView(entry: entry)
        }
        .configurationDisplayName("Your Dailies")
        .description("View your Habitica Dailies due today")
        .supportedFamilies(families)
    }
}

struct TaskListWidgetPreview: PreviewProvider {
    static var previews: some View {
        Group {
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, tasks: makePreviewTasks().dropLast(8), needsCron: true))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, tasks: makePreviewTasks().dropLast(8), needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, tasks: makePreviewTasks(), needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, tasks: makePreviewTasks(), needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, tasks: [], needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .environment(\.colorScheme, .dark)
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemMedium, tasks: [], needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, tasks: [], needsCron: true))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, tasks:makePreviewTasks().dropLast(6), needsCron: false))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            if #available(iOSApplicationExtension 15.0, *) {
                TaskListWidgetView(entry: TaskListEntry(widgetFamily: .systemLarge, tasks:makePreviewTasks().dropLast(6), needsCron: false))
                    .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
            }
        }

    }
}

private func makePreviewTasks() -> [TaskProtocol] {
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
