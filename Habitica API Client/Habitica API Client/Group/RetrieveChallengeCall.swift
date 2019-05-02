//
//  RetrieveChallengeCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 24.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveChallengeCall: ResponseObjectCall<ChallengeProtocol, APIChallenge> {
    public init(challengeID: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "group.json")) {
        super.init(httpMethod: .GET, endpoint: "challenges/\(challengeID)", stubHolder: stubHolder)
    }
}
