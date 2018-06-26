//
//  RetrieveInAppRewardsCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 17.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import FunkyNetwork
import ReactiveSwift

public class RetrieveInAppRewardsCall: ResponseArrayCall<InAppRewardProtocol, APIInAppReward> {
    public init(stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        super.init(httpMethod: .GET, endpoint: "user/in-app-rewards", stubHolder: stubHolder)
    }
}
