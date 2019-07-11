//
//  RealmAchievement.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 11.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmAchievement: Object, AchievementProtocol {
    @objc dynamic var combinedID: String?
    @objc dynamic var userID: String?
    var key: String?
    var type: String?
    var title: String?
    var text: String?
    var icon: String?
    var category: String?
    var earned: Bool = false
    var index: Int = 0
    var optionalCount: Int = -1
    
    
    override static func primaryKey() -> String {
        return "combinedID"
    }
    
    convenience init(userID: String?, protocolObject: AchievementProtocol) {
        self.init()
        self.combinedID = (userID ?? "") + (protocolObject.key ?? "")
        self.userID = userID
        key = protocolObject.key
        type = protocolObject.type
        title = protocolObject.title
        text = protocolObject.text
        icon = protocolObject.icon
        category = protocolObject.category
        earned = protocolObject.earned
        index = protocolObject.index
        optionalCount = protocolObject.optionalCount
    }
}
