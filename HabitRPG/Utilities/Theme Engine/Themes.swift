//
//  Themes.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

public struct DefaultTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.purple300 }
    public var tintColor: UIColor { return UIColor.purple400 }
    public var dimmBackgroundColor: UIColor { return UIColor.purple50 }

    public var menuHeaderBackground: UIColor { return UIColor.purple300 }
    public var menuHeaderText: UIColor { return UIColor.white }
    public var menuHeaderIcon: UIColor { return UIColor.white }
}

public struct GreenTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.green10 }
    public var tintColor: UIColor { return UIColor.green100 }
    public var dimmBackgroundColor: UIColor { return UIColor.green50 }
    
    public var tintedBackgroundColor: UIColor { return UIColor.green500 }
    public var tintedSubtleUI: UIColor { return UIColor.green500.withAlphaComponent(0.12) }
    public var tintedMainText: UIColor { return UIColor.green1 }
    public var tintedSubText: UIColor { return UIColor.green1.withAlphaComponent(0.7) }
    public var tintedMainUI: UIColor { return UIColor.green100 }
    public var tintedSubUI: UIColor { return UIColor.green10 }
    public var tintedDetailsUI: UIColor { return UIColor.green1 }

    public var menuHeaderBackground: UIColor { return UIColor.green100 }
    public var menuHeaderText: UIColor { return UIColor.greenBlack }
    public var menuHeaderIcon: UIColor { return UIColor.green1 }
    public var menuHeaderBubble: UIColor { return UIColor.green500 }
    public var menuHeaderBubbleText: UIColor { return UIColor.green1 }
    public var menuBackground: UIColor { return UIColor.greenWhite }
    public var menuIcon: UIColor { return UIColor.green10 }
    public var menuText: UIColor { return UIColor.green1 }
    public var menuLockBackground: UIColor { return UIColor.green10.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.green10 }
    public var menuPillBackground: UIColor { return UIColor.green300 }
    public var menuPillText: UIColor { return UIColor.green1 }
}

public struct BlueTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.blue10 }
    public var tintColor: UIColor { return UIColor.blue100 }
    public var dimmBackgroundColor: UIColor { return UIColor.blue50 }
    
    public var tintedBackgroundColor: UIColor { return UIColor.blue500 }
    public var tintedSubtleUI: UIColor { return UIColor.blue500.withAlphaComponent(0.12) }
    public var tintedMainText: UIColor { return UIColor.blue1 }
    public var tintedSubText: UIColor { return UIColor.blue1.withAlphaComponent(0.7) }
    public var tintedMainUI: UIColor { return UIColor.blue100 }
    public var tintedSubUI: UIColor { return UIColor.blue10 }
    public var tintedDetailsUI: UIColor { return UIColor.blue1 }

    public var menuHeaderBackground: UIColor { return UIColor.blue100 }
    public var menuHeaderText: UIColor { return UIColor.yellowBlack }
    public var menuHeaderIcon: UIColor { return UIColor.blue1 }
    public var menuHeaderBubble: UIColor { return UIColor.blue500 }
    public var menuHeaderBubbleText: UIColor { return UIColor.blue1 }
    public var menuBackground: UIColor { return UIColor.blueWhite }
    public var menuIcon: UIColor { return UIColor.blue10 }
    public var menuText: UIColor { return UIColor.blue1 }
    public var menuLockBackground: UIColor { return UIColor.blue10.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.blue10 }
    public var menuPillBackground: UIColor { return UIColor.blue300 }
    public var menuPillText: UIColor { return UIColor.blue1 }
}

public struct RedTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.red10 }
    public var tintColor: UIColor { return UIColor.red100 }
    public var dimmBackgroundColor: UIColor { return UIColor.red50 }
    
    public var tintedBackgroundColor: UIColor { return UIColor.red500 }
    public var tintedSubtleUI: UIColor { return UIColor.red500.withAlphaComponent(0.12) }
    public var tintedMainText: UIColor { return UIColor.red1 }
    public var tintedSubText: UIColor { return UIColor.red1.withAlphaComponent(0.7) }
    public var tintedMainUI: UIColor { return UIColor.red100 }
    public var tintedSubUI: UIColor { return UIColor.red10 }
    public var tintedDetailsUI: UIColor { return UIColor.red1 }

    public var menuHeaderBackground: UIColor { return UIColor.red100 }
    public var menuHeaderText: UIColor { return UIColor.yellowBlack }
    public var menuHeaderIcon: UIColor { return UIColor.red1 }
    public var menuHeaderBubble: UIColor { return UIColor.red500 }
    public var menuHeaderBubbleText: UIColor { return UIColor.red1 }
    public var menuBackground: UIColor { return UIColor.redWhite }
    public var menuIcon: UIColor { return UIColor.red10 }
    public var menuText: UIColor { return UIColor.red1 }
    public var menuLockBackground: UIColor { return UIColor.red10.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.red10 }
    public var menuPillBackground: UIColor { return UIColor.red300 }
    public var menuPillText: UIColor { return UIColor.red1 }
}

