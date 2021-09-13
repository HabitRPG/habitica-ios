//
//  FlagInboxMessageCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 23.08.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class FlagInboxMessageCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(message: InboxMessageProtocol, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "group.json")) {
        super.init(httpMethod: .POST, endpoint: "/flag-private-message/\(message.id ?? "")/flag", stubHolder: stubHolder)
    }
}
