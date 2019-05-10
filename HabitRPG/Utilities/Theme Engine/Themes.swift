//
//  Themes.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

public struct DefaultTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.purple300() }
    public var tintColor: UIColor { return UIColor.purple400() }
    public var dimmBackgroundColor: UIColor { return UIColor.purple50() }
}

public struct GreenTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.green10() }
    public var tintColor: UIColor { return UIColor.green100() }
    public var dimmBackgroundColor: UIColor { return UIColor.green50() }
}

public struct BlueTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.blue10() }
    public var tintColor: UIColor { return UIColor.blue100() }
    public var dimmBackgroundColor: UIColor { return UIColor.blue50() }
}

public struct RedTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.red10() }
    public var tintColor: UIColor { return UIColor.red100() }
    public var dimmBackgroundColor: UIColor { return UIColor.red50() }
}

public struct TealTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.teal10() }
    public var tintColor: UIColor { return UIColor.teal100() }
    public var dimmBackgroundColor: UIColor { return UIColor.teal50() }
}

public struct MaroonTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.darkRed10() }
    public var tintColor: UIColor { return UIColor.darkRed100() }
    public var dimmBackgroundColor: UIColor { return UIColor.darkRed50() }
}

public struct OrangeTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.orange10() }
    public var tintColor: UIColor { return UIColor.orange50() }
    public var dimmBackgroundColor: UIColor { return UIColor.orange50() }
}

public struct YellowTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.yellow5() }
    public var tintColor: UIColor { return UIColor.yellow10() }
    public var dimmBackgroundColor: UIColor { return UIColor.yellow5() }
}

public struct GrayTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.gray50() }
    public var tintColor: UIColor { return UIColor.gray100() }
    public var dimmBackgroundColor: UIColor { return UIColor.gray50() }
}

public struct DysheatenerTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor("#410F2A") }
    public var tintColor: UIColor { return UIColor("#931F4D") }
}

public struct NightTheme: DarkTheme {
    public var windowBackgroundColor: UIColor { return UIColor.purple10() }
    public var contentBackgroundColorDimmed: UIColor { return UIColor.purple10() }
    public var contentBackgroundColor: UIColor { return UIColor.purple50() }
    public var offsetBackgroundColor: UIColor { return UIColor.purple100() }
    public var backgroundTintColor: UIColor { return UIColor.purple400() }
    public var lightlyTintedBackgroundColor: UIColor { return UIColor.purple200() }
    public var tintColor: UIColor { return UIColor.purple500() }
    public var primaryTextColor: UIColor { return UIColor.purple600() }
    public var secondaryTextColor: UIColor { return UIColor.purple500() }
    public var ternaryTextColor: UIColor { return UIColor.purple400() }
    public var dimmedTextColor: UIColor { return UIColor.purple300() }
    public var separatorColor: UIColor { return UIColor.purple50() }
    public var tableviewSeparatorColor: UIColor { return UIColor.purple300() }
    public var navbarHiddenColor: UIColor { return contentBackgroundColor }
    public var dimmedColor: UIColor { return UIColor.purple200() }
    public var dimmBackgroundColor: UIColor { return UIColor.purple10() }
    public var taskOverlayTint: UIColor { return UIColor.blackPurple50().withAlphaComponent(0.15) }
}

public struct DarkNightTheme: DarkTheme {
    public var windowBackgroundColor: UIColor { return UIColor.blackPurple100().darker(by: 6) }
    public var contentBackgroundColorDimmed: UIColor { return UIColor.blackPurple100().darker(by: 7) }
    public var contentBackgroundColor: UIColor { return UIColor.blackPurple50() }
    public var offsetBackgroundColor: UIColor { return UIColor.blackPurple100() }
    public var lightlyTintedBackgroundColor: UIColor { return UIColor.gray300() }
    public var backgroundTintColor: UIColor { return UIColor.gray400() }
    public var tintColor: UIColor { return UIColor.gray600() }
    public var primaryTextColor: UIColor { return UIColor.gray700() }
    public var secondaryTextColor: UIColor { return UIColor.gray600() }
    public var ternaryTextColor: UIColor { return UIColor.gray500() }
    public var dimmedTextColor: UIColor { return UIColor.gray200() }
    public var separatorColor: UIColor { return UIColor.gray10() }
    public var tableviewSeparatorColor: UIColor { return UIColor.gray100() }
    public var navbarHiddenColor: UIColor { return contentBackgroundColor }
    public var dimmedColor: UIColor { return UIColor.gray200() }
    public var dimmBackgroundColor: UIColor { return UIColor.gray50() }
    public var badgeColor: UIColor { return UIColor.gray200() }
    public var taskOverlayTint: UIColor { return UIColor.blackPurple50().withAlphaComponent(0.15) }
}

public struct TrueBlackTheme: DarkTheme {
    public var windowBackgroundColor: UIColor { return UIColor.black }
    public var contentBackgroundColorDimmed: UIColor { return UIColor.blackPurple50().lighter(by: 2) }
    public var contentBackgroundColor: UIColor { return UIColor.black }
    public var offsetBackgroundColor: UIColor { return UIColor.blackPurple50() }
    public var backgroundTintColor: UIColor { return UIColor.gray300() }
    public var tintColor: UIColor { return UIColor.gray600() }
    public var primaryTextColor: UIColor { return UIColor.gray700() }
    public var secondaryTextColor: UIColor { return UIColor.gray600() }
    public var ternaryTextColor: UIColor { return UIColor.gray500() }
    public var dimmedTextColor: UIColor { return UIColor.gray200() }
    public var separatorColor: UIColor { return UIColor.gray10() }
    public var tableviewSeparatorColor: UIColor { return UIColor.gray200() }
    public var navbarHiddenColor: UIColor { return contentBackgroundColor }
    public var dimmedColor: UIColor { return UIColor.gray200() }
    public var dimmBackgroundColor: UIColor { return UIColor.gray10() }
    public var badgeColor: UIColor { return UIColor.gray100() }
    public var taskOverlayTint: UIColor { return UIColor.black.withAlphaComponent(0.15) }
}
