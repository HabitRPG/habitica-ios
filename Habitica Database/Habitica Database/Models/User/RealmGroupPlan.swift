//
//  RealmGroupPlan.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 29.08.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

@objc
class RealmGroupPlan: Object, GroupPlanProtocol {
    
    @objc dynamic var combinedID: String?
    @objc dynamic var id: String?
    @objc dynamic var userID: String?
    @objc dynamic var name: String?
    @objc dynamic var leaderID: String?
    @objc dynamic var summary: String?

    override static func primaryKey() -> String {
        return "combinedID"
    }
    
    convenience init(userID: String?, plan: GroupPlanProtocol) {
        self.init()
        self.combinedID = (userID ?? "") + (plan.id ?? "")
        self.id = plan.id
        self.userID = userID
        self.name = plan.name
        self.summary = plan.summary
        self.leaderID = plan.leaderID
    }
    
}
