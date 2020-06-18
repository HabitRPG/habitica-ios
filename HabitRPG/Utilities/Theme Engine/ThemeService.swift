//
//  ThemeService .swift
//  Habitica
//
//  Created by Phillip Thelen on 23.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Eureka
import PopupDialog

@objc
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
        get { return defaults.string(forKey: "themeMode") ?? ThemeMode.system.rawValue }
    }
    
    private var listeners = NSHashTable<AnyObject>.weakObjects()
    private var objcListeners = NSHashTable<AnyObject>.weakObjects()

    override public init() {
        if #available(iOS 13.0, *) {
        }
    }
    
    public func addThemeable(themable: Themeable, applyImmediately: Bool = true) {
        guard !listeners.contains(themable) else {
            return
        }
        listeners.add(themable)
        
        if applyImmediately {
            themable.applyTheme(theme: theme)
        }
    }
    
    public func addThemeable(themable: ObjcThemeable, applyImmediately: Bool = true) {
        guard !listeners.contains(themable) else {
            return
        }
        objcListeners.add(themable)
        
        if applyImmediately {
            themable.applyTheme()
        }
    }
    
    private func applyTheme() {
        UINavigationBar.appearance().tintColor = theme.primaryTextColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: theme.primaryTextColor
        ]
        UINavigationBar.appearance().backgroundColor = theme.contentBackgroundColor
        UINavigationBar.appearance().barTintColor = theme.contentBackgroundColor
        if theme.isDark {
            UITabBar.appearance().tintColor = theme.tintColor
            UITabBar.appearance().backgroundColor = theme.windowBackgroundColor
            UITabBar.appearance().barTintColor = .clear
            UITabBar.appearance().barStyle = .black
            UISearchBar.appearance().barStyle = .blackTranslucent
            UITextField.appearance().keyboardAppearance = .dark
        } else {
            UITabBar.appearance().tintColor = theme.tintColor
            UITabBar.appearance().barTintColor = theme.contentBackgroundColor
            UITabBar.appearance().backgroundColor = theme.contentBackgroundColor
            UITabBar.appearance().barStyle = .black
            UISearchBar.appearance().barStyle = .default
            UITextField.appearance().keyboardAppearance = .default
        }

        UIToolbar.appearance().tintColor = theme.tintColor
        UIToolbar.appearance().backgroundColor = theme.contentBackgroundColor
        UIToolbar.appearance().barTintColor = theme.contentBackgroundColor
        UIRefreshControl.appearance().tintColor = theme.tintColor
        UISegmentedControl.appearance().tintColor = theme.segmentedTintColor
        UISwitch.appearance().onTintColor = theme.backgroundTintColor
        //UIButton.appearance().tintColor = theme.tintColor
        UISearchBar.appearance().backgroundColor = theme.windowBackgroundColor
        UISearchBar.appearance().tintColor = theme.tintColor
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = theme.contentBackgroundColor
        UITextView.appearance().tintColor = theme.tintColor
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = theme.primaryTextColor

        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = theme.primaryTextColor
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = theme.primaryTextColor
        UIButton.appearance(whenContainedInInstancesOf: [UITableView.self]).tintColor = theme.tintColor
        UIButton.appearance(whenContainedInInstancesOf: [UICollectionView.self]).tintColor = theme.tintColor
        UIButton.appearance(whenContainedInInstancesOf: [UIScrollView.self]).tintColor = theme.tintColor
        UITableViewCell.appearance().backgroundColor = theme.contentBackgroundColor
        UITableView.appearance().backgroundColor = theme.windowBackgroundColor
        UITableView.appearance().separatorColor = theme.tableviewSeparatorColor
        UICollectionView.appearance().backgroundColor = theme.windowBackgroundColor
        
        let appearance = PopupDialogOverlayView.appearance()
        appearance.color = theme.dimmBackgroundColor
        appearance.opacity = 0.6
        appearance.blurEnabled = false
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.shadowEnabled = false
        containerAppearance.cornerRadius = 16.0 as Float
        
        let view = UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
        if #available(iOS 13.0, *) {
            view.tintColor = theme.tintColor
        } else {
            view.tintColor = UIColor.purple300
        }
        // Update styles via UIAppearance
        UITabBarItem.appearance().badgeColor = theme.badgeColor
        UITabBar.appearance().unselectedItemTintColor = theme.dimmedTextColor
                
        // The tintColor will trickle down to each view
        if let window = UIApplication.shared.keyWindow {
            window.tintColor = theme.tintColor
        }
        
        // Update each listener. The type cast is needed because allObjects returns [AnyObject]
        listeners.allObjects
            .compactMap { $0 as? Themeable }
            .forEach { $0.applyTheme(theme: theme) }
        objcListeners.allObjects
            .compactMap { $0 as? ObjcThemeable }
            .forEach { $0.applyTheme() }
    }
    
    @available(iOS 12.0, *)
    func updateInterfaceStyle(newStyle: UIUserInterfaceStyle) {
        let isDark = newStyle == .dark
        updateDarkMode(systemIsDark: isDark)
    }
    
    func updateDarkMode() {
        if #available(iOS 13.0, *) {
            updateDarkMode(systemIsDark: UIScreen.main.traitCollection.userInterfaceStyle == .dark)
        } else {
            updateDarkMode(systemIsDark: false)
        }
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
        }
    }
}

public protocol Themeable: AnyObject {
    func applyTheme(theme: Theme)
}

@objc
public protocol ObjcThemeable {
    func applyTheme()
}