public struct TealTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.teal10 }
    public var tintColor: UIColor { return UIColor.teal100 }
    public var dimmBackgroundColor: UIColor { return UIColor.teal50 }
    
    public var tintedBackgroundColor: UIColor { return UIColor.teal500 }
    public var tintedSubtleUI: UIColor { return UIColor.teal500.withAlphaComponent(0.12) }
    public var tintedMainText: UIColor { return UIColor.teal1 }
    public var tintedSubText: UIColor { return UIColor.teal1.withAlphaComponent(0.7) }
    public var tintedMainUI: UIColor { return UIColor.teal100 }
    public var tintedSubUI: UIColor { return UIColor.teal10 }
    public var tintedDetailsUI: UIColor { return UIColor.teal1 }

    public var menuHeaderBackground: UIColor { return UIColor.teal100 }
    public var menuHeaderText: UIColor { return UIColor.tealBlack }
    public var menuHeaderIcon: UIColor { return UIColor.teal1 }
    public var menuHeaderBubble: UIColor { return UIColor.teal500 }
    public var menuHeaderBubbleText: UIColor { return UIColor.teal1 }
    public var menuBackground: UIColor { return UIColor.tealWhite }
    public var menuIcon: UIColor { return UIColor.teal10 }
    public var menuText: UIColor { return UIColor.teal1 }
    public var menuLockBackground: UIColor { return UIColor.teal10.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.teal10 }
    public var menuPillBackground: UIColor { return UIColor.teal300 }
    public var menuPillText: UIColor { return UIColor.teal1 }
}

public struct MaroonTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.maroon10 }
    public var tintColor: UIColor { return UIColor.maroon100 }
    public var dimmBackgroundColor: UIColor { return UIColor.maroon50 }
    
    public var tintedBackgroundColor: UIColor { return UIColor.maroon500 }
    public var tintedSubtleUI: UIColor { return UIColor.maroon500.withAlphaComponent(0.12) }
    public var tintedMainText: UIColor { return UIColor.red1 }
    public var tintedSubText: UIColor { return UIColor.red1.withAlphaComponent(0.7) }
    public var tintedMainUI: UIColor { return UIColor.maroon100 }
    public var tintedSubUI: UIColor { return UIColor.maroon10 }
    public var tintedDetailsUI: UIColor { return UIColor.red1 }

    public var menuHeaderBackground: UIColor { return UIColor.maroon100 }
    public var menuHeaderText: UIColor { return UIColor.redBlack }
    public var menuHeaderIcon: UIColor { return UIColor.red1 }
    public var menuHeaderBubble: UIColor { return UIColor.maroon500 }
    public var menuHeaderBubbleText: UIColor { return UIColor.red1 }
    public var menuBackground: UIColor { return UIColor.redWhite }
    public var menuIcon: UIColor { return UIColor.maroon10 }
    public var menuText: UIColor { return UIColor.red1 }
    public var menuLockBackground: UIColor { return UIColor.maroon10.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.maroon10 }
    public var menuPillBackground: UIColor { return UIColor.maroon500 }
    public var menuPillText: UIColor { return UIColor.red1 }
}

