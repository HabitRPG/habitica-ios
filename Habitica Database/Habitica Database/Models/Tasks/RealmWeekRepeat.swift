//
//  RealmWeekRepeat.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 26.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmWeekRepeat: Object, WeekRepeatProtocol {
    var monday: Bool = true
    var tuesday: Bool = true
    var wednesday: Bool = true
    var thursday: Bool = true
    var friday: Bool = true
    var saturday: Bool = true
    var sunday: Bool = true
    
    @objc dynamic var id: String?
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(id: String, weekRepeat: WeekRepeatProtocol) {
        self.init()
        self.id = id
        monday = weekRepeat.monday
        tuesday = weekRepeat.tuesday
        wednesday = weekRepeat.wednesday
        thursday = weekRepeat.thursday
        friday = weekRepeat.friday
        saturday = weekRepeat.saturday
        sunday = weekRepeat.sunday
    }
}
