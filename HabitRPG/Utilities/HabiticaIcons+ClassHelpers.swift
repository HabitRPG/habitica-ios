//
//  HabiticaIcons+ClassHelpers.swift
//  Habitica
//
//  Created by Patrick Murphy on 10/6/19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

extension HabiticaIcons {
    public class func getIcon(forClass: String) -> UIImage? {
        switch forClass {
            case "warrior":
                return HabiticaIcons.imageOfWarriorLightBg
            case "wizard":
                return  HabiticaIcons.imageOfMageLightBg
            case "healer":
                return HabiticaIcons.imageOfHealerLightBg
            case "rogue":
                return HabiticaIcons.imageOfRogueLightBg
            default:
                return nil
        }
    }
}
