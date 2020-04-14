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
}

public struct GreenTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.green10 }
    public var tintColor: UIColor { return UIColor.green100 }
    public var dimmBackgroundColor: UIColor { return UIColor.green50 }
}

public struct BlueTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.blue10 }
    public var tintColor: UIColor { return UIColor.blue100 }
    public var dimmBackgroundColor: UIColor { return UIColor.blue50 }
}

public struct RedTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.red10 }
    public var tintColor: UIColor { return UIColor.red100 }
    public var dimmBackgroundColor: UIColor { return UIColor.red50 }
}

public struct TealTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.teal10 }
    public var tintColor: UIColor { return UIColor.teal100 }
    public var dimmBackgroundColor: UIColor { return UIColor.teal50 }
}

public struct MaroonTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.maroon10 }
    public var tintColor: UIColor { return UIColor.maroon100 }
    public var dimmBackgroundColor: UIColor { return UIColor.maroon50 }
}

public struct OrangeTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.orange10 }
    public var tintColor: UIColor { return UIColor.orange50 }
    public var dimmBackgroundColor: UIColor { return UIColor.orange50 }
}

public struct YellowTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.yellow5 }
    public var tintColor: UIColor { return UIColor.yellow10 }
    public var dimmBackgroundColor: UIColor { return UIColor.yellow5 }
}

public struct GrayTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.gray50 }
    public var tintColor: UIColor { return UIColor.gray100 }
    public var dimmBackgroundColor: UIColor { return UIColor.gray50 }
}

public struct DysheatenerTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor("#410F2A") }
    public var tintColor: UIColor { return UIColor("#931F4D") }
}

public struct DefaultDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.purple300 }
    public var tintColor: UIColor { return UIColor.purple500 }
    public var dimmBackgroundColor: UIColor { return UIColor.purple10 }
    public var taskOverlayTint: UIColor { return UIColor.blackPurple50.withAlphaComponent(0.15) }
    public var segmentedTintColor: UIColor { return UIColor.purple500 }
}

public struct GreenDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.green10 }
    public var tintColor: UIColor { return UIColor.green50 }
    public var dimmBackgroundColor: UIColor { return UIColor.green10 }
}

public struct BlueDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.blue10 }
    public var tintColor: UIColor { return UIColor.blue50 }
    public var dimmBackgroundColor: UIColor { return UIColor.blue10 }
}

public struct RedDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.red10 }
    public var tintColor: UIColor { return UIColor.red50 }
    public var dimmBackgroundColor: UIColor { return UIColor.red10 }
}

public struct TealDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.teal10 }
    public var tintColor: UIColor { return UIColor.teal50 }
    public var dimmBackgroundColor: UIColor { return UIColor.teal10 }
}

public struct MaroonDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.maroon10 }
    public var tintColor: UIColor { return UIColor.maroon50 }
    public var dimmBackgroundColor: UIColor { return UIColor.maroon10 }
}

public struct OrangeDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.orange50 }
    public var tintColor: UIColor { return UIColor.orange50 }
    public var dimmBackgroundColor: UIColor { return UIColor.orange10 }
}

public struct YellowDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.yellow50 }
    public var tintColor: UIColor { return UIColor.yellow50 }
    public var dimmBackgroundColor: UIColor { return UIColor.yellow5 }
}

public struct GrayDarkTheme: DarkTheme {
    public var backgroundTintColor: UIColor { return UIColor.gray50 }
    public var tintColor: UIColor { return UIColor.gray100 }
    public var dimmBackgroundColor: UIColor { return UIColor.gray10 }
    public var badgeColor: UIColor { return UIColor.gray100 }
    public var taskOverlayTint: UIColor { return UIColor.black.withAlphaComponent(0.30) }
}
