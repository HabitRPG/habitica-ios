//
//  CustomizationSetProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol CustomizationSetProtocol {
    var key: String? { get set }
    var text: String? { get set }
    var availableFrom: Date? { get set }
    var availableUntil: Date? { get set }
    var setPrice: Float { get set }
    var setItems: [CustomizationProtocol]? { get }
}

public extension CustomizationSetProtocol {
    
    var isPurchasable: Bool {
        let now = Date()
        if let availableFrom = availableFrom {
            if availableFrom > now {
                return false
            }
        }
        if let availableUntil = availableUntil {
            if availableUntil < now {
                return false
            }
        }
        return true
    }
    
}
