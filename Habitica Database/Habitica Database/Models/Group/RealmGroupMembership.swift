//
//  RealmGroupMembership.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 03.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmGroupMembership: Object, GroupMembershipProtocol {
    
    @objc dynamic var combinedID: String = ""
    @objc dynamic var userID: String?
    @objc dynamic var groupID: String?
    
    override static func primaryKey() -> String {
        return "combinedID"
    }
    
    convenience init(userID: String?, groupID: String?) {
        self.init()
        combinedID = (userID ?? "") + (groupID ?? "")
        self.userID = userID
        self.groupID = groupID
    }
    
}
