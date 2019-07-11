//
//  PostChatMessageCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 30.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class PostChatMessageCall: ResponseObjectCall<ChatMessageProtocol, APIChatMessage> {
    public init(groupID: String, chatMessage: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "group.json")) {
        let updateDict = [
            "message": chatMessage
        ]
        let json = try? JSONSerialization.data(withJSONObject: updateDict, options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "groups/\(groupID)/chat", postData: json, stubHolder: stubHolder)
    }
}
