//
//  APITag.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APITag: TagProtocol, Codable {
    public var id: String?
    public var text: String?
    public var order: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id
        case text = "name"
    }
    
    init(_ id: String) {
        self.id = id
    }
    
    init(_ tagProtocol: TagProtocol) {
        id = tagProtocol.id
        text = tagProtocol.text
    }
}
