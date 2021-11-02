//
//  AppIconName.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.10.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation

enum AppIconName: String {
    case defaultTheme = "Purple (Default)"
    case purpleAlt = "Purple Alternative"
    case maroon = "Maroon"
    case red = "Red"
    case orange = "Orange"
    case yellow = "Yellow"
    case blue = "Blue"
    case green = "Green"
    case teal = "Teal"
    case black = "Black"
    case maroonAlt = "Maroon Alternative"
    case redAlt = "Red Alternative"
    case orangeAlt = "Orange Alternative"
    case yellowAlt = "Yellow Alternative"
    case blueAlt = "Blue Alternative"
    case greenAlt = "Green Alternative"
    case tealAlt = "Teal Alternative"
    case blackAlt = "Black Alternative"
    case purpleAltBlack = "Purple Alternative Black"
    case maroonAltBlack = "Maroon Alternative Black"
    case redAltBlack = "Red Alternative Black"
    case orangeAltBlack = "Orange Alternative Black"
    case yellowAltBlack = "Yellow Alternative Black"
    case blueAltBlack = "Blue Alternative Black"
    case greenAltBlack = "Green Alternative Black"
    case tealAltBlack = "Teal Alternative Black"
    case blackAltBlack = "Black Alternative Black"
    case prideHabitica = "Pride"
    case prideHabiticaAlt = "Pride Alternative"
    case prideHabiticaAltBlack = "Pride Alternative Black"

    var fileName: String? {
        switch self {
        case .defaultTheme:
            return nil
        case.purpleAlt:
            return "PurpleAlt"
        case .prideHabitica:
            return "PrideHabitica"
        case .prideHabiticaAlt:
            return "PrideHabiticaAlt"
        case .prideHabiticaAltBlack:
            return "PrideHabiticaAltBlack"
        case .maroon:
            return "Maroon"
        case .red:
            return "Red"
        case .orange:
            return "Orange"
        case .yellow:
            return "Yellow"
        case .blue:
            return "Blue"
        case .teal:
            return "Teal"
        case .green:
            return "Green"
        case .black:
            return "Black"
        case .maroonAlt:
            return "MaroonAlt"
        case .redAlt:
            return "RedAlt"
        case .orangeAlt:
            return "OrangeAlt"
        case .yellowAlt:
            return "YellowAlt"
        case .blueAlt:
            return "BlueAlt"
        case .tealAlt:
            return "TealAlt"
        case .greenAlt:
            return "GreenAlt"
        case .blackAlt:
            return "BlackAlt"
        case.purpleAltBlack:
            return "PurpleAltBlack"
        case .maroonAltBlack:
            return "MaroonAltBlack"
        case .redAltBlack:
            return "RedAltBlack"
        case .orangeAltBlack:
            return "OrangeAltBlack"
        case .yellowAltBlack:
            return "YellowAltBlack"
        case .blueAltBlack:
            return "BlueAltBlack"
        case .tealAltBlack:
            return "TealAltBlack"
        case .greenAltBlack:
            return "GreenAltBlack"
        case .blackAltBlack:
            return "BlackAltBlack"
        }
    }
    
    static var allNames: [AppIconName] {
        return [
            .defaultTheme,
            .purpleAlt,
            .purpleAltBlack,
            .maroon,
            .maroonAlt,
            .maroonAltBlack,
            .red,
            .redAlt,
            .redAltBlack,
            .orange,
            .orangeAlt,
            .orangeAltBlack,
            .yellow,
            .yellowAlt,
            .yellowAltBlack,
            .blue,
            .blueAlt,
            .blueAltBlack,
            .teal,
            .tealAlt,
            .tealAltBlack,
            .green,
            .greenAlt,
            .greenAltBlack,
            .black,
            .blackAlt,
            .blackAltBlack,
            .prideHabitica,
            .prideHabiticaAlt,
            .prideHabiticaAltBlack
        ]
    }
}
