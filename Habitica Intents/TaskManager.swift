//
//  TaskManager.swift
//  Habitica
//
//  Created by Christopher Coffin on 3/12/19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import Habitica_Database
import Habitica_API_Client
import ReactiveSwift
import Intents
import RealmSwift

class TaskManager: BaseRepository<TaskLocalRepository> {
    static let shared = TaskManager()
    let listSpokenPhraseMap = ["todo": ["todo", "to do", "to-do", "todos"],
                             "habit": ["habit", "habits"],
                             "daily": ["daily", "dailies", "dailys"]]
    let spokenTaskTypes = ["Habits", "Dailies", "To-Dos"]
    var possibleTaskLists: [INTaskList]
    
    private let userLocalRepository = UserLocalRepository()

    override init() {
        self.possibleTaskLists = self.listSpokenPhraseMap.keys.map {
            return INTaskList(title: INSpeakableString(spokenPhrase: $0 != "todo" ? $0 : "to do"),
                              tasks: [],
                              groupName: nil,
                              createdDateComponents: nil,
                              modifiedDateComponents: nil,
                              identifier: "com.habitica."+$0)}
        super.init()
        AuthenticationManager.shared.initialize(withStorage: KeychainAuthenticationStorage())
        self.setupNetworkClient()
        setupDatabase()
    }

    func getValidTaskListFromSpokenPhrase(spokenPhrase: String) -> String? {
        for minimap in self.listSpokenPhraseMap where minimap.value.contains(spokenPhrase.lowercased()) {
            return minimap.key
        }
        return nil
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
        // AuthenticatedCall.errorHandler = HabiticaNetworkErrorHandler()
        let configuration = URLSessionConfiguration.default
        // NetworkLogger.enableLogging(for: configuration)
        AuthenticatedCall.defaultConfiguration.urlConfiguration = configuration
    }
    
    @objc
    func setupDatabase() {
        var config = Realm.Configuration.defaultConfiguration
        config.deleteRealmIfMigrationNeeded = true
        let fileUrl = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.habitrpg.habitica")?
            .appendingPathComponent("habitica.realm")
        if let url = fileUrl {
            config.fileURL = url
        }
        print("Realm stored at:", config.fileURL ?? "")
        Realm.Configuration.defaultConfiguration = config
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
            AuthenticatedCall.defaultConfiguration = HabiticaServerConfig.from(chosenServer)
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
        let call = RetrieveTasksCall(dueOnDay: dueOnDay, type: type)
        return call.arraySignal.on(value: {[weak self] tasks in
            if let tasks = tasks, dueOnDay == nil {
                self?.localRepository.save(userID: self?.currentUserId, tasks: tasks)
            }
        })
    }

    func tasksForList(withName name: String, oncompletion: @escaping ([String]) -> Void) {
        // The following calls have to run on the main thread to complete successfully
        DispatchQueue.main.sync {
            // start watching for a change in the local repo for todo items
            let taskSignalProducer = self.getTasks(predicate: NSPredicate(format: "type == 'todo'"))
            var disposable: Disposable?
            disposable = taskSignalProducer.on(value: { (tasks, _) in
                var titles: [String] = []
                tasks.forEach({(task) in
                    if let taskTitle = task.text {
                        titles.append(taskTitle)
                    }
                })
                oncompletion(titles)
                disposable?.dispose()
            }).start()
        }
    }

    func add(tasks: [String], type: String, oncompletion: @escaping () -> Void) {
        // validate that it's a known list, so far just todo's are supported, could add habits and dailies
        var addedTasks: [String] = []
        tasks.forEach({(title) in
            createTask(title: title, type: type).observeCompleted {
                addedTasks.append(title)
                if addedTasks.count == tasks.count {
                    oncompletion()
                }
            }
        })
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
        return call.objectSignal.on(value: {[weak self]returnedTask in
            if let returnedTask = returnedTask {
                self?.localRepository.save(userID: self?.currentUserId, task: returnedTask)
            }
        })
    }

    func getUser() -> SignalProducer<UserProtocol, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (userID) in
            return self?.userLocalRepository.getUser(userID) ?? SignalProducer.empty
        })
    }

    func retrieveUser() -> Signal<UserProtocol?, Never> {
        let call = RetrieveUserCall()
        return call.objectSignal.on(value: {[weak self] user in
            if let user = user {
                self?.userLocalRepository.save(user)
            }
        })
    }
}
