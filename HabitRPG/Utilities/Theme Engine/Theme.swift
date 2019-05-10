//
//  Theme.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

public protocol Theme {
    var isDark: Bool { get }
    var contentBackgroundColor: UIColor { get }
    var contentBackgroundColorDimmed: UIColor { get }
    var offsetBackgroundColor: UIColor { get }
    var windowBackgroundColor: UIColor { get }
    var backgroundTintColor: UIColor { get }
    var lightlyTintedBackgroundColor: UIColor { get }
    var tintColor: UIColor { get }
    var separatorColor: UIColor { get }
    var tableviewSeparatorColor: UIColor { get }
    
    var dimmedColor: UIColor { get }
    var dimmBackgroundColor: UIColor { get }
    
    var navbarHiddenColor: UIColor { get }
    
    var primaryTextColor: UIColor { get }
    var secondaryTextColor: UIColor { get }
    var ternaryTextColor: UIColor { get }
    var dimmedTextColor: UIColor { get }
    var lightTextColor: UIColor { get }
    var badgeColor: UIColor { get }
    var successColor: UIColor { get }
    var errorColor: UIColor { get }
    var taskOverlayTint: UIColor { get }
}

public protocol DarkTheme: Theme {
}

extension Theme {
    public var isDark: Bool { return false }
    public var contentBackgroundColor: UIColor { return UIColor.white }
    public var contentBackgroundColorDimmed: UIColor { return UIColor.gray700() }
    public var offsetBackgroundColor: UIColor { return UIColor.gray600() }
    public var windowBackgroundColor: UIColor { return UIColor.gray700() }
    public var backgroundTintColor: UIColor { return UIColor.purple300() }
    public var lightlyTintedBackgroundColor: UIColor { return UIColor.purple600() }
    public var tintColor: UIColor { return UIColor.purple400() }
    public var separatorColor: UIColor { return UIColor.gray600() }
    public var tableviewSeparatorColor: UIColor { return UIColor.gray500() }
    
    public var dimmedColor: UIColor { return UIColor.gray500() }
    public var dimmBackgroundColor: UIColor { return UIColor.purple50() }
    
    public var navbarHiddenColor: UIColor { return backgroundTintColor }
    
    public var primaryTextColor: UIColor { return UIColor.gray10() }
    public var secondaryTextColor: UIColor { return UIColor.gray100() }
    public var ternaryTextColor: UIColor { return UIColor.gray200() }
    public var dimmedTextColor: UIColor { return UIColor.gray400() }
    public var lightTextColor: UIColor { return UIColor.white }
    
    public var badgeColor: UIColor { return tintColor }
    public var successColor: UIColor { return UIColor.green100() }
    public var errorColor: UIColor { return UIColor.red100() }
    public var taskOverlayTint: UIColor { return UIColor.white.withAlphaComponent(0) }
    
    public func applyContentBackgroundColor(views: [UIView]) {
        applyBackgroundColor(views: views, color: contentBackgroundColor)
    }
    
    public func applyBackgroundColor(views: [UIView], color: UIColor) {
        views.forEach {
            $0.backgroundColor = color
        }
    }
}

extension DarkTheme {
    public var isDark: Bool { return true }
    public var successColor: UIColor { return UIColor.green10() }
    public var errorColor: UIColor { return UIColor.red10() }
}

@objc
class ObjcThemeWrapper: NSObject {
    
    @objc public static var contentBackgroundColor: UIColor { return ThemeService.shared.theme.contentBackgroundColor }
    @objc public static var contentBackgroundColorDimmed: UIColor { return ThemeService.shared.theme.contentBackgroundColor }
    @objc public static var windowBackgroundColor: UIColor { return ThemeService.shared.theme.windowBackgroundColor }
    @objc public static var backgroundTintColor: UIColor { return ThemeService.shared.theme.backgroundTintColor }
    @objc public static var tintColor: UIColor { return ThemeService.shared.theme.tintColor }
    
    @objc public static var primaryTextColor: UIColor { return ThemeService.shared.theme.primaryTextColor }
    @objc public static var secondaryTextColor: UIColor { return ThemeService.shared.theme.secondaryTextColor }
    @objc public static var dimmedTextColor: UIColor { return ThemeService.shared.theme.dimmedTextColor }
    @objc public static var lightTextColor: UIColor { return ThemeService.shared.theme.lightTextColor}
}
