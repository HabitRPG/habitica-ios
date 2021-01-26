//
//  String-SafeExtensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 08.12.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

extension String {
    
    func stringWithAbbreviatedNumber(maximumFractionDigits: Int = 2) -> String {
        guard var value = Double(self) else {
            return ""
        }
        var counter = 0
        while value >= 1000.0 {
            counter += 1
            value /= 1000
        }
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.numberStyle = .decimal
        return "\(formatter.string(from: NSNumber(value: value)) ?? "")\(abbreviationFor(counter: counter))"
    }
    
    private func abbreviationFor(counter: Int) -> String {
        switch counter {
        case 1:
            return "k"
        case 2:
            return "m"
        case 3:
            return "b"
        case 4:
            return "t"
        case 5:
            return "p"
        case 6:
            return "e"
        case 7:
            return "z"
        case 8:
            return "s"
        default:
            return ""
        }
    }
    
    func stripHTML() -> String {
        return replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
