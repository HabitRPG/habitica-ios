//
//  RealmContributor.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

@objc
class RealmContributor: Object, ContributorProtocol {
    
    @objc dynamic var level: Int = 0
    @objc dynamic var admin: Bool = false
    @objc dynamic var text: String?
    @objc dynamic var contributions: String?
    
    @objc dynamic var id: String?
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(id: String?, contributor: ContributorProtocol) {
        self.init()
        self.id = id
        level = contributor.level
        admin = contributor.admin
        text = contributor.text
        contributions = contributor.contributions
    }
    
}
