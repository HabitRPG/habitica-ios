//
//  ShopCategoryProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol ShopCategoryProtocol {
    var identifier: String? { get set }
    var text: String? { get set }
    var notes: String? { get set }
    var path: String? { get set }
    var purchaseAll: Bool { get set }
    var pinType: String? { get set }
    var items: [InAppRewardProtocol] { get set }
}
