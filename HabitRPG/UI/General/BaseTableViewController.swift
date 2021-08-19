//
//  BaseTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 08.03.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

class BaseTableViewController: HRPGBaseViewController, Themeable, TutorialStepsProtocol {
    var tutorialIdentifier: String?
    
    var displayedTutorialStep: Bool = false
    
    var activeTutorial: TutorialStepView?
    
    func getDefinitionFor(tutorial: String) -> [String] {
        return []
    }
    
    override func viewDidLoad() {
        if let topHeaderNavigationController = navigationController as? TopHeaderViewController {
            topHeaderCoordinator = TopHeaderCoordinator(topHeaderNavigationController: topHeaderNavigationController, scrollView: tableView)
        }
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        if ThemeService.shared.themeMode == "dark" {
            self.overrideUserInterfaceStyle = .dark
        } else if ThemeService.shared.themeMode == "light" {
            self.overrideUserInterfaceStyle = .light
        } else {
            self.overrideUserInterfaceStyle = .unspecified
        }
        tableView.backgroundColor = theme.windowBackgroundColor
        tableView.separatorColor = theme.tableviewSeparatorColor
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayTutorialStep()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        displayedTutorialStep = false
    }
}
