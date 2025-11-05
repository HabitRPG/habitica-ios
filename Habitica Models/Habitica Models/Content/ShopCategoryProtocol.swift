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
    var endDate: Date? { get set }

}

public extension ShopCategoryProtocol {
    var endDates: Set<Date> {
        var dates = Set<Date>()
        if let endDate = endDate {
            dates.insert(endDate)
        }
        items.map { $0.endDate }.forEach { endDate in
            if let endDate = endDate {
                dates.insert(endDate)
            }
        }
        return dates
    }
}
