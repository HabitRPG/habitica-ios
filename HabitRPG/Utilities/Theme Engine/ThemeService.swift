//
//  ThemeService .swift
//  Habitica
//
//  Created by Phillip Thelen on 23.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

@objc
public class ThemeService: NSObject {
    
    public static let shared = ThemeService()
    public var theme: Theme = DefaultTheme() {
        didSet {
            applyTheme()
        }
    }
    
    private var listeners = NSHashTable<AnyObject>.weakObjects()
    
    override public init() {}
    
    public func addThemeable(themable: Themeable, applyImmediately: Bool = true) {
        guard !listeners.contains(themable) else {
            return
        }
        listeners.add(themable)
        
        if applyImmediately {
            themable.applyTheme(theme: theme)
        }
    }
    
    private func applyTheme() {
        UINavigationBar.appearance().tintColor = theme.tintColor
        UINavigationBar.appearance().backgroundColor = theme.contentBackgroundColor
        UITabBar.appearance().tintColor = theme.tintColor
        UITabBar.appearance().barTintColor = theme.contentBackgroundColor
        UITabBar.appearance().barStyle = .black
        UIToolbar.appearance().tintColor = theme.tintColor
        UIToolbar.appearance().backgroundColor = theme.contentBackgroundColor
        UIRefreshControl.appearance().tintColor = theme.tintColor
        UISegmentedControl.appearance().tintColor = theme.backgroundTintColor
        UISwitch.appearance().onTintColor = theme.backgroundTintColor
        UIButton.appearance().tintColor = theme.tintColor
        UISearchBar.appearance().backgroundColor = theme.windowBackgroundColor
        UISearchBar.appearance().tintColor = theme.tintColor
        let view = UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
        view.tintColor = theme.tintColor
        // Update styles via UIAppearance
        if #available(iOS 10.0, *) {
            UITabBarItem.appearance().badgeColor = theme.tintColor
        }
        
        // The tintColor will trickle down to each view
        if let window = UIApplication.shared.keyWindow {
            window.tintColor = theme.tintColor
        }
        
        // Update each listener. The type cast is needed because allObjects returns [AnyObject]
        listeners.allObjects
            .compactMap { $0 as? Themeable }
            .forEach { $0.applyTheme(theme: theme) }
    }
    
}

public protocol Themeable: AnyObject {
    func applyTheme(theme: Theme)
}