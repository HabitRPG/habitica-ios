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
    public init(message: InboxMessageProtocol, data: [String: Any]) {
        let json = try? JSONSerialization.data(withJSONObject: data)
        super.init(httpMethod: .POST, endpoint: "members/flag-private-message/\(message.id ?? "")", postData: json)
    }
}
