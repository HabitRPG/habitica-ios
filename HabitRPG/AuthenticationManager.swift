//
//  AuthenticationManager.swift
//  Habitica
//
//  Created by Phillip on 29.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import PDKeychainBindingsController
import KeychainAccess
class AuthenticationManager: NSObject {
    
    static let shared = AuthenticationManager()

    func migrateAuthentication() {
        let defaults = UserDefaults.standard
        guard let oldKeychain = PDKeychainBindingsController.shared() else {
            return
        }
        if defaults.string(forKey: "currentUserId") == nil, let userId = oldKeychain.string(forKey: "id") {
            defaults.set(userId, forKey: "currentUserId")
            keychain[userId] = oldKeychain.string(forKey: "key") ?? ""
        }
    }
    
    private var keychain: Keychain {
        return Keychain(server: "https://habitica.com", protocolType: .https)
            .accessibility(.afterFirstUnlock)
    }
    
    var currentUserId: String? {
        get {
            let defaults = UserDefaults.standard
            return defaults.string(forKey: "currentUserId")
        }
        
        set(newUserId) {
            let defaults = UserDefaults.standard
            defaults.set(newUserId, forKey: "currentUserId")
        }
    }
    
    var currentUserKey: String? {
        get {
            if let userId = self.currentUserId {
                return keychain[userId]
            }
            return nil
        }
        
        set(newKey) {
            if let userId = self.currentUserId {
                keychain[userId] = newKey
            }
        }
    }
    
    func hasAuthentication() -> Bool {
        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            //If in snapshot mode it should always start fresh on launch
            return false
        }
        if let userId = self.currentUserId {
            return userId.characters.count > 0
        }
        return false
    }
    
    func setAuthentication(userId: String, key: String) {
        currentUserId = userId
        currentUserKey = key
    }
    
    func clearAuthenticationForAllUsers() {
        currentUserId = nil
        currentUserKey = nil
        
        guard let oldKeychain = PDKeychainBindingsController.shared() else {
            return
        }
        oldKeychain.store(nil, forKey: "id")
        oldKeychain.store(nil, forKey: "key")
    }
    
    func clearAuthentication(userId: String) {
        //Will be used once we support multiple users
        clearAuthenticationForAllUsers()
    }
}
