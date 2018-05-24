//
//  RetrieveChallengesCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 24.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import FunkyNetwork
import ReactiveSwift

public class RetrieveChallengesCall: ResponseArrayCall<ChallengeProtocol, APIChallenge> {
    public init(stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "group.json")) {
        super.init(httpMethod: .GET, endpoint: "challenges/user", stubHolder: stubHolder)
    }
}
