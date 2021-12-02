//
//  BaseModel.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 02.12.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

class BaseModel: Object, BaseModelProtocol {
    @objc dynamic var modelID: String?

    var isValid: Bool {
        return !isInvalidated
    }
    
    var isManaged: Bool {
        return realm != nil
    }
}
