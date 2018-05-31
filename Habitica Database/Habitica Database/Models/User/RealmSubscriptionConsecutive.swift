//
//  RealmSubscriptionConsecutive.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 23.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmSubscriptionConsecutive: Object, SubscriptionConsecutiveProtocol {
    @objc dynamic var hourglasses: Int = 0
    @objc dynamic var gemCapExtra: Int = 0
    @objc dynamic var count: Int = 0
    @objc dynamic var offset: Int = 0
    
    @objc dynamic var id: String?
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(userID: String?, protocolObject: SubscriptionConsecutiveProtocol) {
        self.init()
        self.id = userID
        hourglasses = protocolObject.hourglasses
        gemCapExtra = protocolObject.gemCapExtra
        count = protocolObject.count
        offset = protocolObject.offset
    }
    
}
