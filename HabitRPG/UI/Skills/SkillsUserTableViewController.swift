//
//  SkillsUserTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 29.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class SkillsUserTableViewController: UITableViewController {
    
    private let datasource = SkillsUserTableViewDataSource()
    
    @objc var selectedUserID: String?
    @objc var skill: SkillProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datasource.tableView = tableView
        
        navigationItem.title = L10n.Titles.chooseUser
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let member = datasource.item(at: indexPath) {
            selectedUserID = member.id
        }
        perform(segue: StoryboardSegue.Main.castUserSpellSegue)
    }
}
