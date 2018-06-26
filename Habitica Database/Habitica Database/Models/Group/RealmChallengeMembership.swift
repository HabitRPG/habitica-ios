//
//  RealmChallengeMembership.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 24.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmChallengeMembership: Object, ChallengeMembershipProtocol {
    
    @objc dynamic var combinedID: String = ""
    @objc dynamic var userID: String?
    @objc dynamic var challengeID: String?
    
    override static func primaryKey() -> String {
        return "combinedID"
    }
    
    convenience init(userID: String?, protocolObject: ChallengeMembershipProtocol) {
        self.init()
        combinedID = (userID ?? "") + (protocolObject.challengeID ?? "")
        self.userID = userID
        self.challengeID = protocolObject.challengeID
    }
    convenience init(userID: String?, challengeID: String?) {
        self.init()
        combinedID = (userID ?? "") + (challengeID ?? "")
        self.userID = userID
        self.challengeID = challengeID
    }
}
