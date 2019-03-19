//
//  APIChatMessage.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 29.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIChatMessage: ChatMessageProtocol, Codable {
    public var id: String?
    public var userID: String?
    public var text: String?
    public var attributedText: NSAttributedString?
    public var timestamp: Date?
    public var displayName: String?
    public var username: String?
    public var flagCount: Int
    public var contributor: ContributorProtocol?
    public var userStyles: UserStyleProtocol?
    public var likes: [ChatMessageReactionProtocol] = []
    public var flags: [ChatMessageReactionProtocol] = []
    public var isValid: Bool {
        return true
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "uuid"
        case text
        case timestamp
        case displayName = "user"
        case username
        case flagCount
        case contributor
        case userStyles
        case likes
        case flags
    }
   
    enum ContainerCodingKeys: String, CodingKey {
        case message
    }
    
    public required init(from decoder: Decoder) throws {
        let messageContainer = try decoder.container(keyedBy: ContainerCodingKeys.self)
        let values = try messageContainer.contains(.message) ? messageContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .message) : decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(String.self, forKey: .id)
        userID = try? values.decode(String.self, forKey: .userID)
        text = try? values.decode(String.self, forKey: .text)
        if let timeStampNumber = try? values.decode(Double.self, forKey: .timestamp) {
            timestamp = Date(timeIntervalSince1970: timeStampNumber/1000)
        }
        displayName = try? values.decode(String.self, forKey: .displayName)
        username = try? values.decode(String.self, forKey: .username)
        flagCount = (try? values.decode(Int.self, forKey: .flagCount)) ?? 0
        contributor = (try? values.decode(APIContributor.self, forKey: .contributor))
        if values.contains(.userStyles) {
            userStyles = try? values.decode(APIUserStyle.self, forKey: .userStyles)
        }
        if values.contains(.likes) {
            likes = APIChatMessageReaction.fromList(try values.decode([String: Bool].self, forKey: .likes))
        }
        if values.contains(.flags) {
            flags = APIChatMessageReaction.fromList(try values.decode([String: Bool].self, forKey: .flags))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
