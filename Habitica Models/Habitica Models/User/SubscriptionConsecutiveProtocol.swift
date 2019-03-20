//
//  SubscriptionConsecutiveProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 23.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol SubscriptionConsecutiveProtocol {
    var hourglasses: Int { get set }
    var gemCapExtra: Int { get set }
    var count: Int { get set }
    var offset: Int { get set }
}
