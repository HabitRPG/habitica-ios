//
//  Currency.swift
//  Habitica
//
//  Created by Phillip on 24.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Foundation

public enum Currency: String {
    
    case gold = "gold"
    case gem = "gems"
    case hourglass = "hourglasses"
    
    func getImage() -> UIImage {
        switch self {
        case .gold:
            return #imageLiteral(resourceName: "gold_coin")
        case .gem:
            return #imageLiteral(resourceName: "Gem")
        case .hourglass:
            return #imageLiteral(resourceName: "hourglass")
        }
    }
    
    func getTextColor() -> UIColor {
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
