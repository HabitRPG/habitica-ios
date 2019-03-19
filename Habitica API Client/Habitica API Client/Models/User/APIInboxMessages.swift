//
//  APIInboxMessages.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 25.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIInboxMessage: InboxMessageProtocol, Decodable {
    public var id: String?
    public var userID: String?
    public var contributor: ContributorProtocol?
    public var timestamp: Date?
    public var likes: [ChatMessageReactionProtocol] = []
    public var flags: [ChatMessageReactionProtocol] = []
    public var text: String?
    public var attributedText: NSAttributedString?
    public var sent: Bool
    public var sort: Int
    public var displayName: String?
    public var username: String?
    public var flagCount: Int
    public var userStyles: UserStyleProtocol?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "uuid"
        case text
        case timestamp
        case displayName = "user"
        case username
        case flagCount
        case contributor
        case likes
        case flags
        case sent
        case sort
        case userStyles
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(String.self, forKey: .id)
        userID = try? values.decode(String.self, forKey: .userID)
        text = try? values.decode(String.self, forKey: .text)
        timestamp = try? values.decode(Date.self, forKey: .timestamp)
        displayName = try? values.decode(String.self, forKey: .displayName)
        username = try? values.decode(String.self, forKey: .username)
        flagCount = (try? values.decode(Int.self, forKey: .flagCount)) ?? 0
        contributor = (try? values.decode(APIContributor.self, forKey: .contributor))
        if values.contains(.userStyles) {
            userStyles = try? values.decode(APIUserStyle.self, forKey: .userStyles)
        }
        if values.contains(.likes) {
            likes = APIChatMessageReaction.fromList(try? values.decode([String: Bool].self, forKey: .likes))
        }
        if values.contains(.flags) {
            flags = APIChatMessageReaction.fromList(try? values.decode([String: Bool].self, forKey: .flags))
        }
        sent = (try? values.decode(Bool.self, forKey: .sent)) ?? false
        sort = (try? values.decode(Int.self, forKey: .sort)) ?? 0
    }
}
