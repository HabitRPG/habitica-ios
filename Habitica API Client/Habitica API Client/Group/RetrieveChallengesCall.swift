//
//  RetrieveChallengesCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 24.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveChallengesCall: ResponseArrayCall<ChallengeProtocol, APIChallenge> {
    public init(page: Int, memberOnly: Bool, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "group.json")) {
        var url = "challenges/user?page=\(page)"
        if memberOnly {
            url += "&member=true"
        }
        super.init(httpMethod: .GET, endpoint: url, stubHolder: stubHolder)
    }
}
