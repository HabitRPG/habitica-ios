//
//  UIFont-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.07.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
extension UIFont {
    
    func withTraits(traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        if let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits)) {
            return UIFont(descriptor: descriptor, size: 0)
        } else {
            return self
        }
    }
    
    static func boldItalicSystemFont(ofSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: ofSize).withTraits(traits: .traitBold, .traitItalic)
    }
    
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
}
