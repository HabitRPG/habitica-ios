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
        case "background":
            return "icon_background_\(key)"
        case "chair":
            return "chair_\(key)"
        case "hair":
            let hairColor = preferences?.hair?.color ?? ""
            switch group {
            case "bangs":
                return "hair_bangs_\(key)_\(hairColor)"
            case "base":
                return "hair_base_\(key)_\(hairColor)"
            case "mustache":
                return "hair_mustache_\(key)_\(hairColor)"
            case "beard":
                return "hair_beard_\(key)_\(hairColor)"
            case "color":
                return "hair_bangs_1_\(key)"
            case "flower":
                return "hair_flower_\(key)"
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    func iconName(forUserPreferences preferences: PreferencesProtocol?) -> String? {
        let imagename = imageName(forUserPreferences: preferences)
        if let name = imagename {
            if name == "chair_none" {
                return "head_0"
            }
            return "Icon_\(name)"
        } else {
            return nil
        }
    }
    
    var isPurchasable: Bool {
        return price > 0 && (set?.isPurchasable ?? true)
    }
    
    var path: String {
        if let group = group {
            return "\(type ?? "").\(group).\(key ?? "")"
        } else {
            return "\(type ?? "").\(key ?? "")"
        }
    }
    
    var userPath: String {
        switch type {
        case "shirt":
            return "preferences.shirt"
        case "skin":
            return "preferences.skin"
        case "background":
            return "preferences.background"
        case "chair":
            return "preferences.chair"
        case "hair":
            switch group {
            case "bangs":
                return "preferences.hair.bangs"
            case "base":
                return "preferences.hair.base"
            case "mustache":
                return "preferences.hair.mustache"
            case "beard":
                return "preferences.hair.beard"
            case "color":
                return "preferences.hair.color"
            case "flower":
                return "preferences.hair.flower"
            default:
                return ""
            }
        default:
            return ""
        }
    }
}