public struct OrangeTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.orange10 }
    public var tintColor: UIColor { return UIColor.orange50 }
    public var dimmBackgroundColor: UIColor { return UIColor.orange50 }
    
    public var tintedBackgroundColor: UIColor { return UIColor.orange500 }
    public var tintedSubtleUI: UIColor { return UIColor.orange500.withAlphaComponent(0.12) }
    public var tintedMainText: UIColor { return UIColor.orange1 }
    public var tintedSubText: UIColor { return UIColor.orange1.withAlphaComponent(0.7) }
    public var tintedMainUI: UIColor { return UIColor.orange100 }
    public var tintedSubUI: UIColor { return UIColor.orange10 }
    public var tintedDetailsUI: UIColor { return UIColor.orange1 }

    public var menuHeaderBackground: UIColor { return UIColor.orange100 }
    public var menuHeaderText: UIColor { return UIColor.orangeBlack }
    public var menuHeaderIcon: UIColor { return UIColor.orange1 }
    public var menuHeaderBubble: UIColor { return UIColor.orange500 }
    public var menuHeaderBubbleText: UIColor { return UIColor.orange1 }
    public var menuBackground: UIColor { return UIColor.orangeWhite }
    public var menuIcon: UIColor { return UIColor.orange10 }
    public var menuText: UIColor { return UIColor.orange1 }
    public var menuLockBackground: UIColor { return UIColor.orange10.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.orange10 }
    public var menuPillBackground: UIColor { return UIColor.orange300 }
    public var menuPillText: UIColor { return UIColor.orange1 }
}

public struct YellowTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.yellow10 }
    public var tintColor: UIColor { return UIColor.yellow10 }
    public var dimmBackgroundColor: UIColor { return UIColor.yellow10 }
    
    public var tintedBackgroundColor: UIColor { return UIColor.yellow500 }
    public var tintedSubtleUI: UIColor { return UIColor.yellow500.withAlphaComponent(0.12) }
    public var tintedMainText: UIColor { return UIColor.yellow1 }
    public var tintedSubText: UIColor { return UIColor.yellow1.withAlphaComponent(0.7) }
    public var tintedMainUI: UIColor { return UIColor.yellow100 }
    public var tintedSubUI: UIColor { return UIColor.yellow10 }
    public var tintedDetailsUI: UIColor { return UIColor.yellow1 }

    public var menuHeaderBackground: UIColor { return UIColor.yellow100 }
    public var menuHeaderText: UIColor { return UIColor.yellowBlack }
    public var menuHeaderIcon: UIColor { return UIColor.yellow1 }
    public var menuHeaderBubble: UIColor { return UIColor.yellow500 }
    public var menuHeaderBubbleText: UIColor { return UIColor.yellow1 }
    public var menuBackground: UIColor { return UIColor.yellowWhite }
    public var menuIcon: UIColor { return UIColor.yellow10 }
    public var menuText: UIColor { return UIColor.yellow1 }
    public var menuLockBackground: UIColor { return UIColor.yellow10.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.yellow10 }
    public var menuPillBackground: UIColor { return UIColor.yellow300 }
    public var menuPillText: UIColor { return UIColor.yellow1 }
}

public struct GrayTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.gray50 }
    public var tintColor: UIColor { return UIColor.gray100 }
    public var dimmBackgroundColor: UIColor { return UIColor.gray50 }

    public var menuHeaderBackground: UIColor { return UIColor.gray50 }
    public var menuHeaderText: UIColor { return UIColor.white }
    public var menuHeaderIcon: UIColor { return UIColor.white }
    public var menuHeaderBubble: UIColor { return UIColor.gray10 }
    public var menuHeaderBubbleText: UIColor { return UIColor.white }
    public var menuBackground: UIColor { return UIColor.gray700 }
    public var menuIcon: UIColor { return UIColor.gray100 }
    public var menuText: UIColor { return UIColor.gray10 }
    public var menuLockBackground: UIColor { return UIColor.gray200.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.gray200 }
    public var menuPillBackground: UIColor { return UIColor.gray400 }
    public var menuPillText: UIColor { return UIColor.black }
}

public struct DysheatenerTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor("#410F2A") }
    public var tintColor: UIColor { return UIColor("#931F4D") }
}

public struct DefaultDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.purple400 }
    public var tintColor: UIColor { return UIColor.purple600 }
    public var fixedTintColor: UIColor { return UIColor.purple400 }
    public var dimmBackgroundColor: UIColor { return UIColor.purple10 }
    public var taskOverlayTint: UIColor { return UIColor.blackPurple50.withAlphaComponent(0.15) }
    public var segmentedTintColor: UIColor { return UIColor.purple500 }

    public var menuHeaderBackground: UIColor { return UIColor.purple300 }
    public var menuHeaderText: UIColor { return UIColor.white }
    public var menuHeaderIcon: UIColor { return UIColor.white }
}

