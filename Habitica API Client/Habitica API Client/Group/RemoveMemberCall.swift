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
    public init(groupID: String, userID: String) {
        super.init(httpMethod: .POST, endpoint: "groups/\(groupID)/removeMember/\(userID)")
    }
}
