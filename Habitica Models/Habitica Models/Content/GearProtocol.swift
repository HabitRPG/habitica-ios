//
//  GearProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol GearProtocol {
    var key: String? { get set }
    var text: String? { get set }
    var notes: String? { get set }
    var value: Float { get set }
    var type: String? { get set }
    var set: String? { get set }
    var gearSet: String? { get set }
    var habitClass: String? { get set }
    var specialClass: String? { get set }
    var index: String? { get set }
    var twoHanded: Bool { get set }
    var strength: Int { get set }
    var intelligence: Int { get set }
    var perception: Int { get set }
    var constitution: Int { get set }
    var released: Bool { get set }
}

public extension GearProtocol {
    var statsText: String {
        var components = [String]()
        if intelligence > 0 {
            components.append("INT \(intelligence)")
        }
        if constitution > 0 {
            components.append("CON \(constitution)")
        }
        if strength > 0 {
            components.append("STR \(strength)")
        }
        if perception > 0 {
            components.append("PER \(perception)")
        }
        return components.joined(separator: ", ")
    }
}
