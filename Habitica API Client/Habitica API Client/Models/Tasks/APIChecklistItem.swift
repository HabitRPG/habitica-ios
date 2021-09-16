//
//  APIChecklistItem.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIChecklistItem: ChecklistItemProtocol, Codable {
    var id: String?
    var text: String?
    var completed: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case completed
    }
    
    init(_ itemProtocol: ChecklistItemProtocol) {
        id = itemProtocol.id
        text = itemProtocol.text
        completed = itemProtocol.completed
    }
    
    func detached() -> ChecklistItemProtocol {
        return self
    }
    
    var isValid: Bool = true
}
