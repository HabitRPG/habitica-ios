//
//  String-Extensions.swift
//  Habitica
//
//  Created by Phillip on 18.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation

extension String {

    //https://gist.github.com/zhjuncai/6af27ca9649126dd326c
    func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.width
    }
    
    func stringWithAbbreviatedNumber() -> String {
        guard var value = Double(self) else {
            return ""
        }
        var counter = 0
        while value >= 1000.0 {
            counter += 1
            value /= 1000
        }
        
        let formatter = NumberFormatter()
        formatter.roundingIncrement = 0.01
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
        default:
            return ""
        }
    }
    
    public static func forTaskQuality(task: HRPGTaskProtocol) -> String {
        let taskValue = task.value?.intValue ?? 0
        if taskValue < -20 {
            return NSLocalizedString("Worst", comment: "")
        } else if taskValue < -10 {
            return NSLocalizedString("Worse", comment: "")
        } else if taskValue < -1 {
            return NSLocalizedString("Bad", comment: "")
        } else if taskValue < 1 {
            return NSLocalizedString("Neutral", comment: "")
        } else if taskValue < 5 {
            return NSLocalizedString("Good", comment: "")
        } else if taskValue < 10 {
            return NSLocalizedString("Better", comment: "")
        } else {
            return NSLocalizedString("Best", comment: "")
        }
    }
}
