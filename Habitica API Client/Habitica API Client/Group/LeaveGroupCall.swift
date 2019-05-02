//
//  LeaveGroupCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 11.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class LeaveGroupCall: ResponseObjectCall<GroupProtocol, APIGroup> {
    public init(groupID: String, leaveChallenges: Bool, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "group.json")) {
        var data = [String: String]()
        if leaveChallenges {
            data["keepChallenges"] = "leave-challenges"
        } else {
            data["keepChallenges"] = "remain-in-challenge"
        }
        let json = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "groups/\(groupID)/leave", postData: json, stubHolder: stubHolder)
    }
}
