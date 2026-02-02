//
//  UIColor-Contributor.swift
//  Habitica
//
//  Created by Phillip Thelen on 04.05.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import UIKit

extension UIColor {
    class func contributorColor(forTier tier: Int) -> UIColor {
        if ThemeService.shared.theme.isDark {
            return darkContributorColor(forTier: tier)
        } else {
            return lightContributorColor(forTier: tier)
        }
    }
    
    class func lightContributorColor(forTier tier: Int) -> UIColor {
        switch tier {
        case 1:
            return UIColor.tier1
        case 2:
            return UIColor.tier2
        case 3:
            return UIColor.tier3
        case 4:
            return UIColor.tier4
        case 5:
            return UIColor.tier5
        case 6:
            return UIColor.tier6
        case 7:
            return UIColor.tier7
        case 8:
            return UIColor.purple400
        case 9:
            return UIColor.purple400
        default:
            return ThemeService.shared.theme.primaryTextColor
        }
    }

    class func darkContributorColor(forTier tier: Int) -> UIColor {
        switch tier {
        case 1:
            return UIColor.pink500
        case 2:
            return UIColor.maroon500
        case 3:
            return UIColor.red500
        case 4:
            return UIColor.orange500
        case 5:
            return UIColor.yellow500
        case 6:
            return UIColor.green500
        case 7:
            return UIColor.teal500
        case 8:
            return UIColor.purple500
        case 9:
            return UIColor.purple400
        default:
            return ThemeService.shared.theme.primaryTextColor
        }
    }
}
