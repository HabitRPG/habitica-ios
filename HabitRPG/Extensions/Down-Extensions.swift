//
//  Down-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import Down

extension Down {

    func toHabiticaAttributedString() throws -> NSMutableAttributedString {
        return try self.toHabiticaAttributedString(baseFont: CustomFontMetrics.scaledSystemFont(ofSize: 15))
    }

    func toHabiticaAttributedString(baseFont: UIFont) throws -> NSMutableAttributedString {
        if self.markdownString.range(of: "[*_#\\[]", options: .regularExpression, range: nil, locale: nil) == nil {
            return unformattedAttributedString()
        }
        guard let formattedString = try? self.toAttributedString().mutableCopy() else {
            return unformattedAttributedString()
        }
        guard let string = formattedString as? NSMutableAttributedString else {
            return unformattedAttributedString()
        }
        let baseSize = baseFont.pointSize
        string.enumerateAttribute(NSAttributedStringKey.font,
                                  in: NSRange(location: 0, length: string.length),
                                  options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired,
                                  using: { (value, range, _) in
            if let oldFont = value as? UIFont {
                let font: UIFont
                let fontSizeOffset = oldFont.pointSize - 12
                if oldFont.fontName.lowercased().contains("bold") {
                    font = UIFont.boldSystemFont(ofSize: baseSize+fontSizeOffset)
                } else if oldFont.fontName.lowercased().contains("italic") {
                    font = UIFont.italicSystemFont(ofSize: baseSize+fontSizeOffset)
                } else {
                    font = UIFont.systemFont(ofSize: baseSize+fontSizeOffset)
                }
                string.addAttribute(NSAttributedStringKey.font, value: font, range: range)
            }
        })
        if string.length == 0 {
            return string
        }
        string.deleteCharacters(in: NSRange(location: string.length-1, length: 1))
        return string
    }
    
    private func unformattedAttributedString() -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self.markdownString, attributes: [.font: CustomFontMetrics.scaledSystemFont(ofSize: 15)])
    }
}

class HabiticaMarkdownHelper: NSObject {
    
    @objc
    static func toHabiticaAttributedString(_ text: String) throws -> NSMutableAttributedString {
        if let attributedString =  try? Down(markdownString: text).toHabiticaAttributedString() {
            return attributedString
        }
        return NSMutableAttributedString(string: text)
    }
}
