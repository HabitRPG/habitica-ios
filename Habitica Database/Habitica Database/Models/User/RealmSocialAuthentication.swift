//
//  RealmSocialAuthentication.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 23.11.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

class RealmSocialAuthentication: Object, SocialAuthenticationProtocol {
    var emails: [String] {
        get {
            return realmEmails.map({ (email) -> String in
                return email
            })
        }
        set {
            realmEmails.removeAll()
            newValue.forEach { (email) in
                realmEmails.append(email)
            }
        }
    }
    var realmEmails = List<String>()
    @objc dynamic var id: String?
    @objc dynamic var userID: String?
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(userID: String?, protocolObject: SocialAuthenticationProtocol) {
        self.init()
        self.userID = userID
        emails = protocolObject.emails
        id = protocolObject.id
    }
}
