//
//  CustomizationProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol CustomizationProtocol {
    var key: String? { get set }
    var type: String? { get set }
    var group: String? { get set }
    var price: Float { get set }
    var set: CustomizationSetProtocol? { get set }
}

public extension CustomizationProtocol {
    
    func imageName(forUserPreferences preferences: PreferencesProtocol?) -> String? {
        guard let key = key else {
            return nil
        }
        switch type {
        case "shirt":
            return "\(preferences?.size ?? "")_shirt_\(key)"
        case "skin":
            return "skin_\(key)"
        default:
            return nil
        }
    }
    
}
