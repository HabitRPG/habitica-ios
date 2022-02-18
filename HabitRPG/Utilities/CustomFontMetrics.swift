//
//  UIFontMetrics.default.swift
//
//  Created by Zachary Waldowski on 6/6/17.
//  Licensed under MIT.
//
import UIKit

extension UIFontMetrics {

    @objc
    public func scaledSystemFont(ofSize size: CGFloat, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
        return UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: size), compatibleWith: traitCollection)
    }
    @objc
    public func scaledBoldSystemFont(ofSize size: CGFloat, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
        return UIFontMetrics.default.scaledFont(for: UIFont.boldSystemFont(ofSize: size), compatibleWith: traitCollection)
    }
    @objc
    public func scaledItalicSystemFont(ofSize size: CGFloat, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
        return UIFontMetrics.default.scaledFont(for: UIFont.italicSystemFont(ofSize: size), compatibleWith: traitCollection)
    }
    @objc
    public func scaledBoldItalicSystemFont(ofSize size: CGFloat, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
        return UIFontMetrics.default.scaledFont(for: UIFont.boldItalicSystemFont(ofSize: size), compatibleWith: traitCollection)
    }
    @objc
    public func scaledSystemFont(ofSize size: CGFloat, ofWeight weight: UIFont.Weight, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
        return UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: size, weight: weight), compatibleWith: traitCollection)
    }
}
