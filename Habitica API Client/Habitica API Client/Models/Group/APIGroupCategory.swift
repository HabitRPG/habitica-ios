//
//  APIGroupCategory.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 17.02.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIGroupCategory: GroupCategoryProtocol, Codable {
    var isValid: Bool = true
    
    var id: String?
    var slug: String?
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case slug
        case name
    }
    
    public init(_ category: GroupCategoryProtocol) {
        id = category.id
        slug = category.slug
        name = category.name
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id, forKey: .id)
        try? container.encode(slug, forKey: .slug)
        try? container.encode(name, forKey: .name)
    }
}
