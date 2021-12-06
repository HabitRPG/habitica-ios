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
}

extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
