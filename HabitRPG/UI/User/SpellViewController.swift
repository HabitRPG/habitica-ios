//
//  SpellViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 04.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class SpellViewController: BaseTableViewController {
    
    private let datasource = SpellsTableViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = L10n.Titles.skills
        
        datasource.tableView = tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 95
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        tableView.backgroundColor = theme.contentBackgroundColor
    }
    
    override func getDefinitionFor(tutorial: String) -> [String] {
        if tutorialIdentifier == "skills" {
            return [L10n.Tutorials.spells]
        }
        return []
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let skill = datasource.skillAt(indexPath: indexPath) {
            if datasource.canUse(skill: skill) && datasource.hasManaFor(skill: skill) {
                if skill.target == "task" {
                    let navigationController = StoryboardScene.Main.spellTaskNavigationController.instantiate()
                    present(navigationController, animated: true, completion: {
                        let tabBarController = navigationController.topViewController as? SpellTabBarController
                        tabBarController?.skill = skill
                    })
                } else {
                    datasource.useSkill(skill: skill, targetId: nil)
                }
            }
            return
        }
        if let item = datasource.itemAt(indexPath: indexPath) {
            let navigationController = StoryboardScene.Main.spellUserNavigationController.instantiate()
            present(navigationController, animated: true, completion: {
                let controller = navigationController.topViewController as? SkillsUserTableViewController
                controller?.item = item
            })
        }
    }
    
    @IBAction override func unwindToListSave(_ segue: UIStoryboardSegue) {
        if segue.identifier == "CastUserSpellSegue" {
            guard let userViewController = segue.source as? SkillsUserTableViewController else {
                return
            }
            guard let item = userViewController.item as? SpecialItemProtocol else {
                return
            }
            datasource.useItem(item: item, targetId: userViewController.selectedUserID)
        } else if segue.identifier == "CastTaskSpellSegue" {
            guard let tabViewController = segue.source as? SpellTabBarController else {
                return
            }
            guard let skill = tabViewController.skill else {
                return
            }
            datasource.useSkill(skill: skill, targetId: tabViewController.taskID)
        }
    }
}
