//
//  LeaveChallengeCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 24.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class LeaveChallengeCall: ResponseObjectCall<ChallengeProtocol, APIChallenge> {
    public init(challengeID: String, keepTasks: Bool, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "group.json")) {
        var data = [String: String]()
        if keepTasks {
            data["keep"] = "keep-all"
        } else {
            data["keep"] = "remove-all"
        }
        let json = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "challenges/\(challengeID)/leave", postData: json, stubHolder: stubHolder)
    }
}
