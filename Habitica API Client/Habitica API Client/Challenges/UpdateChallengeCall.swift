//
//  CreateChallengeCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 11.03.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//
import Foundation
import Habitica_Models

public class UpdateChallengeCall: ResponseObjectCall<ChallengeProtocol, APIChallenge> {
    public init(challenge: ChallengeProtocol) {
        let encoder = JSONEncoder()
        encoder.setHabiticaDateEncodingStrategy()
        let json = try? encoder.encode(APIChallenge(challenge))
        super.init(httpMethod: .PUT, endpoint: "challenges/\(challenge.id ?? "")", postData: json)
    }
}
