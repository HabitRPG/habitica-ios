//
//  AvatarWidget.swift
//  Habitica WidgetsExtension
//
//  Created by Phillip Thelen on 07.10.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import WidgetKit
import SwiftUI
import Habitica_Models
import URLImage

private let viewOrder = [
    "background",
    "mount-body",
    "chair",
    "back",
    "skin",
    "shirt",
    "head_0",
    "armor",
    "body",
    "hair-bangs",
    "hair-base",
    "hair-mustache",
    "hair-beard",
    "eyewear",
    "head",
    "head-accessory",
    "hair-flower",
    "shield",
    "weapon",
    "visual-buff",
    "mount-head",
    "zzz",
    "knockout",
    "pet"
]

struct AvatarProvider: TimelineProvider {
    func placeholder(in context: Context) -> AvatarEntry {
        AvatarEntry(date: Date(),
                  widgetFamily: context.family, imageNames: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (AvatarEntry) -> ()) {
        let entry = AvatarEntry(date: Date(),
                              widgetFamily: context.family, imageNames: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AvatarEntry>) -> ()) {
        var entries: [AvatarEntry] = []
        TaskManager.shared.getUser().on(value: { user in
            let avatar = AvatarViewModel(avatar: user)
            let viewDictionary = avatar.getViewDictionary(showsBackground: true, showsMount: false, showsPet: false, isFainted: false, ignoreSleeping: false)
            let nameDictionary = avatar.getFilenameDictionary(ignoreSleeping: false)
            var names = [String]()
            viewOrder.forEach { key in
                if viewDictionary[key] ?? false {
                    if let name = nameDictionary[key], let nName = name {
                        names.append(nName)
                    }
                }
            }
            let entry = AvatarEntry(date: Date(), widgetFamily: context.family, imageNames: names)
            entries.append(entry)

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }).take(first: 1).start()
    }
}

struct AvatarEntry: TimelineEntry {
    var date: Date
    var widgetFamily: WidgetFamily
    
    var imageNames: [String]
}

struct AvatarWidgetView : View {
    var entry: AvatarProvider.Entry


    var body: some View {
        ZStack {
            ForEach(entry.imageNames, id: \.self) { name in
                if let url = URL(string: "https://habitica-assets.s3.amazonaws.com/mobileApp/images/\(name).png") {
                    AsyncImage(url: url)
                }
                }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .background(Color.widgetBackground)
            }
}

struct AvatarWidget: Widget {
    let kind: String = "AvatarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AvatarProvider()) { entry in
            AvatarWidgetView(entry: entry)
        }
        .configurationDisplayName("Habitica Avatar")
        .description("View your Habitica avatar")
        .supportedFamilies([.systemSmall])
    }
}

struct AvatarWidgetPreview: PreviewProvider {
    static var previews: some View {
        AvatarWidgetView(entry: AvatarEntry(date: Date(), widgetFamily: .systemSmall, imageNames: []))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
