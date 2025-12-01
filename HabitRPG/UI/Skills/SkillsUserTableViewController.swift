//
//  SkillsUserTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 29.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class SkillsUserTableViewController: UITableViewController, Themeable {
    
    private let datasource = SkillsUserTableViewDataSource()
    
    @objc var selectedUserID: String?
    @objc var skill: SkillProtocol?
    @objc var item: ItemProtocol?
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datasource.tableView = tableView
        cancelButton.title = L10n.cancel
        
        navigationItem.title = L10n.Titles.chooseUser
        ThemeService.shared.addThemeable(themable: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let member = datasource.item(at: indexPath) {
            selectedUserID = member.id
        }
        perform(segue: StoryboardSegue.Main.castUserSpellSegue)
    }
    
    func applyTheme(theme: any Theme) {
        tableView.backgroundColor = theme.contentBackgroundColor
    }
}
