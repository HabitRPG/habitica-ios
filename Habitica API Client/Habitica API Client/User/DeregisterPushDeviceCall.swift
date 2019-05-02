//
//  DeregisterPushDeviceCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 28.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class DeregisterPushDeviceCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(regID: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "tasks.json")) {
        super.init(httpMethod: .DELETE, endpoint: "user/push-devices/\(regID)", stubHolder: stubHolder)
    }
}
