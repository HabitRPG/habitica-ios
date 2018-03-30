//
//  APIGroup.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 29.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIGroup: GroupProtocol, Decodable {
    public var id: String?
    public var name: String?
    public var groupDescription: String?
    public var summary: String?
    public var type: String?
    public var memberCount: Int
    public var privacy: String?
    public var balance: Float
    public var quest: QuestStateProtocol?
    public var chat: [ChatMessageProtocol]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case groupDescription = "description"
        case summary
        case type
        case memberCount
        case privacy
        case balance
        case quest
        case chat
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(String.self, forKey: .id)
        name = try? values.decode(String.self, forKey: .name)
        groupDescription = try? values.decode(String.self, forKey: .groupDescription)
        summary = try? values.decode(String.self, forKey: .summary)
        type = try? values.decode(String.self, forKey: .type)
        memberCount = (try? values.decode(Int.self, forKey: .memberCount)) ?? 0
        privacy = try? values.decode(String.self, forKey: .privacy)
        balance = (try? values.decode(Float.self, forKey: .balance)) ?? 0
        quest = try? values.decode(APIQuestState.self, forKey: .quest)
        chat = (try? values.decode([APIChatMessage].self, forKey: .chat)) ?? []
    }
}
