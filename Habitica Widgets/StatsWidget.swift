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

    func getSnapshot(in context: Context, completion: @escaping (UserEntry) -> Void) {
        let entry = UserEntry(date: Date(),
                              widgetFamily: context.family)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UserEntry>) -> Void) {
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

struct StatsWidgetView: View {
    var entry: Provider.Entry
    
    var padding: EdgeInsets {
        if entry.widgetFamily == .systemSmall {
            return EdgeInsets(top: 33, leading: 14, bottom: 33, trailing: 20)
        } else {
            return EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ValueBar(title: L10n.health, value: entry.health, maxValue: entry.maxHealth, color: Color.barRed, iconName: "Heart", showLabels: entry.widgetFamily != .systemSmall)
            Spacer()
            ValueBar(title: L10n.experience, value: entry.experience, maxValue: entry.maxExperience, color: Color.barYellow, iconName: "Experience", showLabels: entry.widgetFamily != .systemSmall)
            Spacer()
            ValueBar(title: "Mana", value: entry.mana, maxValue: entry.maxMana, color: Color.barBlue, iconName: "Mana", showLabels: entry.widgetFamily != .systemSmall)
            if entry.widgetFamily != .systemSmall {
                Spacer()
                HStack {
                    Text(L10n.levelNumber(entry.level)).font(.footnote).foregroundColor(Color.widgetText)
                    Spacer()
                    Image("Gold")
                    Text("\(entry.gold)".stringWithAbbreviatedNumber()).font(.footnote).foregroundColor(Color.widgetText)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                    Image("Gem")
                    Text("\(entry.gems)".stringWithAbbreviatedNumber()).font(.footnote).foregroundColor(Color.widgetText)
                }
            }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .padding(padding)
        .background(Color.widgetBackground)
            }
}

struct ValueBar: View {
    var title: String
    var value: Float
    var maxValue: Float
    var color: Color
    var iconName: String
    var showLabels = false
    
    var thickness: CGFloat {
        if showLabels {
            return 8
        } else {
            return 10
        }
    }
    
    var body: some View {
        HStack(alignment: showLabels ? .top : .center) {
            Image(iconName)
            VStack(alignment: .center, spacing: 0, content: {
                GeometryReader { metrics in
                    ZStack(alignment: .leading, content: {
                        Rectangle().fill(Color.progressBackground).frame(width: metrics.size.width, height: thickness, alignment: .leading).cornerRadius(4)
                        Rectangle().fill(color).frame(width: metrics.size.width * CGFloat(value / maxValue), height: thickness, alignment: .leading).cornerRadius(4)
                    })
                }.frame(width: .infinity, height: thickness, alignment: .center)
                if showLabels { HStack {
                    Text(title).font(.caption).foregroundColor(Color.widgetText)
                    Spacer()
                    Text("\(Int(value))/\(Int(maxValue))").font(.caption).foregroundColor(Color.widgetText)
                }.padding(.top, 2) }
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
