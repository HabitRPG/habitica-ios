//
//  RealmUserNewMessages.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 13.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmUserNewMessages: Object, UserNewMessagesProtocol {
    @objc dynamic var combinedID: String?
    @objc dynamic var userID: String?
    var id: String?
    var name: String?
    var hasNewMessages: Bool = false
    
    override static func primaryKey() -> String {
        return "combinedID"
    }
    
    convenience init(userID: String?, protocolObject: UserNewMessagesProtocol) {
        self.init()
        self.combinedID = (userID ?? "") + (protocolObject.id ?? "")
        self.userID = userID
        id = protocolObject.id
        name = protocolObject.name
        hasNewMessages = protocolObject.hasNewMessages
    }
}
