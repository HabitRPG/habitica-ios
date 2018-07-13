//
//  BaseReward.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 16.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol BaseRewardProtocol: BaseModelProtocol {
    var text: String? { get set }
    var notes: String? { get set }
    var type: String? { get set }
    var value: Float { get set }
}
