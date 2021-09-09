//
//  File.swift
//  Habitica
//
//  Created by Phillip Thelen on 29.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class SkillsTaskTableViewDataSource: BaseReactiveTableViewDataSource<TaskProtocol> {
    
    private let taskRepository = TaskRepository()
    
    private let taskType: TaskType
    
    init(taskType: TaskType) {
        self.taskType = taskType
        super.init()
        sections.append(ItemSection<TaskProtocol>())
        
        disposable.add(taskRepository.getTasks(type: taskType).on(value: {[weak self](tasks, changes) in
            self?.sections[0].items = tasks
            self?.notify(changes: changes)
        }).start())
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let task = item(at: indexPath) {
            cell.textLabel?.text = task.text?.unicodeEmoji
            cell.textLabel?.textColor = UIColor.forTaskValue(task.value)
            if task.challengeID != nil {
                cell.detailTextLabel?.text = L10n.Skills.cantCastOnChallengeTasks
                cell.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
            } else {
                cell.detailTextLabel?.text = nil
            }
        }
        return cell
    }
}
