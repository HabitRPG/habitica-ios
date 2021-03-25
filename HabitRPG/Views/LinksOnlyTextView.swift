//
//  LinksOnlyTextView.swift
//  Habitica
//
//  Created by Juan on 23/06/20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

class LinksOnlyTextView: UITextView {
    // Only allow interactions directly on top of a link
    // https://stackoverflow.com/questions/36198299/uitextview-disable-selection-allow-links/44878203#44878203
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let pos = closestPosition(to: point), pos != endOfDocument else {
            return false
        }
        guard let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: .layout(.left)) else { return false }
        let startIndex = offset(from: beginningOfDocument, to: range.start)

        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
    }
}
