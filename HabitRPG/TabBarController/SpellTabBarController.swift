//
//  SpellTabBarController.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.10.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

@objc
class SpellTabBarController: UITabBarController {
    @objc
    var skill: SkillProtocol?
    @objc
    var taskID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = L10n.chooseTask
        tabBar.items?[0].title = L10n.Tasks.habits
        tabBar.items?[1].title = L10n.Tasks.dailies
        tabBar.items?[2].title = L10n.Tasks.todos
        
        var tabIndex = 0
        for controller in viewControllers ?? [] {
            if let taskController = controller as? SkillsTaskTableViewController {
                switch tabIndex {
                case 0:
                    taskController.taskType = .habit
                case 1:
                    taskController.taskType = .daily
                case 2:
                    taskController.taskType = .todo
                default:
                    continue
                }
                tabIndex += 1
            }
        }
    }
    
    func castSpell() {
        perform(segue: StoryboardSegue.Main.castTaskSpellSegue)
    }
    
    @objc
    func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
}
