//
//  InviteToGroupCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 20.07.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import FunkyNetwork
import ReactiveSwift

public class InviteToGroupCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(groupID: String, invitationType: String, inviter: String, members: [String], stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "group.json")) {
        let data: [String: Any] = [
            invitationType: members,
            "inviter": inviter
        ]
        let json = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "groups/\(groupID)/invite", postData: json, stubHolder: stubHolder)
    }
}
