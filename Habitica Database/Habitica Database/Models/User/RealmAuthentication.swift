//
//  RealmAuthentication.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

class RealmAuthentication: Object, AuthenticationProtocol {
    var timestamps: AuthenticationTimestampsProtocol? {
        get {
            return realmTimestamps
        }
        set {
            if let value = newValue as? RealmAuthenticationTimestamps {
                realmTimestamps = value
            }
            if let value = newValue {
                realmTimestamps = RealmAuthenticationTimestamps(userID: id, protocolObject: value)
            }
        }
    }
    @objc dynamic var realmTimestamps: RealmAuthenticationTimestamps?
    var local: LocalAuthenticationProtocol? {
        get {
            return realmLocal
        }
        set {
            if let value = newValue as? RealmLocalAuthentication {
                realmLocal = value
            }
            if let value = newValue {
                realmLocal = RealmLocalAuthentication(userID: id, protocolObject: value)
            }
        }
    }
    @objc dynamic var realmLocal: RealmLocalAuthentication?
    
    @objc dynamic var id: String?
    var google: SocialAuthenticationProtocol? {
        get {
            return realmGoogle
        }
        set {
            if let value = newValue as? RealmSocialAuthentication {
                realmGoogle = value
            }
            if let value = newValue {
                realmGoogle = RealmSocialAuthentication(userID: id, protocolObject: value)
            }
        }
    }
    @objc dynamic var realmGoogle: RealmSocialAuthentication?
    var apple: SocialAuthenticationProtocol? {
        get {
            return realmApple
        }
        set {
            if let value = newValue as? RealmSocialAuthentication {
                realmApple = value
            }
            if let value = newValue {
                realmApple = RealmSocialAuthentication(userID: id, protocolObject: value)
            }
        }
    }
    @objc dynamic var realmApple: RealmSocialAuthentication?
    var facebook: SocialAuthenticationProtocol? {
        get {
            return realmFacebook
        }
        set {
            if let value = newValue as? RealmSocialAuthentication {
                realmFacebook = value
            }
            if let value = newValue {
                realmFacebook = RealmSocialAuthentication(userID: id, protocolObject: value)
            }
        }
    }
    @objc dynamic var realmFacebook: RealmSocialAuthentication?
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(userID: String?, protocolObject: AuthenticationProtocol) {
        self.init()
        self.id = userID
        timestamps = protocolObject.timestamps
        local = protocolObject.local
        facebook = protocolObject.facebook
        google = protocolObject.google
        apple = protocolObject.apple
    }
}
