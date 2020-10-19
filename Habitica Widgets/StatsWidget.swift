//
//  Habitica_Widgets.swift
//  Habitica Widgets
//
//  Created by Phillip Thelen on 06.10.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import WidgetKit
import SwiftUI
import Habitica_Models

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> UserEntry {
        UserEntry(date: Date(),
                  widgetFamily: context.family)
    }

    func getSnapshot(in context: Context, completion: @escaping (UserEntry) -> ()) {
        let entry = UserEntry(date: Date(),
                              widgetFamily: context.family)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UserEntry>) -> ()) {
        var entries: [UserEntry] = []
        TaskManager.shared.getUser().on(value: { user in
            let entry = UserEntry(date: Date(),
                                  widgetFamily: context.family,
                                  health: user.stats?.health ?? 0.0,
                                  maxHealth: user.stats?.maxHealth ?? 0.0,
                                  experience: user.stats?.experience ?? 0.0,
                                  maxExperience: user.stats?.toNextLevel ?? 0.0,
                                  mana: user.stats?.mana ?? 0.0,
                                  maxMana: user.stats?.maxMana ?? 0.0,
                                  level: user.stats?.level ?? 0,
                                  gold: user.stats?.gold ?? 0.0,
                                  gems: user.gemCount)
            entries.append(entry)

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }).take(first: 1).start()
    }
}

struct UserEntry: TimelineEntry {
    var date: Date
    var widgetFamily: WidgetFamily
    
    var health: Float = 42.0
    var maxHealth: Float = 50.0
    var experience: Float = 420.0
    var maxExperience: Float = 500.0
    var mana: Float = 100.0
    var maxMana: Float = 100.0
    
    var level = 42
    var gold: Float = 123.0
    var gems = 4
}

struct StatsWidgetView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ValueBar(title: entry.widgetFamily == .systemSmall ? "HP" : "Health", value: entry.health, maxValue: entry.maxHealth, color: Color.barRed, iconName: "Heart", compact: entry.widgetFamily == .systemSmall)
            ValueBar(title: entry.widgetFamily == .systemSmall ? "XP" : "Experience", value: entry.experience, maxValue: entry.maxExperience, color: Color.barYellow, iconName: "Experience", compact: entry.widgetFamily == .systemSmall)
            ValueBar(title: entry.widgetFamily == .systemSmall ? "MP" : "Mana", value: entry.mana, maxValue: entry.maxMana, color: Color.barBlue, iconName: "Mana", compact: entry.widgetFamily == .systemSmall)
            if entry.widgetFamily != .systemSmall {
                HStack {
                    Text("Level \(entry.level)").font(.footnote).foregroundColor(Color.widgetText)
                    Spacer()
                    Image("Gold")
                    Text("\(entry.gold)").font(.footnote).foregroundColor(Color.widgetText)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                    Image("Gem")
                    Text("\(entry.gems)").font(.footnote).foregroundColor(Color.widgetText)
                }
            }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                    .padding()
        .background(Color.widgetBackground)
            }
}

struct ValueBar: View {
    var title: String
    var value: Float
    var maxValue: Float
    var color: Color
    var iconName: String
    var compact = false
    var body: some View {
        HStack(alignment: .top) {
            Image(iconName)
            VStack(alignment: .leading, spacing: 0, content: {
                GeometryReader { metrics in
                    ZStack(alignment: .leading, content: {
                        Rectangle().fill(Color.progressBackground).frame(width: metrics.size.width, height: 8, alignment: .leading).cornerRadius(4)
                        Rectangle().fill(color).frame(width: metrics.size.width * CGFloat(value / maxValue), height: 8, alignment: .leading).cornerRadius(4)
                    })
                }
                HStack {
                    Text(title).font(.caption).foregroundColor(Color.widgetText)
                    Spacer()
                    Text("\(Int(value))/\(Int(maxValue))").font(.caption).foregroundColor(Color.widgetText)
                }
                if compact { Spacer() }
            })
        }
    }
}

struct StatsWidget: Widget {
    let kind: String = "StatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StatsWidgetView(entry: entry)
        }
        .configurationDisplayName("Habitica Stats")
        .description("View your Habitica stats")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct StatsWidgetPreview: PreviewProvider {
    static var previews: some View {
        StatsWidgetView(entry: UserEntry(date: Date(), widgetFamily: .systemMedium))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
