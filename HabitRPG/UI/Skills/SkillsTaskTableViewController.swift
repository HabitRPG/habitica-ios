//
//  SkillsTaskTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 29.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class SkillsTaskTableViewController: UITableViewController {
    
    private var dataSource: SkillsTaskTableViewDataSource?
    
    var taskType: TaskType?
    @objc var taskTypeString: String? {
        get {
            return taskType?.rawValue
        }
        set {
            taskType = TaskType(rawValue: newValue ?? "")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let taskType = self.taskType {
            dataSource = SkillsTaskTableViewDataSource(taskType: taskType)
            dataSource?.tableView = tableView
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let task = dataSource?.item(at: indexPath) {
            let tabBarController = parent as? SpellTabBarController
            tabBarController?.taskID = task.id
            tabBarController?.castSpell()
        }
    }
}
