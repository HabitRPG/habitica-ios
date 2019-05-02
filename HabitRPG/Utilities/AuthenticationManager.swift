//
//  AuthenticationManager.swift
//  Habitica
//
//  Created by Phillip on 29.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import KeychainAccess
import Crashlytics
import Amplitude_iOS
import Habitica_API_Client

class AuthenticationManager: NSObject {
    
    @objc static let shared = AuthenticationManager()
    
    private var keychain: Keychain {
        return Keychain(server: "https://habitica.com", protocolType: .https)
            .accessibility(.afterFirstUnlock)
    }
    
    @objc var currentUserId: String? {
        get {
            let defaults = UserDefaults.standard
            return defaults.string(forKey: "currentUserId")
        }
        
        set(newUserId) {
            let defaults = UserDefaults.standard
            defaults.set(newUserId, forKey: "currentUserId")
            NetworkAuthenticationManager.shared.currentUserId = newUserId
            currentUserIDProperty.value = newUserId
            if newUserId != nil {
                Crashlytics.sharedInstance().setUserIdentifier(newUserId)
                Crashlytics.sharedInstance().setUserName(newUserId)
                Amplitude.instance().setUserId(newUserId)
            }
        }
    }
    
    var currentUserIDProperty = MutableProperty<String?>(nil)
    
    @objc var currentUserKey: String? {
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
            NetworkAuthenticationManager.shared.currentUserKey = newKey
        }
    }
    
    override init() {
        super.init()
        currentUserIDProperty.value = currentUserId
    }
    
    @objc
    func hasAuthentication() -> Bool {
        if let userId = self.currentUserId {
            return userId.isEmpty == false
        }
        return false
    }
    
    @objc
    func setAuthentication(userId: String, key: String) {
        currentUserId = userId
        currentUserKey = key
    }
    
    @objc
    func clearAuthenticationForAllUsers() {
        currentUserId = nil
        currentUserKey = nil
    }
    
    @objc
    func clearAuthentication(userId: String) {
        //Will be used once we support multiple users
        clearAuthenticationForAllUsers()
    }
}
