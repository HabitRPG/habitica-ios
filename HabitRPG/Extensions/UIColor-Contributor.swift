//
//  UIColor-Contributor.swift
//  Habitica
//
//  Created by Phillip Thelen on 04.05.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation

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
            return UIColor.tierMod
        case 9:
            return UIColor.purple400
        default:
            return ThemeService.shared.theme.primaryTextColor
        }
    }
    
    class func darkContributorColor(forTier tier: Int) -> UIColor {
        switch tier {
        case 1:
            return UIColor.tier1.lighter()
        case 2:
            return UIColor.tier2.lighter()
        case 3:
            return UIColor.tier3.lighter()
        case 4:
            return UIColor.tier4.lighter()
        case 5:
            return UIColor.tier5.lighter()
        case 6:
            return UIColor.tier6.lighter()
        case 7:
            return UIColor.tier7.lighter()
        case 8:
            return UIColor.tierMod.lighter()
        case 9:
            return UIColor.purple400
        default:
            return ThemeService.shared.theme.primaryTextColor
        }
    }
}
