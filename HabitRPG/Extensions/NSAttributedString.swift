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
    
    func highlightWords(words: String...) {
        let mString = mutableString
        for word in words {
            let range = mString.range(of: word, options: .caseInsensitive)
            if range.location != NSNotFound {
                addAttributes([NSAttributedString.Key.foregroundColor: ThemeService.shared.theme.tintColor], range: range)
            }
        }
    }
}

@available(iOS 15, *)
extension AttributedString {
    func withHighlightWords(words: String...) -> AttributedString {
        var text = self
        for word in words {
            if let range = range(of: word) {
                text[range].foregroundColor = ThemeService.shared.theme.tintColor
            }
        }
        return text
    }
    
    func withLinkedWord(word: String, link: String) -> AttributedString {
        var text = self
        if let range = range(of: word) {
            text[range].foregroundColor = ThemeService.shared.theme.tintColor
            text[range].link = .init(string: link)
        }
        return text
    }
    
    func withCommunityGuidelinesLinked() -> AttributedString {
        return withLinkedWord(word: L10n.communityGuidelines, link: "https://")
    }
    
    func withTermsOfServiceLinked() -> AttributedString {
        return withLinkedWord(word: L10n.termsOfService, link: "https://habitica.com/static/terms")
    }
}
