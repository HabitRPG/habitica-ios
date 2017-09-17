//
//  JsonSerializable.swift
//  Habitica
//
//  Created by Phillip on 17.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

enum JSONSerializationError: Error {
    case unserializable
}

protocol JSONSerializable {
    
    init(json: JSON) throws
    
}
