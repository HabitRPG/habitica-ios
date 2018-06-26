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
}

public struct GreenTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.green10() }
    public var tintColor: UIColor { return UIColor.green100() }
}

public struct BlueTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.blue10() }
    public var tintColor: UIColor { return UIColor.blue100() }
}

public struct RedTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.red10() }
    public var tintColor: UIColor { return UIColor.red100() }
}

public struct TealTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.teal10() }
    public var tintColor: UIColor { return UIColor.teal100() }
}

public struct MaroonTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.darkRed10() }
    public var tintColor: UIColor { return UIColor.darkRed100() }
}

public struct OrangeTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.orange10() }
    public var tintColor: UIColor { return UIColor.orange50() }
}

public struct YellowTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor.yellow5() }
    public var tintColor: UIColor { return UIColor.yellow10() }
}

public struct DysheatenerTheme: Theme {
    public var backgroundTintColor: UIColor { return UIColor("#410F2A") }
    public var tintColor: UIColor { return UIColor("#931F4D") }
}

public struct NightTheme: Theme {
    public var windowBackgroundColor: UIColor { return UIColor.purple50() }
    public var contentBackgroundColor: UIColor { return UIColor.purple100() }
    public var tintColor: UIColor { return UIColor.purple500() }
    public var primaryTextColor: UIColor { return UIColor.purple600() }
    public var secondaryTextColor: UIColor { return UIColor.purple500() }
    public var separatorColor: UIColor { return UIColor.purple50() }
}
