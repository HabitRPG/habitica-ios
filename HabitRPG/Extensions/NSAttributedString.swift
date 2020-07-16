//
//  NSAttributedString.swift
//  Habitica
//
//  Created by Phillip Thelen on 19.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

extension NSAttributedString {
    static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(left)
        result.append(right)
        return result
    }

}

extension NSMutableAttributedString {
    func addAttributesToSubstring(string: String, attributes: [NSAttributedString.Key: Any]) {
        let range = (self.string as NSString).range(of: string)
        if range.length > 0 {
             addAttributes(attributes, range: range)
        }
    }
}
