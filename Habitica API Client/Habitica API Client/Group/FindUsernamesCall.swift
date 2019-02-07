//
//  FindUsernameCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.02.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import FunkyNetwork
import ReactiveSwift

public class FindUsernamesCall: ResponseArrayCall<MemberProtocol, APIMember> {
    public init(username: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "member.json")) {
        super.init(httpMethod: .GET, endpoint: "members/find/\(username)", stubHolder: stubHolder)
    }
}
