//
//  EventHelper.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.03.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation

class EventHelper {
    static func setup(event: String, endDate: Date?) {
        switch event {
        case "invert":
            setupInvertedAprilFools(endDate: endDate)
        default:
            return
        }
    }
    
    static func disableAll() {
        AvatarView.imageFilters.removeAll()
    }
    
    private static func setupInvertedAprilFools(endDate: Date?) {
        AvatarView.imageFilters["pet"] = { image in
            if endDate?.compare(Date()) != .orderedDescending {
                return image
            }
            return image.inverted() ?? image
        }
    }
}
