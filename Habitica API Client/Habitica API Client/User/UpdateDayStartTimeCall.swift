//
//  UpdateDayStartTimeCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 31.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class UpdateDayStartTimeCall: ResponseObjectCall<UserProtocol, APIUser> {
    public init(_ time: Int, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let json = try? JSONSerialization.data(withJSONObject: ["dayStart": time], options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "user/custom-day-start", postData: json, stubHolder: stubHolder)
    }
}
