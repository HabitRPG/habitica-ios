//
//  ContributorProtocol-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

extension ContributorProtocol {
    
    var color: UIColor {
        switch level {
        case 1:
            return UIColor(red: 0.941, green: 0.380, blue: 0.549, alpha: 1.0)
        case 2:
            return UIColor(red: 0.659, green: 0.118, blue: 0.141, alpha: 1.0)
        case 3:
            return UIColor(red: 0.984, green: 0.098, blue: 0.031, alpha: 1.0)
        case 4:
            return UIColor(red: 0.992, green: 0.506, blue: 0.031, alpha: 1.0)
        case 5:
            return UIColor(red: 0.806, green: 0.779, blue: 0.284, alpha: 1.0)
        case 6:
            return UIColor(red: 0.333, green: 1.000, blue: 0.035, alpha: 1.0)
        case 7:
            return UIColor(red: 0.071, green: 0.592, blue: 1.000, alpha: 1.0)
        case 8:
            return UIColor(red: 0.055, green: 0.000, blue: 0.876, alpha: 1.0)
        case 9:
            return UIColor(red: 0.455, green: 0.000, blue: 0.486, alpha: 1.0)
        default:
            return UIColor.gray10()
        }
    }
    
}
