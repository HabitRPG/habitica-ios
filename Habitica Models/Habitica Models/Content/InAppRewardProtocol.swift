//
//  InAppRewardProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 16.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol InAppRewardProtocol: BaseRewardProtocol {
    var key: String? { get set }
    var eventStart: Date? { get set }
    var eventEnd: Date? { get set }
    var currency: String? { get set }
    var isSuggested: Bool { get set }
    var lastPurchased: Date? { get set }
    var locked: Bool { get set }
    var path: String? { get set }
    var pinType: String? { get set }
    var purchaseType: String? { get set }
    var imageName: String? { get set }
    var isSubscriberItem: Bool { get set }
    var unlockConditionReason: String? { get set }
    var unlockConditionIncentiveThreshold: Int { get set }
    var previous: String? { get set }
    var level: Int { get set }
    
    var category: ShopCategoryProtocol? { get }
}
