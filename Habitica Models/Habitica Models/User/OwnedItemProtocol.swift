//
//  OwnedQuestProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 28.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol OwnedItemProtocol {
    var key: String? { get set }
    var numberOwned: Int { get set }
    var itemType: String? { get set }
}
