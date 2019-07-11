//
//  RealmTutorialStep.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 30.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmTutorialStep: Object, TutorialStepProtocol {
    @objc dynamic var combinedKey: String?
    @objc dynamic var key: String?
    @objc dynamic var type: String?
    @objc dynamic var wasSeen: Bool = false
    
    override static func primaryKey() -> String {
        return "combinedKey"
    }
    
    convenience init(userID: String?, protocolObject: TutorialStepProtocol) {
        self.init()
        self.combinedKey = (userID ?? "") + (protocolObject.type ?? "") + (protocolObject.key ?? "")
        key = protocolObject.key
        type = protocolObject.type
        wasSeen = protocolObject.wasSeen
    }
}
