//
//  FindUsernameCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.02.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class FindUsernamesCall: ResponseArrayCall<MemberProtocol, APIMember> {
    public init(username: String, context: String?, id: String?, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "member.json")) {
        var url = "members/find/\(username)"
        if let context = context, let id = id {
            url += "?context=\(context)&id=\(id)"
        }
        super.init(httpMethod: .GET, endpoint: url, stubHolder: stubHolder)
    }
}
