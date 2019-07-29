//
//  APIAchievement.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 11.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIAchievement: Decodable, AchievementProtocol {
    public var key: String?
    public var title: String?
    public var text: String?
    public var icon: String?
    public var category: String?
    public var earned: Bool = false
    public var index: Int = 0
    public var optionalCount: Int = -1
    
    enum CodingKeys: String, CodingKey {
        case key
        case type
        case title
        case text
        case icon
        case category
        case earned
        case index
        case optionalCount
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try? values.decode(String.self, forKey: .key)
        title = try? values.decode(String.self, forKey: .title)
        text = try? values.decode(String.self, forKey: .text)
        icon = try? values.decode(String.self, forKey: .icon)
        index = (try? values.decode(Int.self, forKey: .index)) ?? 0
        earned = (try? values.decode(Bool.self, forKey: .earned)) ?? false
        optionalCount = (try? values.decode(Int.self, forKey: .optionalCount)) ?? -1
    }
    
    init() {
    }
}
