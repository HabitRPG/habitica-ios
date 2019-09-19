//
//  RetrieveInboxConversationsCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 11.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveInboxConversationsCall: ResponseArrayCall<InboxConversationProtocol, APIInboxConversation> {
    public init(stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "tasks.json")) {
        super.init(httpMethod: .GET, endpoint: "inbox/conversations", stubHolder: stubHolder)
    }
}
