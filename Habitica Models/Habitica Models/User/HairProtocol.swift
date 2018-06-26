//
//  HairProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol HairProtocol {
    var color: String? { get set }
    var bangs: Int { get set }
    var base: Int { get set }
    var beard: Int { get set }
    var mustache: Int { get set }
    var flower: Int { get set }
}
