//
//  RealmChecklistItem.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

class RealmChecklistItem: Object, ChecklistItemProtocol {
    
    @objc dynamic var id: String?
    @objc dynamic var text: String?
    @objc dynamic var completed: Bool = false
    
    convenience init(_ checklistItemProtocol: ChecklistItemProtocol) {
        self.init()
        id = checklistItemProtocol.id
        text = checklistItemProtocol.text
        completed = checklistItemProtocol.completed
    }
}
