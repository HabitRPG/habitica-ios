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
    @objc dynamic var facebookID: String?
    @objc dynamic var googleID: String?
    @objc dynamic var appleID: String?
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(userID: String?, protocolObject: AuthenticationProtocol) {
        self.init()
        self.id = userID
        timestamps = protocolObject.timestamps
        local = protocolObject.local
        facebookID = protocolObject.facebookID
        googleID = protocolObject.googleID
        appleID = protocolObject.appleID
    }
}
