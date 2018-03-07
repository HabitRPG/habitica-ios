//
//  DateDecodingStrategy-Extension.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

extension JSONDecoder {
    
    func setHabiticaDateDecodingStrategy() {
        self.dateDecodingStrategy = .custom({ dateDecoder -> Date in
            let container = try dateDecoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
            
            return dateFormatter.date(from: dateStr) ?? Date()
        })
    }
    
}
