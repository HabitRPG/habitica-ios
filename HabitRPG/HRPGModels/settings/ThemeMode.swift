//
//  ThemeMode.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.10.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation

enum ThemeMode: String {
    case light
    case dark
    case system
    
    var niceName: String {
        switch self {
        case .light:
            return L10n.Theme.alwaysLight
        case .dark:
            return L10n.Theme.alwaysDark
        case .system:
            return L10n.Theme.followSystem
        }
    }
    
    static var allModes: [ThemeMode] {
        return [.system, .light, .dark]
    }
}
