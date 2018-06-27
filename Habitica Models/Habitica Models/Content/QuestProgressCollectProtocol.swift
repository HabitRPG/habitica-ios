//
//  QuestProgressCollectProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 27.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol QuestProgressCollectProtocol {
    var key: String? { get set }
    var count: Int { get set }
}
