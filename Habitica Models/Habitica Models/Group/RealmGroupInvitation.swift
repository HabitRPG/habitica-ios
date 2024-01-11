//
//  GroupInvitation.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 22.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

@objc
class  RealmGroupInvitation: Object, GroupInvitationProtocol {
    var isValid: Bool {
        return !isInvalidated
    }
    
    var isManaged: Bool {
        return true
    }
    
    @objc dynamic var combinedID: String = ""
    var id: String?
    @objc dynamic var userID: String?
    var name: String?
    var inviterID: String?
    var isPartyInvitation: Bool = false
    var isPublicGuild: Bool = false
    
    override static func primaryKey() -> String {
        return "combinedID"
    }
    
    convenience init(userID: String?, protocolObject: GroupInvitationProtocol) {
        self.init()
        combinedID = (userID ?? "") + (protocolObject.id ?? "")
        self.userID = userID
        self.id = protocolObject.id
        self.name = protocolObject.name
        self.inviterID = protocolObject.inviterID
        self.isPartyInvitation = protocolObject.isPartyInvitation
        self.isPublicGuild = protocolObject.isPublicGuild
    }
}
