//
//  DateEncodingStrategy-Extension.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 01.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

extension JSONEncoder {
    
    func setHabiticaDateEncodingStrategy() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateEncodingStrategy = .formatted(dateFormatter)
    }
    
}
