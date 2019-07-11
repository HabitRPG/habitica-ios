//
//  RegisterPushDeviceCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 28.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class RegisterPushDeviceCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(regID: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "tasks.json")) {
        let json = try? JSONSerialization.data(withJSONObject: ["regId": regID, "type": "ios"], options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "user/push-devices", postData: json, stubHolder: stubHolder)
    }
}
