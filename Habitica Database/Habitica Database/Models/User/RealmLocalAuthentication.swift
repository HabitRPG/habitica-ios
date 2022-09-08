//
//  RealmLocalAuthentication.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

class RealmLocalAuthentication: Object, LocalAuthenticationProtocol {
    @objc dynamic var email: String?
    @objc dynamic var username: String?
    @objc dynamic var lowerCaseUsername: String?
    @objc dynamic var hasPassword: Bool = false
    
    @objc dynamic var id: String?
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(userID: String?, protocolObject: LocalAuthenticationProtocol) {
        self.init()
        self.id = userID
        email = protocolObject.email
        username = protocolObject.username
        lowerCaseUsername = protocolObject.lowerCaseUsername
        hasPassword = protocolObject.hasPassword
    }
}
