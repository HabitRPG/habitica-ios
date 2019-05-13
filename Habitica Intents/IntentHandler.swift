//
//  IntentHandler.swift
//  Habitica Intents
//
//  Created by Christopher Coffin on 5/12/19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//
/* Sample intents
 Add the following under Siri intent query:
 
 Add Task
 Add get grocieries to my todo list in Habitica
 
 Show Tasks in a given list
 Show my todo list in Habitica
 */

import Intents


class IntentHandler: INExtension, INAddTasksIntentHandling, INSearchForNotebookItemsIntentHandling {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }

    // handle for reading the list of task in todo
    func handle(intent: INSearchForNotebookItemsIntent, completion: @escaping (INSearchForNotebookItemsIntentResponse) -> Void) {
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSearchForNotebookItemsIntent.self))
        //let response = INSearchForNotebookItemsIntentResponse(code: .inProgress, userActivity: userActivity)
        let response = INSearchForNotebookItemsIntentResponse(code: .success, userActivity: userActivity)
        // Initialize with found message's attributes
        response.tasks = []
        TaskManager.sharedInstance.tasksForList(withName: "todo", oncompletion: {(taskTitles) in
            for taskTitle in taskTitles {
                response.tasks?.append(INTask(
                    title: INSpeakableString(spokenPhrase: taskTitle),
                    status: .notCompleted,
                    taskType: .completable,
                    spatialEventTrigger: nil,
                    temporalEventTrigger: nil,
                    createdDateComponents: nil,
                    modifiedDateComponents: nil,
                    identifier: nil))
            }
            completion(response)
        })
    }
    
    // Creates a list of tasks to be returned to Siri
    func createTasks(fromTitles taskTitles: [String]) -> [INTask] {
        var tasks: [INTask] = []
        tasks = taskTitles.map { taskTitle -> INTask in
            let task = INTask(title: INSpeakableString(spokenPhrase: taskTitle),
                              status: .notCompleted,
                              taskType: .completable,
                              spatialEventTrigger: nil,
                              temporalEventTrigger: nil,
                              createdDateComponents: nil,
                              modifiedDateComponents: nil,
                              identifier: nil)
            return task
        }
        return tasks
    }
    
    func handle(intent: INAddTasksIntent, completion: @escaping (INAddTasksIntentResponse) -> Void) {
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INAddTasksIntent.self))
        let taskList = intent.targetTaskList
        // TODO assume todo list if not specified
        
        guard let title = taskList?.title else {
            completion(INAddTasksIntentResponse(code: .failure, userActivity: nil))
            return
        }
        var tasks: [INTask] = []
        if let taskTitles = intent.taskTitles {
            let taskTitlesStrings = taskTitles.map {
                taskTitle -> String in
                return taskTitle.spokenPhrase
            }
            tasks = createTasks(fromTitles: taskTitlesStrings)
            TaskManager.sharedInstance.add(tasks: taskTitlesStrings, type: title.spokenPhrase, oncompletion: {
                // to require app launch
                //let response = INAddTasksIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil)
                let response = INAddTasksIntentResponse(code: .success, userActivity: nil)
                response.modifiedTaskList = intent.targetTaskList
                response.addedTasks = tasks
                completion(response)
            })
        }
    }
}
