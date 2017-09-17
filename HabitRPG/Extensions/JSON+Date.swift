//
//  JSON+Date.swift
//  Tallyr
//
//  Created by Phillip Thelen on 14/06/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

import UIKit
import SwiftyJSON

extension JSON {
    
    public var date: Date? {
        get {
            if let stringObject = object as? String {
                return Formatter.jsonDateFormatter.date(from: stringObject)
            }
            return nil
        }
    }
    
}
