//
//  ResponseArray.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Eson

public class ResponseArray<T: NSObject>: NSObject {
    var success: Bool = false
    var data: [[String: AnyObject]]?
    
    func dataArray() -> [T]? {
        return Eson().fromJsonArray(data, clazz: T.self)
    }
}
