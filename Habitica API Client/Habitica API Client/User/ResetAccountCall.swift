//
//  ResetAccountCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class ResetAccountCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(password: String) {
        let json = try? JSONSerialization.data(withJSONObject: ["password": password], options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "user/reset", postData: json)
    }
}