public struct GreenDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.green10 }
    public var tintColor: UIColor { return UIColor.green50 }
    public var dimmBackgroundColor: UIColor { return UIColor.green10 }
    
    public var tintedBackgroundColor: UIColor { return UIColor.green500 }
    public var tintedSubtleUI: UIColor { return UIColor.green500.withAlphaComponent(0.12) }
    public var tintedMainText: UIColor { return UIColor.green500 }
    public var tintedSubText: UIColor { return UIColor.green500 }
    public var tintedMainUI: UIColor { return UIColor.green100 }
    public var tintedSubUI: UIColor { return UIColor.green10 }
    public var tintedDetailsUI: UIColor { return UIColor.green1 }

    public var menuHeaderBackground: UIColor { return UIColor.green100 }
    public var menuHeaderText: UIColor { return UIColor.greenBlack }
    public var menuHeaderIcon: UIColor { return UIColor.green1 }
    public var menuHeaderBubble: UIColor { return UIColor.green500 }
    public var menuHeaderBubbleText: UIColor { return UIColor.green1 }
    public var menuBackground: UIColor { return UIColor.greenBlack }
    public var menuIcon: UIColor { return UIColor.green500 }
    public var menuText: UIColor { return UIColor.greenWhite }
    public var menuLockBackground: UIColor { return UIColor.green500.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.green500 }
    public var menuPillBackground: UIColor { return UIColor.green300 }
    public var menuPillText: UIColor { return UIColor.green1 }
}

public struct BlueDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.blue10 }
    public var tintColor: UIColor { return UIColor.blue50 }
    public var dimmBackgroundColor: UIColor { return UIColor.blue10 }
    
    public var tintedBackgroundColor: UIColor { return UIColor.blue500 }
    public var tintedSubtleUI: UIColor { return UIColor.blue500.withAlphaComponent(0.12) }
    public var tintedMainText: UIColor { return UIColor.blue500 }
    public var tintedSubText: UIColor { return UIColor.blue500 }
    public var tintedMainUI: UIColor { return UIColor.blue100 }
    public var tintedSubUI: UIColor { return UIColor.blue10 }
    public var tintedDetailsUI: UIColor { return UIColor.blue1 }

    public var menuHeaderBackground: UIColor { return UIColor.blue100 }
    public var menuHeaderText: UIColor { return UIColor.yellowBlack }
    public var menuHeaderIcon: UIColor { return UIColor.blue1 }
    public var menuHeaderBubble: UIColor { return UIColor.blue500 }
    public var menuHeaderBubbleText: UIColor { return UIColor.blue1 }
    public var menuBackground: UIColor { return UIColor.blueBlack }
    public var menuIcon: UIColor { return UIColor.blue500 }
    public var menuText: UIColor { return UIColor.blueWhite }
    public var menuLockBackground: UIColor { return UIColor.blue500.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.blue500 }
    public var menuPillBackground: UIColor { return UIColor.blue300 }
    public var menuPillText: UIColor { return UIColor.blue1 }
}

public struct RedDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.red10 }
    public var tintColor: UIColor { return UIColor.red50 }
    public var dimmBackgroundColor: UIColor { return UIColor.red10 }
    
    public var tintedBackgroundColor: UIColor { return UIColor.red500 }
    public var tintedSubtleUI: UIColor { return UIColor.red500.withAlphaComponent(0.12) }
    public var tintedMainText: UIColor { return UIColor.red500 }
    public var tintedSubText: UIColor { return UIColor.red500 }
    public var tintedMainUI: UIColor { return UIColor.red100 }
    public var tintedSubUI: UIColor { return UIColor.red10 }
    public var tintedDetailsUI: UIColor { return UIColor.red1 }

    public var menuHeaderBackground: UIColor { return UIColor.red100 }
    public var menuHeaderText: UIColor { return UIColor.yellowBlack }
    public var menuHeaderIcon: UIColor { return UIColor.red1 }
    public var menuHeaderBubble: UIColor { return UIColor.red500 }
    public var menuHeaderBubbleText: UIColor { return UIColor.red1 }
    public var menuBackground: UIColor { return UIColor.redBlack }
    public var menuIcon: UIColor { return UIColor.red500 }
    public var menuText: UIColor { return UIColor.redWhite }
    public var menuLockBackground: UIColor { return UIColor.red500.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.red500 }
    public var menuPillBackground: UIColor { return UIColor.red300 }
    public var menuPillText: UIColor { return UIColor.red1 }
}

