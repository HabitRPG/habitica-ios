//
//  RealmPushDevice.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 28.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmPushDevice: Object, PushDeviceProtocol {
    @objc dynamic var combinedKey: String?
    var updatedAt: Date?
    var createdAt: Date?
    var type: String?
    var regId: String?
    
    @objc dynamic var userID: String?
    override static func primaryKey() -> String {
        return "combinedKey"
    }
    
    convenience init(userID: String?, protocolObject: PushDeviceProtocol) {
        self.init()
        self.userID = userID
        combinedKey = (userID ?? "") + String(protocolObject.regId?.hashValue ?? 0)
        updatedAt = protocolObject.updatedAt
        createdAt = protocolObject.createdAt
        type = protocolObject.type
        regId = protocolObject.regId
    }
}
