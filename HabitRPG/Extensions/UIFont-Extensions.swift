//
//  UIFont-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.07.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
extension UIFont {
    
    func withTraits(traits: UIFontDescriptorSymbolicTraits...) -> UIFont {
        if let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits)) {
            return UIFont(descriptor: descriptor, size: 0)
        } else {
            return self
        }
    }
    
    static func boldItalicSystemFont(ofSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: ofSize).withTraits(traits: .traitBold, .traitItalic)
    }
    
}
