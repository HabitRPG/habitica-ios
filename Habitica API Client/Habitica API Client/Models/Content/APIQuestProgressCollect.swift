//
//  APIQuestProgressCollect.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 27.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIQuestProgressCollect: QuestProgressCollectProtocol, Decodable {
    var key: String?
    var count: Int
    
    init(key: String, count: Int) {
        self.key = key
        self.count = count
    }
}
