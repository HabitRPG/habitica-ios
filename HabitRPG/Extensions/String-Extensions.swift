//
//  String-Extensions.swift
//  Habitica
//
//  Created by Phillip on 18.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

extension String {

    //https://gist.github.com/zhjuncai/6af27ca9649126dd326c
    func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.width
    }
    
    func stringWithAbbreviatedNumber(roundingIncrement: Double = 0.01) -> String {
        guard var value = Double(self) else {
            return ""
        }
        var counter = 0
        while value >= 1000.0 {
            counter += 1
            value /= 1000
        }
        
        let formatter = NumberFormatter()
        formatter.roundingIncrement = roundingIncrement as NSNumber
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
    
    public static func forTaskQuality(task: TaskProtocol) -> String {
        let taskValue = task.value
        if taskValue < -20 {
            return L10n.Tasks.Quality.worst
        } else if taskValue < -10 {
            return L10n.Tasks.Quality.worse
        } else if taskValue < -1 {
            return L10n.Tasks.Quality.bad
        } else if taskValue < 1 {
            return L10n.Tasks.Quality.neutral
        } else if taskValue < 5 {
            return L10n.Tasks.Quality.good
        } else if taskValue < 10 {
            return L10n.Tasks.Quality.better
        } else {
            return L10n.Tasks.Quality.best
        }
    }
    
    func stripHTML() -> String {
        return replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
