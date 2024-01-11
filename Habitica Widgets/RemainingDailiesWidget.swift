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

    func getSnapshot(for configuration: HRPGDailiesCountIntent, in context: Context, completion: @escaping (DailiesCountWidgetEntry) -> Void) {
        let entry = DailiesCountWidgetEntry(date: Date(), widgetFamily: context.family, totalCount: 10, completedCount: 5)
        completion(entry)
    }

    func getTimeline(for configuration: HRPGDailiesCountIntent, in context: Context, completion: @escaping (Timeline<DailiesCountWidgetEntry>) -> Void) {
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

                                            needsCron = (components.day ?? 0) > (user.preferences?.dayStart ?? 0)
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

    private var isLockscreenWidget: Bool {
        if #available(iOSApplicationExtension 16.0, *) {
            return entry.widgetFamily == .accessoryInline || entry.widgetFamily == .accessoryCircular
        } else {
            return false
        }
    }
    
    private var inlineLockScreenContent: some View {
        var text = ""
        if entry.needsCron {
            text = "Start a new day"
        } else if entry.completedCount == entry.totalCount {
            text = "\(entry.totalCount) Dailies done"
        } else {
            let displayCount = entry.displayRemaining ? (entry.totalCount - entry.completedCount) : entry.completedCount
            text = "\(displayCount)/\(entry.totalCount) \(entry.displayRemaining ? "Dailies left" : "Dailies done")"
        }
        return Text(text)
    }
    
    var body: some View {
            if isLockscreenWidget {
                if #available(iOSApplicationExtension 16.0, *) {
                    if entry.widgetFamily == .accessoryInline {
                        Label {
                            inlineLockScreenContent
                        } icon: {
                            Image("gryphon").resizable()
                        }
                    } else {
                        if entry.needsCron {
                            VStack(spacing: 2) {
                                Image("StartDayIcon").resizable().frame(width: 12, height: 12)
                                Text("Start day").font(.caption)
                            }
                            .padding(.bottom, 2)
                            .foregroundColor(Color.widgetText)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .multilineTextAlignment(.center).background(Color.widgetBackground)
                            
                        } else if entry.completedCount == entry.totalCount {
                            Gauge(value: Float(entry.completedCount) / Float(entry.totalCount)) {
                                Image("Sparkles").resizable().frame(width: 16, height: 16)
                            } currentValueLabel: {
                                Text("\(entry.completedCount) / \(entry.totalCount)")
                            }.gaugeStyle(.accessoryCircular)
                        } else {
                            Gauge(value: Float(entry.completedCount) / Float(entry.totalCount)) {
                                Image("gryphon")
                            } currentValueLabel: {
                                Text("\(entry.completedCount) / \(entry.totalCount)")
                            }.gaugeStyle(.accessoryCircular)
                        }
                    }
                }
            } else {
                Group {
                    if entry.needsCron {
                        StartDayView()
                    } else if entry.completedCount == entry.totalCount {
                        CompletedView(totalCount: entry.totalCount).padding(.bottom, 17)
                    } else {
                        let displayCount = entry.displayRemaining ? (entry.totalCount - entry.completedCount) : entry.completedCount
                        CountView(completedCount: entry.completedCount, totalCount: entry.totalCount, displayCount: displayCount, displayRemaining: entry.displayRemaining).padding(.bottom, 17)
                    }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    .widgetBackground(Color.widgetBackground)
                    .widgetURL(URL(string: "/user/tasks/daily"))
            }
    }
}

struct CountView: View {
    var completedCount: Int
    var totalCount: Int
    var displayCount: Int
    var displayRemaining: Bool
    
    private let colors = [
            Color.barRed,
            Color.barYellow,
            Color.barBlue
        ]
    
