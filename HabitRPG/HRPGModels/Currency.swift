//
//  Currency.swift
//  Habitica
//
//  Created by Phillip on 24.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation

public enum Currency: String {
    
    case gold = "gold"
    case gem = "gems"
    case hourglass = "hourglasses"
    
    func getImage() -> UIImage {
        switch self {
        case .gold:
            return HabiticaIcons.imageOfGold
        case .gem:
            return HabiticaIcons.imageOfGem
        case .hourglass:
            return HabiticaIcons.imageOfHourglass
        }
    }
    
    func getTextColor() -> UIColor {
        if ThemeService.shared.theme.isDark {
            switch self {
            case .gold:
                return .yellow50()
            case .gem:
                return .green50()
            case .hourglass:
                return .blue50()
            }
        } else {
            switch self {
            case .gold:
                return .yellow5()
            case .gem:
                return .green10()
            case .hourglass:
                return .blue10()
            }
        }
    }
}
