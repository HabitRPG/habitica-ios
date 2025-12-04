//
//  AuthenticationManager.swift
//  Habitica
//
//  Created by Phillip on 29.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation

class AuthenticationManager {
    func initialize(withStorage storage: AuthenticationStorage) {
        self.storage = storage
        // This is to properly run the setters so that the app is correctly configured
        currentUserId = storage.userID
        currentUserKey = storage.apiKey
    }
    
    static let shared = AuthenticationManager()
    var storage: AuthenticationStorage?

    var currentUserId: String? {
        get {
            return storage?.userID
        }
        
        set(newValue) {
            storage?.userID = newValue
        }
    }

    var currentUserKey: String? {
        get {
            return storage?.apiKey
        }
        
        set(newValue) {
            storage?.apiKey = newValue
        }
    }

    func hasAuthentication() -> Bool {
        return currentUserId?.isEmpty == false && currentUserKey?.isEmpty == false
    }

    func setAuthentication(userId: String, key: String) {
        currentUserId = userId
        currentUserKey = key
    }

    func clearAuthenticationForAllUsers() {
        currentUserId = nil
        currentUserKey = nil
    }

    func clearAuthentication(userId: String) {
        // Will be used once we support multiple users
        clearAuthenticationForAllUsers()
    }
}
