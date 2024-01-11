//
//  Color-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.10.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import SwiftUI

extension Color {
    static let widgetBackground = Color("WidgetBackground")
    static let widgetBackgroundSecondary = Color("widgetBackgroundSecondary")
    static let widgetText = Color("widgetText")
    static let widgetTextSecondary = Color("widgetTextSecondary")
    static let dailiesWidgetPurple = Color("dailiesWidgetPurple")
    static let progressBackground = Color("progressBackground")
    static let checklistBackground = Color("checklistBackground")
    static let checklistBackgroundDone = Color("checklistBackgroundDone")
    static let separator = Color("separator")
    
    static let barRed = Color(red: 1.0, green: 97.0 / 255.0, blue: 101.0 / 255.0)
    static let barOrange = Color(red: 1.0, green: 148.0 / 255.0, blue: 76.0 / 255.0)
    static let barYellow = Color(red: 1.0, green: 190.0 / 255.0, blue: 93.0 / 255.0)
    static let barGreen = Color(red: 36.0 / 255.0, green: 204.0 / 255.0, blue: 143.0 / 255.0)
    static let barTeal = Color(red: 59.0 / 255.0, green: 202.0 / 255.0, blue: 215.0 / 255.0)
    static let barBlue = Color(red: 80.0 / 255.0, green: 181.0 / 255.0, blue: 233.0 / 255.0)
    static let barPurple = Color(red: 146.0 / 255.0, green: 92.0 / 255.0, blue: 243.0 / 255.0)
    static let barGray = Color(red: 52.0 / 255.0, green: 49.0 / 255.0, blue: 58.0 / 255.0)
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
