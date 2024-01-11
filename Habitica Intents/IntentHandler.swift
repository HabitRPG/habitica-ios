//
//  IntentHandler.swift
//  Habitica Intents
//
//  Created by Christopher Coffin on 5/12/19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//
/* Sample intents
 Add the following under Siri intent query:
 
 Example to add a task:
 Add get grocieries to my todo list in Habitica
 
 Example showing tasks in a list
 Show my todo list in Habitica
 */

import Intents

class IntentHandler: INExtension, INAddTasksIntentHandling, INSearchForNotebookItemsIntentHandling {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        return self
    }

    /*  Ensures that we have a valid title for a list when searching for items in a list,
     If siri didn't hear a list that matches one of the known lists, it will ask for the
     user to select from a known list.
     */
    func resolveTitle(for intent: INSearchForNotebookItemsIntent, with completion: @escaping (INSpeakableStringResolutionResult) -> Void) {
        let result: INSpeakableStringResolutionResult
        if let taskList = intent.title {
            if TaskManager.shared.getValidTaskListFromSpokenPhrase(spokenPhrase: taskList.spokenPhrase) == nil {
                // we don't know what it is so ask for clarification
                result = INSpeakableStringResolutionResult.disambiguation(with: TaskManager.shared.spokenTaskTypes.map {
                    return INSpeakableString(spokenPhrase: $0)})
                completion(result)
                return
            }
            result = INSpeakableStringResolutionResult.success(with: taskList)
        } else {
            result = INSpeakableStringResolutionResult.needsValue()
        }
        completion(result)
    }
    
    // handle for reading the list of tasks in one of todo, habit, daily
    func handle(intent: INSearchForNotebookItemsIntent, completion: @escaping (INSearchForNotebookItemsIntentResponse) -> Void) {
        guard let targetTaskList = intent.title else {
            print("Could not find a target task list")
            completion(INSearchForNotebookItemsIntentResponse(code: .failure, userActivity: nil))
            return
        }
        guard let validTaskListTitle = TaskManager.shared.getValidTaskListFromSpokenPhrase(spokenPhrase: targetTaskList.spokenPhrase) else {
            // This should never be hit as we already filter the title
            completion(INSearchForNotebookItemsIntentResponse(code: .failure, userActivity: nil))
            return
        }
        let response = INSearchForNotebookItemsIntentResponse(code: .success, userActivity: NSUserActivity(activityType: NSStringFromClass(INSearchForNotebookItemsIntent.self)))
        // Initialize with found message's attributes
        response.tasks = []
        TaskManager.shared.tasksForList(withName: validTaskListTitle, oncompletion: {(taskTitles) in
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
            return INTask(title: INSpeakableString(spokenPhrase: taskTitle),
                          status: .notCompleted,
                          taskType: .completable,
                          spatialEventTrigger: nil,
                          temporalEventTrigger: nil,
                          createdDateComponents: nil,
                          modifiedDateComponents: nil,
                          identifier: nil)
        }
        return tasks
    }
    
    /* makes sure that we have a valid title for a list when adding a task
     If siri didn't hear a list that matches one of the known lists, it will ask for the
     user to select from a known list.
     */
    func resolveTargetTaskList(for intent: INAddTasksIntent, with completion: @escaping (INTaskListResolutionResult) -> Void) {
        let result: INTaskListResolutionResult
        if let taskList = intent.targetTaskList {
            if TaskManager.shared.getValidTaskListFromSpokenPhrase(spokenPhrase: taskList.title.spokenPhrase) == nil {
                // we don't know what it is so ask for clarification
                result = INTaskListResolutionResult.disambiguation(with: TaskManager.shared.possibleTaskLists)
                completion(result)
                return
            }
            result = INTaskListResolutionResult.success(with: taskList)
        } else {
            result = INTaskListResolutionResult.needsValue()
        }
        
        completion(result)
    }
    
    // handles adding one or more tasks to a list
    func handle(intent: INAddTasksIntent, completion: @escaping (INAddTasksIntentResponse) -> Void) {
        if AuthenticationManager.shared.currentUserKey == nil {
            completion(INAddTasksIntentResponse(code: .failure, userActivity: nil))
            return
        }
        guard let targetTaskList = intent.targetTaskList?.title else {
            completion(INAddTasksIntentResponse(code: .failure, userActivity: nil))
            // to require app launch
            // let response = INAddTasksIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil)
            return
        }
        guard let validTaskListTitle = TaskManager.shared.getValidTaskListFromSpokenPhrase(spokenPhrase: targetTaskList.spokenPhrase) else {
            // This should never be hit as we already filter the title
            completion(INAddTasksIntentResponse(code: .failure, userActivity: nil))
            return
        }

        // add to the given list
        var tasks: [INTask] = []
        if let taskTitles = intent.taskTitles {
            let taskTitlesStrings = taskTitles.map { taskTitle -> String in
                return taskTitle.spokenPhrase
            }
            tasks = createTasks(fromTitles: taskTitlesStrings)
            TaskManager.shared.add(tasks: taskTitlesStrings, type: validTaskListTitle, oncompletion: {
                let response = INAddTasksIntentResponse(code: .success, userActivity: nil)
                response.modifiedTaskList = intent.targetTaskList
                response.addedTasks = tasks
                completion(response)
            })
        }
    }
}
