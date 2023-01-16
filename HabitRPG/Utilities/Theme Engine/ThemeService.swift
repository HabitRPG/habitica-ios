//
//  ThemeService .swift
//  Habitica
//
//  Created by Phillip Thelen on 23.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Eureka

public class ThemeService: NSObject {
    private let defaults = UserDefaults.standard

    public static let shared = ThemeService()
    public var isDarkTheme: Bool?
    public var theme: Theme = DefaultTheme() {
        didSet {
            applyTheme()
        }
    }
    public var themeMode: String {
        return defaults.string(forKey: "themeMode") ?? ThemeMode.system.rawValue
    }
    
    private var listeners = NSHashTable<AnyObject>.weakObjects()
    
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
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: theme.primaryTextColor
        ]
        UINavigationBar.appearance().backgroundColor = theme.contentBackgroundColor
        UINavigationBar.appearance().barTintColor = theme.contentBackgroundColor
        UITabBar.appearance().barTintColor = theme.contentBackgroundColor
        UITabBar.appearance().backgroundColor = theme.contentBackgroundColor
        UITabBar.appearance().backgroundImage = UIImage.from(color: theme.contentBackgroundColor)
        UITabBar.appearance().shadowImage = UIImage.from(color: theme.contentBackgroundColor)
        UITabBar.appearance().barStyle = .black
        if theme.isDark {
            UISearchBar.appearance().barStyle = .black
            UISearchBar.appearance().isTranslucent = true
            UITextField.appearance().keyboardAppearance = .dark
        } else {
            UISearchBar.appearance().barStyle = .default
            UISearchBar.appearance().isTranslucent = false
            UITextField.appearance().keyboardAppearance = .default
        }

        UIToolbar.appearance().backgroundColor = theme.contentBackgroundColor
        UIToolbar.appearance().barTintColor = theme.contentBackgroundColor
        UISwitch.appearance().onTintColor = theme.backgroundTintColor
        UISearchBar.appearance().backgroundColor = theme.windowBackgroundColor
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = theme.contentBackgroundColor
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = theme.primaryTextColor

        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = theme.primaryTextColor
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = theme.primaryTextColor
        UITableViewCell.appearance().backgroundColor = theme.contentBackgroundColor
        UITableView.appearance().backgroundColor = theme.windowBackgroundColor
        UITableView.appearance().separatorColor = theme.tableviewSeparatorColor
        UICollectionView.appearance().backgroundColor = theme.windowBackgroundColor

        // Update styles via UIAppearance
        UITabBarItem.appearance().badgeColor = theme.badgeColor
        UITabBar.appearance().unselectedItemTintColor = theme.quadTextColor
                        
        // The tintColor will trickle down to each view
        UIApplication.shared.windows.forEach { window in
            window.tintColor = theme.tintColor
            window.overrideUserInterfaceStyle = theme.isDark ? .dark : .light
        }
        
        // Update each listener. The type cast is needed because allObjects returns [AnyObject]
        listeners.allObjects
            .compactMap { $0 as? Themeable }
            .forEach { $0.applyTheme(theme: theme) }
    }
    
    func updateInterfaceStyle(newStyle: UIUserInterfaceStyle) {
        let isDark = newStyle == .dark
        updateDarkMode(systemIsDark: isDark)
    }
    
    func updateDarkMode() {
        updateDarkMode(systemIsDark: UIScreen.main.traitCollection.userInterfaceStyle == .dark)
    }
    
    func updateDarkMode(systemIsDark: Bool) {
        var enabled = themeMode == ThemeMode.dark.rawValue
        if themeMode == ThemeMode.system.rawValue {
            enabled = systemIsDark
        }
        if enabled != self.isDarkTheme {
            self.isDarkTheme = enabled
            
            let themeName = ThemeName(rawValue: defaults.string(forKey: "theme") ?? "") ?? ThemeName.defaultTheme
            ThemeService.shared.theme = themeName.themeClass
            
            UIApplication.shared.connectedScenes.map({ scene in
                return (scene as? UIWindowScene)?.windows ?? []
            }).forEach({ windows in
                for window in windows {
                    if ThemeService.shared.themeMode == "dark" {
                            window.overrideUserInterfaceStyle = .dark
                    } else if ThemeService.shared.themeMode == "light" {
                        window.overrideUserInterfaceStyle = .light
                    } else {
                        window.overrideUserInterfaceStyle = .unspecified
                    }
                }
            })
        }
    }
}

public protocol Themeable: AnyObject {
    func applyTheme(theme: Theme)
}
