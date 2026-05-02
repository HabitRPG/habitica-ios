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
import Habitica_API_Client
import RealmSwift

class TaskManager {
    static let shared = TaskManager()
    private let userLocalRepository = UserLocalRepository()
    private let localRepository = TaskLocalRepository()

    init() {
        AuthenticationManager.shared.initialize(withStorage: KeychainAuthenticationStorage())
        setupDatabase()
        setupNetworkClient()
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
        Realm.Configuration.defaultConfiguration = config
    }

    @objc
    func setupNetworkClient() {
        NetworkAuthenticationManager.shared.currentUserId = AuthenticationManager.shared.currentUserId
        NetworkAuthenticationManager.shared.currentUserKey = AuthenticationManager.shared.currentUserKey
        let configuration = URLSessionConfiguration.default
        AuthenticatedCall.defaultConfiguration.urlConfiguration = configuration
    }

    func getTasks(predicate: NSPredicate, sortKey: String = "order") -> [TaskProtocol] {
        guard let userID = AuthenticationManager.shared.currentUserId else {
            return []
        }
        return localRepository.getTasksAsync(userID: userID, predicate: predicate, sortKey: sortKey) ?? []
    }

    func getUser() -> UserProtocol? {
        guard let userID = AuthenticationManager.shared.currentUserId else {
            return nil
        }
        return userLocalRepository.getUserAsync(userID)
    }

    func markTaskCompleted(taskId: String) {
        localRepository.markTaskCompleted(taskId: taskId)
    }
}
