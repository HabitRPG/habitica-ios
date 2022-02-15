//
//  RealmGroupCategory.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 17.02.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

class RealmGroupCategory: BaseModel, GroupCategoryProtocol {
    @objc dynamic var id: String?
    @objc dynamic var slug: String?
    @objc dynamic var name: String?
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(_ categoryProtocol: GroupCategoryProtocol) {
        self.init()
        id = categoryProtocol.id
        slug = categoryProtocol.slug
        name = categoryProtocol.name
    }
}
