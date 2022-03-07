//
//  MarkdownTextView.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import UIKit
import Down

class MarkdownTextView: LinksOnlyTextView, UITextViewDelegate {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
    }
    
    func setMarkdownString(_ markdownString: String?, highlightUsernames: Bool = true, attributes: [NSAttributedString.Key: Any]? = nil) {
        if let str = markdownString {
            let attributedStr = try? Down(markdownString: str).toHabiticaAttributedString(highlightUsernames: highlightUsernames)
            if let attributes = attributes {
                attributedStr?.addAttributes(attributes, range: NSRange(location: 0, length: attributedStr?.length ?? 0))
            }
            attributedText = attributedStr
            delegate = self
        } else {
            text = nil
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return !RouterHandler.shared.handle(url: URL)
    }
}
