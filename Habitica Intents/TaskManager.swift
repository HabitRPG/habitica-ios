//
//  TaskManager.swift
//  Habitica
//
//  Created by Christopher Coffin on 3/12/19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_API_Client
import Habitica_Database
import ReactiveSwift
import Habitica_Models
import Intents


class TaskManager: BaseRepository<TaskLocalRepository>, TaskRepositoryProtocol {
    static let shared = TaskManager()
    let possibleListNames = ["todo", "habit", "daily"]
    var possibleTaskLists: [INTaskList]
    
    override init() {
        self.possibleTaskLists = self.possibleListNames.map {
            return INTaskList(title: INSpeakableString(spokenPhrase: $0),
                              tasks: [],
                              groupName: nil,
                              createdDateComponents: nil,
                              modifiedDateComponents: nil,
                              identifier: "com.habitica."+$0)}
        super.init()
        self.setupNetworkClient()
        if let cid = AuthenticationManager.shared.currentUserId {
            AuthenticationManager.shared.currentUserKey = AuthenticationManager.shared.localKeychain[cid]
        }
        print("Auth at start id, ", AuthenticationManager.shared.currentUserId)
        print("Auth at start key, ", AuthenticationManager.shared.currentUserKey)
    }
    
    func isValidTaskList(taskList: INTaskList) -> Bool {
        return self.possibleListNames.contains(taskList.title.spokenPhrase)
    }
    
    @objc
    func setupNetworkClient() {
        /*
         Comment for code review, TODO, remove:
         This function is a direct copy of the function from AppDelegate, there
         may be a better solution to handle the project inegration, to avoid the duplicate
         code, but it's beyond what I know regarding swift project setup. Alternatively,
         we could separate the code, but that doesn't seem like a call I should make.
         - Chris Coffin
         */
        NetworkAuthenticationManager.shared.currentUserId = AuthenticationManager.shared.currentUserId
        NetworkAuthenticationManager.shared.currentUserKey = AuthenticationManager.shared.currentUserKey
        updateServer()
        //AuthenticatedCall.errorHandler = HabiticaNetworkErrorHandler()
        let configuration = URLSessionConfiguration.default
        //NetworkLogger.enableLogging(for: configuration)
        AuthenticatedCall.defaultConfiguration.urlConfiguration = configuration
    }
    
    func updateServer() {
        /*
         Comment for code review, TODO, remove:
         This function is a direct copy of the function from AppDelegate, there
         may be a better solution to handle the project inegration, to avoid the duplicate
         code, but it's beyond what I know regarding swift project setup. Alternatively,
         we could separate the code, but that doesn't seem like a call I should make.
         - Chris Coffin
         */
        if let chosenServer = UserDefaults().string(forKey: "chosenServer") {
            switch chosenServer {
            case "staging":
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.staging
            case "beta":
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.beta
            case "gamma":
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.gamma
            case "delta":
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.delta
            default:
                AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.production
            }
        }
    }
    
    func getTasks(predicate: NSPredicate, sortKey: String = "order") -> SignalProducer<ReactiveResults<[TaskProtocol]>, ReactiveSwiftRealmError> {
        /*
         Comment for code review, TODO, remove:
         This function is a direct copy of the function from TaskRepositoryImpl, there
         may be a better solution to handle the project inegration, to avoid the duplicate
         code, but it's beyond what I know regarding swift project setup. Alternatively,
         we could separate the code, but that doesn't seem like a call I should make.
         
         Adding TaskManagerImpl directly causes there to be a chain of inclusions which
         leads to inclusions of many of the UI elements as well. This seemed like to many
         dependencies for these two functions.
         - Chris Coffin
         */
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (userID) in
            return self?.localRepository.getTasks(userID: userID, predicate: predicate, sortKey: sortKey) ?? SignalProducer.empty
        })
    }
    
    func retrieveTasks(dueOnDay: Date? = nil, type: String? = "todo") -> Signal<[TaskProtocol]?, Never> {
        /*
         Comment for code review, TODO, remove:
         This function is a direct copy of the function from TaskRepositoryImpl, there
         may be a better solution to handle the project inegration, to avoid the duplicate
         code, but it's beyond what I know regarding swift project setup. Alternatively,
         we could separate the code, but that doesn't seem like a call I should make.
         
         Adding TaskManagerImpl directly causes there to be a chain of inclusions which
         leads to inclusions of many of the UI elements as well. This seemed like to many
         dependencies for these two functions.
         - Chris Coffin
         */
        let call = RetrieveTasksCall(dueOnDay: dueOnDay)//, type: "todo"
        call.fire()
        return call.arraySignal.on(value: {[weak self] tasks in
            if let tasks = tasks, dueOnDay == nil {
                self?.localRepository.save(userID: self?.currentUserId, tasks: tasks)
            }
        })
    }
    
    func tasksForList(withName name: String, oncompletion: @escaping ([String]) -> Void) {
        // The following calls have to run on the main thread to complete successfully
        DispatchQueue.main.sync{
            let signalObserver = Signal<[TaskProtocol]?, Never>.Observer(
                value: { value in
                    print("Got value from server ?? got no value", value ?? "no value")
                    /*
                    var titles: [String] = []
                    value?.forEach({(task) in
                        if let taskTitle = task.text {
                            if !task.completed && task.isValid {
                                titles.append(taskTitle)
                            }
                        }
                    })
                    print("server direct titles", titles)
                    oncompletion(titles)*/
            }, completed: {
                print("DEBUG completed")
            }, interrupted: {
                print("DEBUG interrupted")
            })
            // start watching for a change in the local repo for todo items
            let taskSignalProducer = self.getTasks(predicate: NSPredicate(format: "type == 'todo'"))
            var disposable: Disposable?
            disposable = taskSignalProducer.on(value: {[weak self](tasks, changes) in
                var titles: [String] = []
                tasks.forEach({(task) in
                    if let taskTitle = task.text {
                        titles.append(taskTitle)
                    }
                })
                print("DEBUG have titles and changes", titles, changes)
                oncompletion(titles)
                disposable?.dispose()
            }).start()
            // start getting the tasks from the server, which will trigger a local change
            self.retrieveTasks().observe(signalObserver)
        }
    }
    
    func add(tasks: [String], type: String, oncompletion: @escaping () -> Void) {
        // validate that it's a known list, so far just todo's are supported, could add habits and dailies
        tasks.forEach({(title) in
            createTask(title: title, type: type).observeCompleted {}
        })
        oncompletion()
    }
    
    func createTask(title: String, type: String) -> Signal<TaskProtocol?, Never> {
        // create a blank task
        let task = localRepository.getNewTask()
        // set title and text as that's all we know about from a simple comm
        task.text = title
        task.type = type
        // notes and start date specified for the sake of adding habits
        task.notes = ""
        task.startDate = Date()
        // actually add the task and start it syncing with server
        localRepository.save(userID: currentUserId, task: task)
        localRepository.setTaskSyncing(userID: currentUserId, task: task, isSyncing: true)
        let call = CreateTaskCall(task: task)
        call.fire()
        return call.objectSignal.on(value: {[weak self]returnedTask in
            if let returnedTask = returnedTask {
                self?.localRepository.save(userID: self?.currentUserId, task: returnedTask)
            }
        })
    }
    
}
