//
//  BaseSubscriptionViewModel.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.09.24.
//  Copyright © 2024 HabitRPG Inc. All rights reserved.
//

import SwiftUI

class BaseSubscriptionViewModel: ObservableObject {
    @Published var isSubscribing = false
    @Published var prices = [String: String]()
    @Published var titles = [String: String]()
    @Published var twelveMonthNonSalePrice: String?
    
    func calculateNonSalePrice(_ price: NSDecimalNumber, locale: Locale) {
        let quarterly = price.doubleValue
        var yearly = quarterly * 4
        if yearly.rounded() != yearly {
            yearly = yearly.rounded(.up) - 0.01
        }
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        twelveMonthNonSalePrice = formatter.string(from: yearly as NSNumber)
    }
    
    func priceFor(_ identifier: String) -> String {
        return prices[identifier] ?? ""
    }
    
    func titleFor(_ identifier: String) -> String {
        return titles[identifier] ?? ""
    }
}