    var body: some View {
        let barColor = colors[Int((Float(completedCount) / Float(totalCount)) * Float(colors.count))]
        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            Text(String(displayCount)).font(Font.system(size: 50, weight: .semibold)).foregroundColor(Color.dailiesWidgetPurple)
            Text(displayRemaining ? "Dailies left" : "Dailies done").foregroundColor(Color.widgetText).font(Font.system(size: 15, weight: .semibold)).multilineTextAlignment(.center).padding(.top, -12)
            GeometryReader { geometry in
                let width = geometry.size.width
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color.progressBackground)
                        .frame(width: width, height: 7.0)
                    Rectangle()
                        .foregroundColor(barColor)
                        .frame(width: width * (CGFloat(completedCount) / CGFloat(totalCount)), height: 7.0)
                    
                }
                .cornerRadius(4.0)
            }.padding(.top, 12)
            Text(displayRemaining ? "\(completedCount) done" : "\(totalCount - completedCount) left to do").font(Font.system(size: 12)).padding(.top, 4).foregroundColor(.widgetTextSecondary)
        }
    }
}

struct CompletedView: View {
    var totalCount: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            HStack() {
                Text(String(totalCount)).font(Font.system(size: 50, weight: .semibold)).foregroundColor(Color.dailiesWidgetPurple)
                Image("Sparkles").padding(.leading, 1)
            }
            Text("Dailies done").foregroundColor(Color.widgetText).font(Font.system(size: 15, weight: .semibold)).multilineTextAlignment(.center).padding(.top, -12)
            GeometryReader { geometry in
                let width = geometry.size.width
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color.barPurple)
                        .frame(width: width, height: 7.0)
                    
                }
                .cornerRadius(4.0)
            }.padding(.top, 12)
            Text("All done today!").font(Font.system(size: 12)).padding(.top, 4).foregroundColor(.widgetTextSecondary)
        }
    }
}

struct StartDayView: View {
    var showSpacer = true
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image("StartDayIcon")
            Text("Start a new day").foregroundColor(Color.widgetText).font(Font.system(size: 15, weight: .semibold)).multilineTextAlignment(.center)
        }
    }
}


struct DailiesCountWidget: Widget {
    let kind: String = "DailiesCountWidget"
    
    private var families: [WidgetFamily] {
        var families: [WidgetFamily] = [.systemSmall]
        if #available(iOSApplicationExtension 16.0, *) {
            families.append(.accessoryInline)
            families.append(.accessoryCircular)
        }
        return families
    }

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: HRPGDailiesCountIntent.self,
                            provider: DailiesCountProvider()
        ) { entry in
            DailiesCountWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Count")
        .description("View how many dailies you completed today or how many are still left")
        .supportedFamilies(families)
    }
}

struct DailiesCountWidgetPreview: PreviewProvider {
    static var previews: some View {
        DailiesCountWidgetView(entry: DailiesCountWidgetEntry(date: Date(), widgetFamily: .systemSmall, totalCount: 42, completedCount: 10))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        DailiesCountWidgetView(entry: DailiesCountWidgetEntry(date: Date(), widgetFamily: .systemSmall, totalCount: 42, completedCount: 42))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        DailiesCountWidgetView(entry: DailiesCountWidgetEntry(date: Date(), widgetFamily: .systemSmall, totalCount: 42, completedCount: 10, needsCron: true))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        if #available(iOSApplicationExtension 16.0, *) {
            DailiesCountWidgetView(entry: DailiesCountWidgetEntry(date: Date(), widgetFamily: .accessoryInline, totalCount: 42, completedCount: 10))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
            DailiesCountWidgetView(entry: DailiesCountWidgetEntry(date: Date(), widgetFamily: .accessoryInline, totalCount: 42, completedCount: 42))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
            DailiesCountWidgetView(entry: DailiesCountWidgetEntry(date: Date(), widgetFamily: .accessoryInline, totalCount: 42, completedCount: 10, needsCron: true))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
            
            
                DailiesCountWidgetView(entry: DailiesCountWidgetEntry(date: Date(), widgetFamily: .accessoryCircular, totalCount: 42, completedCount: 10))
                    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                DailiesCountWidgetView(entry: DailiesCountWidgetEntry(date: Date(), widgetFamily: .accessoryCircular, totalCount: 42, completedCount: 42))
                    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                DailiesCountWidgetView(entry: DailiesCountWidgetEntry(date: Date(), widgetFamily: .accessoryCircular, totalCount: 42, completedCount: 10, needsCron: true))
                    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        }
    }
}
