//
//  RetrieveInAppRewardsCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 17.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RetrieveInAppRewardsCall: ResponseArrayCall<InAppRewardProtocol, APIInAppReward> {
    public init(language: String? = nil, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let url = language != nil ? "user/in-app-rewards?language=\(language ?? "")" : "user/in-app-rewards"
        super.init(httpMethod: .GET, endpoint: url, stubHolder: stubHolder)
    }
}
