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

    func toHabiticaAttributedString(baseFont: UIFont = CustomFontMetrics.scaledSystemFont(ofSize: 15),
                                    textColor: UIColor = UIColor.gray100()) throws -> NSMutableAttributedString {
        let mentions = markdownString.components(separatedBy: " ").filter({ $0.first == "@"})
        if markdownString.range(of: "[*_#\\[<]", options: .regularExpression, range: nil, locale: nil) == nil {
            let string = NSMutableAttributedString(string: markdownString,
                                                   attributes: [.font: CustomFontMetrics.scaledSystemFont(ofSize: 15),
                                                                .foregroundColor: textColor])
            if mentions.count > 0 {
                applyMentions(string, mentions: mentions)
            }
            return string
        }
        guard let parsedString = try? toAttributedString().mutableCopy() as? NSMutableAttributedString, let string = parsedString else {
            let string = NSMutableAttributedString(string: markdownString,
                                                  attributes: [.font: CustomFontMetrics.scaledSystemFont(ofSize: 15),
                                                               .foregroundColor: textColor])
            if mentions.count > 0 {
                applyMentions(string, mentions: mentions)
            }
            return string
        }
        let baseSize = baseFont.pointSize
        string.enumerateAttribute(NSAttributedStringKey.font,
                                  in: NSRange(location: 0, length: string.length),
                                  options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired,
                                  using: { (value, range, _) in
            if let oldFont = value as? UIFont {
                let font: UIFont
                let fontSizeOffset = oldFont.pointSize - 12
                if oldFont.fontDescriptor.symbolicTraits.contains(.traitBold) && oldFont.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                    font = UIFont.boldItalicSystemFont(ofSize: baseSize+fontSizeOffset)
                } else if oldFont.fontDescriptor.symbolicTraits.contains(.traitBold) {
                    font = UIFont.boldSystemFont(ofSize: baseSize+fontSizeOffset)
                } else if oldFont.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                    font = UIFont.italicSystemFont(ofSize: baseSize+fontSizeOffset)
                } else {
                    font = UIFont.systemFont(ofSize: baseSize+fontSizeOffset)
                }
                string.addAttribute(NSAttributedStringKey.font, value: font, range: range)
                string.addAttribute(NSAttributedStringKey.foregroundColor, value: textColor, range: range)
            }
        })
        if mentions.count > 0 {
            applyMentions(string, mentions: mentions)
        }
        if string.length == 0 {
            return string
        }
        string.deleteCharacters(in: NSRange(location: string.length-1, length: 1))
        return string
    }
    
    private func applyMentions(_ string: NSMutableAttributedString, mentions: [String]) {
        let text = string.mutableString
        for mention in mentions {
            let range = text.range(of: mention)
            string.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.purple400(), range: range)
        }
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
