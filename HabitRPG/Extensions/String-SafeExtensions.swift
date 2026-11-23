//
//  String-SafeExtensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 08.12.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

extension String {
    
    private static let abbreviationLookup: [Int: String] = [
        1: "k",
        2: "m",
        3: "b",
        4: "t",
        5: "p",
        6: "e",
        7: "z",
        8: "s"
    ]
    
    func stringWithAbbreviatedNumber(maximumFractionDigits: Int = 2) -> String {
        guard var value = Double(self), value.isFinite else {
            return ""
        }
        let rounding = pow(10, Double(maximumFractionDigits))
        var counter = 0
        while (value * rounding).rounded() / rounding >= 1000.0 {
            counter += 1
            value /= 1000
        }
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.numberStyle = .decimal
        let formattedValue = formatter.string(from: NSNumber(value: value)) ?? ""
        
        if let abbreviation = String.abbreviationLookup[counter] {
            return formattedValue + abbreviation
        } else {
            return formattedValue
        }
    }
    
    func stripHTML() -> String {
        return replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
