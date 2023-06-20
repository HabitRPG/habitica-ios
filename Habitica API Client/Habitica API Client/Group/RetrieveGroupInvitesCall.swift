//
//  RetrieveGroupInvitesCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 19.06.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveGroupInvitesCall: ResponseArrayCall<MemberProtocol, APIMember> {
    public init(groupID: String) {
        super.init(httpMethod: .GET, endpoint: "groups/\(groupID)/invites?includeAllPublicFields=true")
    }
}
