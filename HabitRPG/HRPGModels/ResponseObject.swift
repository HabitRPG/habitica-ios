//
//  ResponseObject.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Eson

public class ResponseObject<T: NSObject>: NSObject {
    var success: Bool = false
    var data: [String: AnyObject]?
    
    func dataObject() -> T? {
        return Eson().fromJsonDictionary(data, clazz: T.self)
    }

}