public struct TealDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.teal10 }
    public var tintColor: UIColor { return UIColor.teal50 }
    public var dimmBackgroundColor: UIColor { return UIColor.teal10 }
    
    public var tintedBackgroundColor: UIColor { return UIColor.teal500 }
    public var tintedSubtleUI: UIColor { return UIColor.teal500.withAlphaComponent(0.12) }
    public var tintedMainText: UIColor { return UIColor.teal500 }
    public var tintedSubText: UIColor { return UIColor.teal500 }
    public var tintedMainUI: UIColor { return UIColor.teal100 }
    public var tintedSubUI: UIColor { return UIColor.teal10 }
    public var tintedDetailsUI: UIColor { return UIColor.teal1 }

    public var menuHeaderBackground: UIColor { return UIColor.teal100 }
    public var menuHeaderText: UIColor { return UIColor.tealBlack }
    public var menuHeaderIcon: UIColor { return UIColor.teal1 }
    public var menuHeaderBubble: UIColor { return UIColor.teal500 }
    public var menuHeaderBubbleText: UIColor { return UIColor.teal1 }
    public var menuBackground: UIColor { return UIColor.tealBlack }
    public var menuIcon: UIColor { return UIColor.teal500 }
    public var menuText: UIColor { return UIColor.tealWhite }
    public var menuLockBackground: UIColor { return UIColor.teal500.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.teal500 }
    public var menuPillBackground: UIColor { return UIColor.teal300 }
    public var menuPillText: UIColor { return UIColor.teal1 }
}

public struct MaroonDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.maroon10 }
    public var tintColor: UIColor { return UIColor.maroon50 }
    public var dimmBackgroundColor: UIColor { return UIColor.maroon10 }
    
    public var tintedBackgroundColor: UIColor { return UIColor.maroon500 }
    public var tintedSubtleUI: UIColor { return UIColor.maroon500.withAlphaComponent(0.12) }
    public var tintedMainText: UIColor { return UIColor.maroon500 }
    public var tintedSubText: UIColor { return UIColor.maroon500 }
    public var tintedMainUI: UIColor { return UIColor.maroon100 }
    public var tintedSubUI: UIColor { return UIColor.maroon10 }
    public var tintedDetailsUI: UIColor { return UIColor.red1 }

    public var menuHeaderBackground: UIColor { return UIColor.maroon100 }
    public var menuHeaderText: UIColor { return UIColor.redBlack }
    public var menuHeaderIcon: UIColor { return UIColor.red1 }
    public var menuHeaderBubble: UIColor { return UIColor.maroon500 }
    public var menuHeaderBubbleText: UIColor { return UIColor.red1 }
    public var menuBackground: UIColor { return UIColor.redBlack }
    public var menuIcon: UIColor { return UIColor.maroon500 }
    public var menuText: UIColor { return UIColor.redWhite }
    public var menuLockBackground: UIColor { return UIColor.maroon500.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.maroon500 }
    public var menuPillBackground: UIColor { return UIColor.maroon500 }
    public var menuPillText: UIColor { return UIColor.red1 }
}

public struct OrangeDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.orange50 }
    public var tintColor: UIColor { return UIColor.orange50 }
    public var dimmBackgroundColor: UIColor { return UIColor.orange10 }
    
    public var tintedBackgroundColor: UIColor { return UIColor.orange500 }
    public var tintedSubtleUI: UIColor { return UIColor.orange500.withAlphaComponent(0.12) }
    public var tintedMainText: UIColor { return UIColor.orange500 }
    public var tintedSubText: UIColor { return UIColor.orange500 }
    public var tintedMainUI: UIColor { return UIColor.orange100 }
    public var tintedSubUI: UIColor { return UIColor.orange10 }
    public var tintedDetailsUI: UIColor { return UIColor.orange1 }

    public var menuHeaderBackground: UIColor { return UIColor.orange100 }
    public var menuHeaderText: UIColor { return UIColor.orangeBlack }
    public var menuHeaderIcon: UIColor { return UIColor.orange1 }
    public var menuHeaderBubble: UIColor { return UIColor.orange500 }
    public var menuHeaderBubbleText: UIColor { return UIColor.orange1 }
    public var menuBackground: UIColor { return UIColor.orangeBlack }
    public var menuIcon: UIColor { return UIColor.orange500 }
    public var menuText: UIColor { return UIColor.orangeWhite }
    public var menuLockBackground: UIColor { return UIColor.orange500.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.orange500 }
    public var menuPillBackground: UIColor { return UIColor.orange300 }
    public var menuPillText: UIColor { return UIColor.orange1 }
}

