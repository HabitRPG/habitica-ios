//
//  BaseUIViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 06.05.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

class BaseUIViewController: HRPGTutorialUIViewController, Themeable {
    
    lazy var topHeaderCoordinator: TopHeaderCoordinator? = {
        if hrpgTopHeaderNavigationController() != nil {
            return TopHeaderCoordinator(topHeaderNavigationController: hrpgTopHeaderNavigationController())
        }
        return nil
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateText()
        ThemeService.shared.addThemeable(themable: self)
        topHeaderCoordinator?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topHeaderCoordinator?.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayTutorialStep()
        topHeaderCoordinator?.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        topHeaderCoordinator?.viewWillDisappear()
        super.viewWillDisappear(animated)
    }
    
    func populateText() {
        
    }
    
    func applyTheme(theme: Theme) {
        if #available(iOS 13.0, *) {
            if ThemeService.shared.themeMode == "dark" {
                self.overrideUserInterfaceStyle = .dark
            } else if ThemeService.shared.themeMode == "light" {
                self.overrideUserInterfaceStyle = .light
            } else {
                self.overrideUserInterfaceStyle = .unspecified
            }
        }
        view.backgroundColor = theme.contentBackgroundColor
    }
    
}
