//
//  RetrieveInboxMessagesCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 28.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveInboxMessagesCall: ResponseArrayCall<InboxMessageProtocol, APIInboxMessage> {
    public init(stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "tasks.json")) {
        super.init(httpMethod: .GET, endpoint: "inbox/messages", stubHolder: stubHolder)
    }
}
