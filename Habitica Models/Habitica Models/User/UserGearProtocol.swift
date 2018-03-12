//
//  UserGearProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol UserGearProtocol {
    var equipped: OutfitProtocol? { get set }
    var costume: OutfitProtocol? { get set }
}
