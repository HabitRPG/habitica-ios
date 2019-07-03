//
//  APINotificationNewChatData.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 02.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

private class NewChatGroupData: Decodable {
    var id: String
    var name: String
}

class APINotificationNewChatData: Decodable {
    var groupID: String?
    var groupName: String?
    
    enum CodingKeys: String, CodingKey {
        case group
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let groupData = try? values.decode(NewChatGroupData.self, forKey: .group) {
            groupID = groupData.id
            groupName = groupData.name
        }
    }
}
