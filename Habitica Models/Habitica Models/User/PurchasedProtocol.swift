//
//  PurchasedProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 23.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol PurchasedProtocol {
    var hair: [OwnedCustomizationProtocol] { get set }
    var skin: [OwnedCustomizationProtocol] { get set }
    var shirt: [OwnedCustomizationProtocol] { get set }
    var background: [OwnedCustomizationProtocol] { get set }
    var subscriptionPlan: SubscriptionPlanProtocol? { get set }
}
