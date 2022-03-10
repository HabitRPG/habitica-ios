//
//  RejectGroupInvitationCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 22.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RejectGroupInvitationCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(groupID: String) {
        super.init(httpMethod: .POST, endpoint: "groups/\(groupID)/reject-invite")
    }
}
