//
//  Formatter.swift
//  Tallyr
//
//  Created by Phillip Thelen on 14/06/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

import UIKit

class Formatter {
    
    private static var internalJsonDateFormatter = DateFormatter() {
        didSet {
            internalJsonDateFormatter.dateFormat = "yyyy-MM-dd"
        }
    }
    private static var internalJsonDateTimeFormatter: DateFormatter?
    
    static var jsonDateFormatter: DateFormatter {
        return internalJsonDateFormatter
    }
    
}