public struct YellowDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.yellow50 }
    public var tintColor: UIColor { return UIColor.yellow50 }
    public var dimmBackgroundColor: UIColor { return UIColor.yellow10 }
    
    public var tintedBackgroundColor: UIColor { return UIColor.yellow500 }
    public var tintedSubtleUI: UIColor { return UIColor.yellow500.withAlphaComponent(0.12) }
    public var tintedMainText: UIColor { return UIColor.yellow500 }
    public var tintedSubText: UIColor { return UIColor.yellow500 }
    public var tintedMainUI: UIColor { return UIColor.yellow100 }
    public var tintedSubUI: UIColor { return UIColor.yellow10 }
    public var tintedDetailsUI: UIColor { return UIColor.yellow1 }

    public var menuHeaderBackground: UIColor { return UIColor.yellow100 }
    public var menuHeaderText: UIColor { return UIColor.yellowBlack }
    public var menuHeaderIcon: UIColor { return UIColor.yellow1 }
    public var menuHeaderBubble: UIColor { return UIColor.yellow500 }
    public var menuHeaderBubbleText: UIColor { return UIColor.yellow1 }
    public var menuBackground: UIColor { return UIColor.yellowBlack }
    public var menuIcon: UIColor { return UIColor.yellow500 }
    public var menuText: UIColor { return UIColor.yellowWhite }
    public var menuLockBackground: UIColor { return UIColor.yellow500.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.yellow500 }
    public var menuPillBackground: UIColor { return UIColor.yellow300 }
    public var menuPillText: UIColor { return UIColor.yellow1 }
}

public struct GrayDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.gray50 }
    public var tintColor: UIColor { return UIColor.gray100 }
    public var dimmBackgroundColor: UIColor { return UIColor.gray10 }
    public var badgeColor: UIColor { return UIColor.gray100 }
    public var taskOverlayTint: UIColor { return UIColor.black.withAlphaComponent(0.30) }

    public var menuHeaderBackground: UIColor { return UIColor.gray50 }
    public var menuHeaderText: UIColor { return UIColor.white }
    public var menuHeaderIcon: UIColor { return UIColor.white }
    public var menuHeaderBubble: UIColor { return UIColor.gray10 }
    public var menuHeaderBubbleText: UIColor { return UIColor.white }
    public var menuBackground: UIColor { return UIColor.black }
    public var menuIcon: UIColor { return UIColor.gray300 }
    public var menuText: UIColor { return UIColor.gray700 }
    public var menuLockBackground: UIColor { return UIColor.gray500.withAlphaComponent(0.12) }
    public var menuLockIcon: UIColor { return UIColor.gray500 }
    public var menuPillBackground: UIColor { return UIColor.gray400 }
    public var menuPillText: UIColor { return UIColor.black }
}

public struct CustomTheme: Theme {
    init(baseColor: UIColor) {
        tintColor = baseColor
        if baseColor.isLight() {
            badgeColor = tintColor.darker()
        } else {
            badgeColor = tintColor.lighter()
        }

    }
    public var navbarHiddenColor: UIColor { return tintColor }
    public var backgroundTintColor: UIColor { return tintColor.darker(by: 15) }
    public var tintColor: UIColor
    public var dimmBackgroundColor: UIColor { return tintColor.darker(by: 20) }
    public var badgeColor: UIColor
}

public struct CustomDarkTheme: DarkTheme {
    init(baseColor: UIColor) {
        tintColor = baseColor.darker(by: 10)
        if baseColor.isLight() {
            badgeColor = tintColor.darker()
        } else {
            badgeColor = tintColor.lighter()
        }
    }
    public var backgroundTintColor: UIColor { return tintColor.darker(by: 30) }
    public var tintColor: UIColor
    public var dimmBackgroundColor: UIColor { return tintColor.darker(by: 20) }
    public var badgeColor: UIColor
}
