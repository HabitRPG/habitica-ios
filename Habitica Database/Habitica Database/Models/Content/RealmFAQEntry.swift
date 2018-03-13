//
//  RealmFAQEntry.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmFAQEntry: Object, FAQEntryProtocol {
    @objc dynamic var index: Int = 0
    @objc dynamic var question: String?
    @objc dynamic var ios: String?
    @objc dynamic var web: String?
    
    override static func primaryKey() -> String {
        return "index"
    }
    
    convenience init(_ entry: FAQEntryProtocol) {
        self.init()
        index = entry.index
        question = entry.question
        ios = entry.ios
        web = entry.web
    }
}
