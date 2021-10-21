//
//  Down-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 09/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import Down
import ReactiveSwift
import UIKit

extension Down {

    func toHabiticaAttributedStringAsync(baseFont: UIFont = CustomFontMetrics.scaledSystemFont(ofSize: 15),
                                         textColor: UIColor = UIColor.gray100, onComplete: @escaping ((NSMutableAttributedString?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            let string = try? self.toHabiticaAttributedString()
            DispatchQueue.main.async {
                onComplete(string)
            }
        }
    }
    
    func toHabiticaAttributedString(baseSize: CGFloat = 15,
                                    textColor: UIColor = ThemeService.shared.theme.primaryTextColor, useAST: Bool = true, highlightUsernames: Bool = true) throws -> NSMutableAttributedString {
        let mentions = matchUsernames(text: markdownString)
        
        if markdownString.range(of: "[*_#\\[<>`]|\\A\\d+[\\.\\)]", options: .regularExpression, range: nil, locale: nil) == nil {
            let string = NSMutableAttributedString(string: markdownString,
                                                   attributes: [.font: CustomFontMetrics.scaledSystemFont(ofSize: baseSize),
                                                                .foregroundColor: textColor])
            applyParagraphStyling(string)
            applyCustomChanges(string, mentions: mentions, highlightUsernames: highlightUsernames, baseSize: baseSize)
            return string
        }
        guard let string = try? (useAST ? toAttributedString(styler: HabiticaStyler(ofSize: baseSize, textColor: textColor)) : toAttributedString()).mutableCopy() as? NSMutableAttributedString else {
            let string = NSMutableAttributedString(string: markdownString,
                                                  attributes: [.font: CustomFontMetrics.scaledSystemFont(ofSize: baseSize),
                                                               .foregroundColor: textColor])
            applyParagraphStyling(string)
            applyCustomChanges(string, mentions: mentions, highlightUsernames: highlightUsernames, baseSize: baseSize)
            return string
        }
        if !useAST {
            let scaledBaseSize = CustomFontMetrics.scaledSystemFont(ofSize: baseSize).pointSize
            string.enumerateAttribute(NSAttributedString.Key.font,
                                      in: NSRange(location: 0, length: string.length),
                                      options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired,
                                      using: { (value, range, _) in
                                        if let oldFont = value as? UIFont {
                                            let font: UIFont
                                            let fontSizeOffset = oldFont.pointSize - 12
                                            if oldFont.fontDescriptor.symbolicTraits.contains(.traitBold) && oldFont.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                                                font = UIFont.boldItalicSystemFont(ofSize: scaledBaseSize+fontSizeOffset)
                                            } else if oldFont.fontDescriptor.symbolicTraits.contains(.traitBold) {
                                                font = UIFont.boldSystemFont(ofSize: scaledBaseSize+fontSizeOffset)
                                            } else if oldFont.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                                                font = UIFont.italicSystemFont(ofSize: scaledBaseSize+fontSizeOffset)
                                            } else {
                                                font = UIFont.systemFont(ofSize: scaledBaseSize+fontSizeOffset)
                                            }
                                            string.addAttribute(NSAttributedString.Key.font, value: font, range: range)
                                            string.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: range)
                                        }
            })
        }
        applyCustomChanges(string, mentions: mentions, highlightUsernames: highlightUsernames, baseSize: baseSize)

        if !useAST {
            if string.length == 0 {
                return string
            }
            string.deleteCharacters(in: NSRange(location: string.length-1, length: 1))
        }
        return string
    }
    
    private func applyCustomChanges(_ string: NSMutableAttributedString, mentions: [String], highlightUsernames: Bool, baseSize: CGFloat) {
        if mentions.isEmpty == false && highlightUsernames {
            applyMentions(string, mentions: mentions)
        }
        applyCustomEmoji(string, size: baseSize)
        
        var range = string.mutableString.range(of: "<br>")
        while range.length > 0 {
            string.replaceCharacters(in: range, with: "\n")
            range = string.mutableString.range(of: "<br>")
        }
    }
    
    private func applyMentions(_ string: NSMutableAttributedString, mentions: [String]) {
        let text = string.mutableString
        for mention in mentions {
            let range = text.range(of: String(mention))
            string.addAttribute(.foregroundColor, value: UIColor.purple400, range: range)
        }
    }
    
    private func applyCustomEmoji(_ string: NSMutableAttributedString, size: CGFloat) {
        let text = string.mutableString
        let range = text.range(of: ":melior:")
        if range.length > 0 {
            let attachment = NSTextAttachment()
            attachment.image = Asset.melior.image
            attachment.bounds = CGRect(x: 0, y: 0, width: size, height: size)
            let addedString = NSAttributedString(attachment: attachment)
            string.replaceCharacters(in: range, with: addedString)
        }
    }
    
    private func applyParagraphStyling(_ string: NSMutableAttributedString) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        paragraphStyle.paragraphSpacing = 7
        string.addAttribute(.paragraphStyle, value: paragraphStyle)
    }
    
    private func matchUsernames(text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: "\\B@[-\\w]+")
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                if let range = Range($0.range, in: text) {
                    return String(text[range])
                } else {
                    return text
                }
            }
        } catch let error {
            logger.log("invalid regex: \(error.localizedDescription)", level: .error)
            return []
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

private class HabiticaStyler: DownStyler {    
    override func style(item str: NSMutableAttributedString, prefixLength: Int) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = CGFloat(prefixLength * 12)
        str.addAttribute(.paragraphStyle, value: paragraphStyle)
    }
    
    override func style(heading str: NSMutableAttributedString, level: Int) {
        switch level {
        case 1:
            str.addAttribute(.font, value: CustomFontMetrics.scaledBoldSystemFont(ofSize: 27))
        case 2:
            str.addAttribute(.font, value: CustomFontMetrics.scaledBoldSystemFont(ofSize: 21))
        case 3:
            str.addAttribute(.font, value: CustomFontMetrics.scaledBoldSystemFont(ofSize: 17))
        case 4:
            str.addAttribute(.font, value: CustomFontMetrics.scaledBoldSystemFont(ofSize: 15))
        case 5:
            str.addAttribute(.font, value: CustomFontMetrics.scaledBoldSystemFont(ofSize: 13))
        case 6:
            str.addAttribute(.font, value: CustomFontMetrics.scaledBoldSystemFont(ofSize: 12))
        default:
            return
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.paragraphSpacing = 16
        str.addAttribute(.paragraphStyle, value: paragraphStyle)
    }
    
    let baseSize: CGFloat
    let textColor: UIColor
    
    init(ofSize baseSize: CGFloat, textColor: UIColor) {
        self.baseSize = baseSize
        self.textColor = textColor
    }
    
    var listPrefixAttributes: [NSAttributedString.Key: Any] {
            return [
            .foregroundColor: ThemeService.shared.theme.primaryTextColor
        ]
    }
    
    override func style(codeBlock str: NSMutableAttributedString, fenceInfo: String?) {
        str.addAttributes([
            .font: CustomFontMetrics.scaledFont(for: UIFont(name: "Menlo", size: baseSize) ?? UIFont.systemFont(ofSize: baseSize))
            ], range: NSRange(location: 0, length: str.length))
    }

    override func style(paragraph str: NSMutableAttributedString) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        paragraphStyle.paragraphSpacing = 7
        str.addAttribute(.paragraphStyle, value: paragraphStyle)
    }
    
    override func style(listItemPrefix str: NSMutableAttributedString) {
        str.addAttribute(.font, value: CustomFontMetrics.scaledSystemFont(ofSize: baseSize))
        str.addAttribute(.foregroundColor, value: textColor)
        
        var listDotLocation = 0

        for char in str.string {
            if Int(String(char)) == nil {
                break
            }
            listDotLocation += 1
        }
        str.replaceCharacters(in: NSRange(location: listDotLocation, length: 1), with: " ")
    }

    override func style(text str: NSMutableAttributedString) {
        str.addAttribute(.font, value: CustomFontMetrics.scaledSystemFont(ofSize: baseSize))
        str.addAttribute(.foregroundColor, value: textColor)
    }

    override func style(code str: NSMutableAttributedString) {
        str.addAttributes([
                .foregroundColor: UIColor.red50,
                .font: CustomFontMetrics.scaledFont(for: UIFont(name: "Menlo", size: baseSize) ?? UIFont.systemFont(ofSize: baseSize))
            ], range: NSRange(location: 0, length: str.length))
    }

    override func style(emphasis str: NSMutableAttributedString) {
        if (str.attribute(.font, at: 0, effectiveRange: nil) as? UIFont)?.isBold == true {
            str.addAttribute(.font, value: CustomFontMetrics.scaledBoldItalicSystemFont(ofSize: baseSize))
        } else {
            str.addAttribute(.font, value: CustomFontMetrics.scaledItalicSystemFont(ofSize: baseSize))
        }
    }
    override func style(strong str: NSMutableAttributedString) {
        if (str.attribute(.font, at: 0, effectiveRange: nil) as? UIFont)?.isItalic == true {
            str.addAttribute(.font, value: CustomFontMetrics.scaledBoldItalicSystemFont(ofSize: baseSize))
        } else {
            str.addAttribute(.font, value: CustomFontMetrics.scaledBoldSystemFont(ofSize: baseSize))
        }
    }
    override func style(link str: NSMutableAttributedString, title: String?, url: String?) {
        guard let url = url else {
            return
        }
        var range = NSRange(location: 0, length: str.length)
        if let title = title {
            str.replaceCharacters(in: NSRange(location: 0, length: str.length), with: title)
            range = NSRange(location: 0, length: title.count)
        }
        str.addAttribute(.link, value: url, range: range)
    }
    override func style(image str: NSMutableAttributedString, title: String?, url: String?) {
        if let imageURL = URL(string: url ?? ""), let data = try? Data(contentsOf: imageURL) {
            let attachment = NSTextAttachment()
            attachment.image = UIImage(data: data)
            let addedString = NSAttributedString(attachment: attachment)
            str.replaceCharacters(in: NSRange(location: 0, length: str.length), with: addedString)
        }
    }
}

extension NSMutableAttributedString {
    func addAttribute(_ name: NSAttributedString.Key, value: Any) {
        addAttribute(name, value: value, range: NSRange(location: 0, length: length))
    }
}
