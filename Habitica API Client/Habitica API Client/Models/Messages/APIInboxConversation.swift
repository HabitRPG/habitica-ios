//
//  APIInboxConversation.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 11.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIInboxConversation: InboxConversationProtocol, Codable {
    public var uuid: String
    public var text: String?
    public var timestamp: Date?
    public var displayName: String?
    public var username: String?
    public var contributor: ContributorProtocol?
    public var userStyles: UserStyleProtocol?
    public var isValid: Bool {
        return true
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case text
        case timestamp
        case displayName = "user"
        case username
        case contributor
        case userStyles
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try values.decode(String.self, forKey: .uuid)
        text = try? values.decode(String.self, forKey: .text)
        let timeStampNumber = try? values.decode(Double.self, forKey: .timestamp)
        if let number = timeStampNumber {
            timestamp = Date(timeIntervalSince1970: number/1000)
        } else {
            timestamp = try? values.decode(Date.self, forKey: .timestamp)
        }
        displayName = try? values.decode(String.self, forKey: .displayName)
        username = try? values.decode(String.self, forKey: .username)
        contributor = (try? values.decode(APIContributor.self, forKey: .contributor))
        if values.contains(.userStyles) {
            userStyles = try? values.decode(APIUserStyle.self, forKey: .userStyles)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
