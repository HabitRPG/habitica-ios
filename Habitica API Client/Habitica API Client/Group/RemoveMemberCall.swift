//
//  TransferOwnershipCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 16.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RemoveMemberCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(groupID: String, userID: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "member.json")) {
        super.init(httpMethod: .GET, endpoint: "groups/\(groupID)/removeMember/\(userID)", stubHolder: stubHolder)
    }
}
