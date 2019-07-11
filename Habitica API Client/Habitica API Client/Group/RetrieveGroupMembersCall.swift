//
// Created by Phillip Thelen on 02.05.18.
// Copyright (c) 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveGroupMembersCall: ResponseArrayCall<MemberProtocol, APIMember> {
    public init(groupID: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "member.json")) {
        super.init(httpMethod: .GET, endpoint: "groups/\(groupID)/members?includeAllPublicFields=true", stubHolder: stubHolder)
    }
}
