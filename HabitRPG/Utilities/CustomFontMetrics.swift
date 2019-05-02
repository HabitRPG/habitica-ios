//
//  CustomFontMetrics.swift
//
//  Created by Zachary Waldowski on 6/6/17.
//  Licensed under MIT.
//
import UIKit

private extension UITraitCollection {
    
    @available(iOS 10.0, *)
    static let defaultContentSizeCategory = UITraitCollection(preferredContentSizeCategory: .large)
    
}

private extension UIFont {
    
    var bodyLeading: CGFloat {
        return lineHeight + leading
    }
    
    func scaledValue(forValue value: CGFloat) -> CGFloat {
        guard let style = fontDescriptor.object(forKey: .textStyle) as? UIFont.TextStyle else {
            return value
            
        }
        if #available(iOS 10.0, *) {
            let defaultFont = UIFont.preferredFont(forTextStyle: style, compatibleWith: .defaultContentSizeCategory)
            return (value * bodyLeading) / defaultFont.bodyLeading
        } else {
            let defaultFont = UIFont.preferredFont(forTextStyle: style)
            return (value * bodyLeading) / defaultFont.bodyLeading
        }
    }
    
}

private extension CGFloat {
    
    func roundedForDisplay(compatibleWith traitCollection: UITraitCollection? = nil) -> CGFloat {
        let scale = traitCollection.flatMap {
            $0.displayScale.isZero ? nil : $0.displayScale
            } ?? UIScreen.main.scale
        return (self * scale).rounded(.toNearestOrAwayFromZero) / scale
    }
    
}

// MARK: -
/// Metrics represent the size, weight, and widths of an iOS built-in Dynamic
/// Type style.
///
/// A backport of `UIFontMetrics` from iOS 11.
public class CustomFontMetrics: NSObject {
    
    private enum Representation {
        @available(iOS 11.0, tvOS 11.0, watchOS 4.0, *)
        case modern(UIFontMetrics)
        
        case legacy(UIFont.TextStyle)
        static let legacyDefault = Representation.legacy(.body)
    }
    
    private let rep: Representation
    
    private init(_ rep: Representation) {
        self.rep = rep
    }
    
    /// The standard font metrics used for body text.
    public static var `default`: CustomFontMetrics {
        if #available(iOS 11.0, tvOS 11.0, watchOS 4.0, *) {
            return CustomFontMetrics(.modern(.default))
        } else {
            return CustomFontMetrics(.legacyDefault)
        }
    }
    
    /// Creates font metrics for interpolating values for a `textStyle`.
    @objc
    public init(forTextStyle textStyle: UIFont.TextStyle) {
        if #available(iOS 11.0, tvOS 11.0, watchOS 4.0, *) {
            rep = .modern(UIFontMetrics(forTextStyle: textStyle))
        } else {
            rep = .legacy(textStyle)
        }
    }
    
    private static let supportedDynamicTypeStyles: Set<UIFont.TextStyle> = [
        .title1, .title2, .title3, .headline, .subheadline, .body, .callout, .footnote, .caption1, .caption2
    ]
    
    @objc
    public static func scaledFont(for font: UIFont, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
        return CustomFontMetrics(forTextStyle: .body).scaledFont(for: font, compatibleWith: traitCollection)
    }
    
    @objc
    public static func scaledSystemFont(ofSize size: CGFloat, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
        return CustomFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: size), compatibleWith: traitCollection)
    }
    
    @objc
    public static func scaledBoldSystemFont(ofSize size: CGFloat, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
        return CustomFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.boldSystemFont(ofSize: size), compatibleWith: traitCollection)
    }
    
    @objc
    public static func scaledItalicSystemFont(ofSize size: CGFloat, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
        return CustomFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.italicSystemFont(ofSize: size), compatibleWith: traitCollection)
    }
    
    @objc
    public static func scaledBoldItalicSystemFont(ofSize size: CGFloat, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
        return CustomFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.boldItalicSystemFont(ofSize: size), compatibleWith: traitCollection)
    }
    
    @objc
    public static func scaledSystemFont(ofSize size: CGFloat, ofWeight weight: UIFont.Weight, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
        return CustomFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: size, weight: weight), compatibleWith: traitCollection)
    }
    
    /// Interpolates a `font` compatible with the size for self in the
    /// default trait environment against the current environment.
    ///
    /// The `value` will proportionately scale according to the letter size
    /// of a font appropriate for self in the given `traitCollection`. Fonts
    /// already vended by Dynamic Type will simply re-create the same font for
    /// the new style.
    ///
    /// For example, you may observe this method always returns `value` in a
    /// pristine iOS simulator, because it is set to the standard text size.
    @objc
    public func scaledFont(for font: UIFont, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
        // TODO: support "maximumPointSize: CGFloat = 0"
        switch rep {
        case .modern(let metrics):
            return metrics.scaledFont(for: font, compatibleWith: traitCollection)
        case .legacy(let overrideStyle):
            let descriptor = font.fontDescriptor
            var systemFont = UIFont.preferredFont(forTextStyle: overrideStyle)
            if #available(iOS 10.0, *) {
                systemFont = UIFont.preferredFont(forTextStyle: overrideStyle, compatibleWith: traitCollection)
            }
            
            /// Is it a system font? Then we can simply re-make it.
            if let originalStyle = descriptor.object(forKey: .textStyle) as? UIFont.TextStyle, CustomFontMetrics.supportedDynamicTypeStyles.contains(originalStyle) {
                return systemFont
            }
            
            // Otherwise, interpolate.
            let newPointSize = systemFont.scaledValue(forValue: descriptor.pointSize).rounded(.toNearestOrAwayFromZero)
            /*if maximumPointSize > 0 {
             newPointSize = min(newPointSize, maximumPointSize)
             }*/
            return UIFont(descriptor: descriptor, size: newPointSize)
        }
    }
    
    /// Interpolates a scalar `value` compatible with the size for self in the
    /// default trait environment against the current environment.
    ///
    /// The `value` will proportionately scale according to the letter size
    /// of a font appropriate for self in the given `traitCollection`.
    ///
    /// For example, you may observe this method always returns `value` in a
    /// pristine iOS simulator, because it is set to the standard text size.
    public func scaledValue(for value: CGFloat, compatibleWith traitCollection: UITraitCollection? = nil) -> CGFloat {
        switch rep {
        case .modern(let metrics):
            return metrics.scaledValue(for: value, compatibleWith: traitCollection)
        case .legacy(let style):
            if #available(iOS 10.0, *) {
                return UIFont.preferredFont(forTextStyle: style, compatibleWith: traitCollection).scaledValue(forValue: value).roundedForDisplay(compatibleWith: traitCollection)
            } else {
                return UIFont.preferredFont(forTextStyle: style).scaledValue(forValue: value).roundedForDisplay(compatibleWith: traitCollection)
            }
        }
    }
    
}
