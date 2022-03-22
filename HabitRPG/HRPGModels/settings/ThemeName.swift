//
//  ThemeName.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.10.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import UIKit

enum ThemeName: String {
    case defaultTheme
    case blue
    case teal
    case green
    case yellow
    case orange
    case red
    case maroon
    case gray
    case custom
    
    var customColor: UIColor {
        let defaults = UserDefaults.standard
        if let hexcode = defaults.string(forKey: "customColor") {
            return UIColor(hexcode)
        }
        return .purple200
    }
    
    var themeClass: Theme {
        if ThemeService.shared.isDarkTheme == true {
            switch self {
            case .defaultTheme:
                return DefaultDarkTheme()
            case .blue:
                return BlueDarkTheme()
            case .teal:
                return TealDarkTheme()
            case .green:
                return GreenDarkTheme()
            case .yellow:
                return YellowDarkTheme()
            case .orange:
                return OrangeDarkTheme()
            case .red:
                return RedDarkTheme()
            case .maroon:
                return MaroonDarkTheme()
            case .gray:
                return GrayDarkTheme()
            case .custom:
                return CustomDarkTheme(baseColor: customColor)
            }
        } else {
            switch self {
            case .defaultTheme:
                return DefaultTheme()
            case .blue:
                return BlueTheme()
            case .teal:
                return TealTheme()
            case .green:
                return GreenTheme()
            case .yellow:
                return YellowTheme()
            case .orange:
                return OrangeTheme()
            case .red:
                return RedTheme()
            case .maroon:
                return MaroonTheme()
            case .gray:
                return GrayTheme()
            case .custom:
                return CustomTheme(baseColor: customColor)
            }
        }
    }
    
    var niceName: String {
        switch self {
        case .defaultTheme:
            return "Royal Purple (Default)"
        case .blue:
            return "Blue Task Group"
        case .teal:
            return "The real Teal"
        case .green:
            return "Against the Green"
        case .yellow:
            return "Yellow Subtask"
        case .orange:
            return "Orange you glad"
        case .red:
            return "Red Task Redemption"
        case .maroon:
            return "Maroon"
        case .gray:
            return "Plain Gray"
        case .custom:
            return "Custom Theme"
        }
    }
    
    static var allNames: [ThemeName] {
        return [
            .defaultTheme,
            .blue,
            .teal,
            .green,
            .yellow,
            .orange,
            .red,
            .maroon,
            .gray
        ]
    }
}
