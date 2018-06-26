//
//  APIChatMessageReaction.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 02.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIChatMessageReaction: ChatMessageReactionProtocol, Decodable {
    var userID: String?
    var hasReacted: Bool = false
    
    static func fromList(_ list: [String: Bool]?) -> [APIChatMessageReaction] {
        var returnList = [APIChatMessageReaction]()
        list?.forEach({ (key, value) in
            let newReaction = APIChatMessageReaction()
            newReaction.userID = key
            newReaction.hasReacted = value
            returnList.append(newReaction)
        })
        return returnList
    }
}
