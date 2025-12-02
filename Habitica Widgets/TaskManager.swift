//
//  TaskManager.swift
//  Habitica
//
//  Created by Phillip Thelen on 01.12.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import Habitica_Database
import ReactiveSwift
import RealmSwift

class TaskManager {
    static let shared = TaskManager()
    private let userLocalRepository = UserLocalRepository()
    private let localRepository = TaskLocalRepository()

    private var userID = ""
    
    init() {
        userID = UserDefaults.standard.string(forKey: "currentUserId") ?? ""
        setupDatabase()
    }

    @objc
    func setupDatabase() {
        var config = Realm.Configuration.defaultConfiguration
        config.deleteRealmIfMigrationNeeded = true
        config.maximumNumberOfActiveVersions = 1
        let fileUrl = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.habitrpg.habitica")?
            .appendingPathComponent("habitica.realm")
        if let url = fileUrl {
            config.fileURL = url
        }
        print("Realm stored at:", config.fileURL ?? "")
        Realm.Configuration.defaultConfiguration = config
    }

    func getTasks(predicate: NSPredicate, sortKey: String = "order") -> [TaskProtocol] {
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
        return localRepository.getTasksAsync(userID: userID, predicate: predicate, sortKey: sortKey) ?? []
    }

    func getUser() -> UserProtocol? {
        return userLocalRepository.getUserAsync(userID)
    }
}
