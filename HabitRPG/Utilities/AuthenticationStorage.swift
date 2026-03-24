//
//  AuthenticationStorage.swift
//  Habitica
//
//  Created by Phillip Thelen on 03.12.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import Foundation
import KeychainAccess

protocol AuthenticationStorage {
    var userID: String? { get set }
    var apiKey: String? { get set }
}

class KeychainAuthenticationStorage: AuthenticationStorage {
    private let localKeychain = Keychain(service: "com.habitrpg.ios.Habitica", accessGroup: "group.habitrpg.habitica")

    private var keychain: Keychain {
        return Keychain(server: "https://habitica.com", protocolType: .https)
            .accessibility(.afterFirstUnlock)
    }
    
    var userID: String? {
        get {
            // using this to bootstrap identification so user's don't have to re-log in
            guard let cuid = localKeychain["currentUserId"] else {
                let cuid = UserDefaults.standard.string(forKey: "currentUserId")
                localKeychain["currentUserId"] = cuid
                return cuid
            }
            return cuid
        }

        set(newUserId) {
            localKeychain["currentUserId"] = newUserId
        }
    }
    
    var apiKey: String? {
        get {
            if let userID = userID {
                let userKey = keychain[userID]
                if userKey != nil {
                    localKeychain[userID] = userKey
                    return userKey
                } else {
                    return localKeychain[userID]
                }
            }
            return nil
        }

        set(newKey) {
            if let userID = userID {
                keychain[userID] = newKey
                localKeychain[userID] = newKey
            }
        }
    }
}

class MemoryAuthenticationStorage: AuthenticationStorage {
    var userID: String?
    var apiKey: String?
}
