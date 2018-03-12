//
//  QuestCollectProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol QuestCollectProtocol {
    var key: String? { get set }
    var text: String? { get set }
    var count: Int { get set }
}
