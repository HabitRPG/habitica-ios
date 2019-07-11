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
    public init(groupID: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "group.json")) {
        super.init(httpMethod: .GET, endpoint: "groups/\(groupID)/chat", stubHolder: stubHolder)
    }
}
