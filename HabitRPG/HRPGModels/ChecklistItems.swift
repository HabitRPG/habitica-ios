//
//  ChecklistItems.swift
//  Habitica
//
//  Created by Phillip on 17.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class ChecklistItem: Object, JSONSerializable {
    
    dynamic var id = ""
    dynamic var completed = false
    dynamic var text = ""
    dynamic var currentlyChecking = false
    
    convenience required init(json: JSON) {
        self.init()
        self.id = json["id"].stringValue
        self.text = json["text"].stringValue
        self.completed = json["completed"].boolValue
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
