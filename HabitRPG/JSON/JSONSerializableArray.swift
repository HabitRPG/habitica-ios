//
//  JSONList.swift
//  Habitica
//
//  Created by Phillip on 17.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Array: JSONSerializable {
    
    init(json: JSON) throws {
        guard let serializable = Element.self as? JSONSerializable.Type else {
            throw JSONSerializationError.unserializable
        }
        
        self = json.flatMap { element in
            let result: Element? = (try? serializable.init(json: element.1)) as? Element
            return result
        }
    }
    
}
