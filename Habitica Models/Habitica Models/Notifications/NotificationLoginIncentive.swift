//
//  NotificationLoginIncentive.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 28.07.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol NotificationLoginIncentiveProtocol: NotificationProtocol {
    var nextRewardAt: Int { get set }
    var message: String? { get set }
    var rewardKey: String? { get set }
    var rewardText: String? { get set }
}
