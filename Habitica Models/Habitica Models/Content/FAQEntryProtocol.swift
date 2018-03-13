//
//  FAQEntryProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol FAQEntryProtocol {
    var index: Int { get set }
    var question: String? { get set }
    var ios: String? { get set }
    var web: String? { get set }
}

public extension FAQEntryProtocol {
    var answer: String {
        if let iOSAnswer = ios {
            return iOSAnswer
        }
        return web ?? ""
    }
}
