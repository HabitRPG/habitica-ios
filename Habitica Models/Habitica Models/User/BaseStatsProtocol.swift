//
//  BaseStatsProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol BaseStatsProtocol {
    var strength: Int { get set }
    var intelligence: Int { get set }
    var constitution: Int { get set }
    var perception: Int { get set }
}
