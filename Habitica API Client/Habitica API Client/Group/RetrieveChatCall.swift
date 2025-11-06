//
//  RetrieveChatCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 30.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveChatCall: ResponseArrayCall<ChatMessageProtocol, APIChatMessage> {
    public init(groupID: String, limit: Int? = nil, before: String? = nil) {
        var endpoint = "groups/\(groupID)/chat"
        var queryParams: [String] = []

        if let limit = limit {
            queryParams.append("limit=\(limit)")
        }

        if let before = before {
            queryParams.append("before=\(before)")
        }

        if !queryParams.isEmpty {
            endpoint += "?" + queryParams.joined(separator: "&")
        }

        super.init(httpMethod: .GET, endpoint: endpoint)
    }
}
