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
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: theme.primaryTextColor
        ]
        UINavigationBar.appearance().backgroundColor = theme.contentBackgroundColor
        UINavigationBar.appearance().barTintColor = theme.contentBackgroundColor
        if theme.isDark {
            UITabBar.appearance().tintColor = theme.tintColor
            UITabBar.appearance().backgroundColor = theme.windowBackgroundColor
            UITabBar.appearance().barTintColor = .clear
            UITabBar.appearance().barStyle = .blackOpaque
            UISearchBar.appearance().barStyle = .blackTranslucent
            UITextField.appearance().keyboardAppearance = .dark
        } else {
            UITabBar.appearance().tintColor = theme.tintColor
            UITabBar.appearance().barTintColor = theme.contentBackgroundColor
            UITabBar.appearance().backgroundColor = .clear
            UITabBar.appearance().barStyle = .black
            UISearchBar.appearance().barStyle = .default
            UITextField.appearance().keyboardAppearance = .default
        }

        UIToolbar.appearance().tintColor = theme.tintColor
        UIToolbar.appearance().backgroundColor = theme.contentBackgroundColor
        UIToolbar.appearance().barTintColor = theme.contentBackgroundColor
        UIRefreshControl.appearance().tintColor = theme.tintColor
        UISegmentedControl.appearance().tintColor = theme.backgroundTintColor
        UISwitch.appearance().onTintColor = theme.backgroundTintColor
        //UIButton.appearance().tintColor = theme.tintColor
        UISearchBar.appearance().backgroundColor = theme.windowBackgroundColor
        UISearchBar.appearance().tintColor = theme.tintColor
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = theme.contentBackgroundColor
        UITextView.appearance().tintColor = theme.tintColor
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = theme.primaryTextColor

        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = theme.primaryTextColor
        UILabel.appearance(whenContainedInInstancesOf: [UICollectionReusableView.self]).textColor = theme.primaryTextColor
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
        
        let view = UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
        view.tintColor = theme.tintColor
        // Update styles via UIAppearance
        if #available(iOS 10.0, *) {
            UITabBarItem.appearance().badgeColor = theme.badgeColor
            UITabBar.appearance().unselectedItemTintColor = theme.dimmedTextColor
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
