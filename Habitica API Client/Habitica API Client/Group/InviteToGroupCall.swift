//
//  InviteToGroupCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 20.07.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class InviteToGroupCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(groupID: String, members: [String: Any], stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "group.json")) {
        let json = try? JSONSerialization.data(withJSONObject: members, options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "groups/\(groupID)/invite", postData: json, stubHolder: stubHolder)
    }
}
