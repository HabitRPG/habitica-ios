//
//  TaskVisualEffectsModalViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class TaskFormVisualEffectsModalViewController: VisualEffectModalViewController {
    
    @objc var isCreating = false
    @objc var taskId: String?
    var taskType: TaskType?
    
    @objc
    func setTaskTypeString(type: String) {
        taskType = TaskType(rawValue: type) ?? .habit
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Tasks.embedSegue.rawValue {
            let destination = segue.destination as? TaskFormViewController
            destination?.modalContainerViewController = self
            destination?.isCreating = isCreating
            if let taskId = self.taskId {
                destination?.taskId = taskId
            }
            if let taskType = self.taskType {
                destination?.taskType = taskType
            }
        }
    }
}
