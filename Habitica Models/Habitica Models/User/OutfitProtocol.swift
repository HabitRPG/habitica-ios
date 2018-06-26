//
//  OutfitProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol OutfitProtocol {
    var back: String? { get set }
    var body: String? { get set }
    var armor: String? { get set }
    var eyewear: String? { get set }
    var headAccessory: String? { get set }
    var head: String? { get set }
    var weapon: String? { get set }
    var shield: String? { get set }
}

public extension OutfitProtocol {
    
    func keyFor(type: String) -> String? {
        switch type {
        case "back":
            return back
        case "body":
            return body
        case "armor":
            return armor
        case "eyewear":
            return eyewear
        case "headAccessory":
            return headAccessory
        case "head":
            return head
        case "weapon":
            return weapon
        case "shield":
            return shield
        default:
            return nil
        }
    }
    
}
