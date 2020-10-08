//
//  RemainingDailiesWidget.swift
//  Habitica Widgets
//
//  Created by Phillip Thelen on 06.10.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import WidgetKit
import SwiftUI
import Foundation
import Habitica_Models
import ReactiveSwift

struct DailiesCountProvider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> DailiesCountWidgetEntry {
        DailiesCountWidgetEntry(date: Date(),
                  widgetFamily: context.family, totalCount: 42, completedCount: 10)
    }

    func getSnapshot(for configuration: HRPGDailiesCountIntent,in context: Context, completion: @escaping (DailiesCountWidgetEntry) -> ()) {
        let entry = DailiesCountWidgetEntry(date: Date(), widgetFamily: context.family, totalCount: 10, completedCount: 5)
        completion(entry)
    }

    func getTimeline(for configuration: HRPGDailiesCountIntent, in context: Context, completion: @escaping (Timeline<DailiesCountWidgetEntry>) -> ()) {
        var entries: [DailiesCountWidgetEntry] = []
        SignalProducer.combineLatest(TaskManager.shared.getTasks(predicate: NSPredicate(format: "type == 'daily' && isDue == true")),
                                     TaskManager.shared.getUser()).on(value: { result in
                                        let tasks = result.0
                                        let user = result.1
                                        var needsCron = user.needsCron
                                        if !needsCron, let lastCron = user.lastCron {
                                            let calendar = Calendar.current
                                            let date1 = calendar.startOfDay(for: lastCron)
                                            let date2 = calendar.startOfDay(for: Date())
                                            let components = calendar.dateComponents([.day], from: date1, to: date2)

                                            needsCron = (components.day ?? 0) > 0
                                        }
                                        let entry = DailiesCountWidgetEntry(date: Date(), widgetFamily: context.family, totalCount: tasks.value.count, completedCount: tasks.value.filter({ $0.completed }).count, displayRemaining: configuration.displayRemaining?.boolValue ?? false, needsCron: needsCron)
                                        entries.append(entry)

                                        let timeline = Timeline(entries: entries, policy: .atEnd)
                                        completion(timeline)
        }).take(first: 1).start()
    }
}

struct DailiesCountWidgetEntry: TimelineEntry {
    var date: Date
    var widgetFamily: WidgetFamily
    
    var totalCount: Int
    var completedCount: Int
    
    var displayRemaining = false
    
    var needsCron = false
}

struct DailiesCountWidgetView : View {
    var entry: DailiesCountProvider.Entry

    var body: some View {
        VStack() {
            if entry.needsCron {
                StartDayView()
            } else if entry.completedCount == entry.totalCount {
                CompletedView()
            } else {
                let displayCount = entry.displayRemaining ? (entry.totalCount - entry.completedCount) : entry.completedCount
                CountView(completedCount: entry.completedCount, totalCount: entry.totalCount, displayCount: displayCount, displayRemaining: entry.displayRemaining)
            }
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                .padding(EdgeInsets(top: 24, leading: 0, bottom: 20, trailing: 0))
                .background(Color.widgetBackground)
            }
}

struct CountView: View {
    var completedCount: Int
    var totalCount: Int
    var displayCount: Int
    var displayRemaining: Bool
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            ProgressCircle(progress: Float(completedCount) / Float(totalCount), label: String(displayCount))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            Text(displayRemaining ? "Dailies left" : "Dailies done").foregroundColor(Color.widgetText).font(Font.system(size: 15, weight: .semibold)).multilineTextAlignment(.center)
        }
    }
}

struct CompletedView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Image("DailiesCompleted")
            Text("All done for today!").foregroundColor(Color.widgetText).font(Font.system(size: 15, weight: .semibold)).multilineTextAlignment(.center)
        }
    }
}

struct StartDayView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image("StartDayIcon")
            Text("Start a new day").foregroundColor(Color.widgetText).font(Font.system(size: 15, weight: .semibold)).multilineTextAlignment(.center)
        }
    }
}

struct ProgressCircle: View {
    var progress: Float
    var label: String
    var stroke: CGFloat = 8
    var backgroundColor = Color.progressBackground
    
    private let colors = [
        Color.barRed,
        Color.barYellow,
        Color.barBlue
    ]
    
    var body: some View {
        let color = colors[Int(progress * Float(colors.count))]
        ZStack {
            Circle()
                .stroke(lineWidth: stroke)
                .foregroundColor(backgroundColor)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: stroke, lineCap: .butt, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            Text(label).foregroundColor(Color.widgetText).font(.system(size: 30, weight: .semibold))
        }
    }
}


struct DailiesCountWidget: Widget {
    let kind: String = "DailiesCountWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: HRPGDailiesCountIntent.self,
                            provider: DailiesCountProvider()
        ) { entry in
            DailiesCountWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Count")
        .description("View how many dailies you completed today or how many are still left")
        .supportedFamilies([.systemSmall])
    }
}

struct DailiesCountWidgetPreview: PreviewProvider {
    static var previews: some View {
        DailiesCountWidgetView(entry: DailiesCountWidgetEntry(date: Date(), widgetFamily: .systemSmall, totalCount: 42, completedCount: 10))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
