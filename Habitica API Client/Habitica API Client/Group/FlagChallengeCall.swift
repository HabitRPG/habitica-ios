//
//  FlagChallengeCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 24.11.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class FlagChallengeCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(challengeID: String, data: [String: Any]) {
        let json = try? JSONSerialization.data(withJSONObject: data)
        super.init(httpMethod: .POST, endpoint: "challenges/\(challengeID)/flag", postData: json)
    }
}
