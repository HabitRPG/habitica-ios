//
//  RealmInbox.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 03.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmInbox: Object, InboxProtocol {
    @objc dynamic var id: String?
    @objc dynamic var optOut: Bool = false
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(id: String?, inboxProtocol: InboxProtocol) {
        self.init()
        self.id = id
        self.optOut = inboxProtocol.optOut
    }
}
