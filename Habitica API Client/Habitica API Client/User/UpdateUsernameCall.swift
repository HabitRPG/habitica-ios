//
//  UpdateUsernameCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import FunkyNetwork
import ReactiveSwift

public class UpdateUsernameCall: ResponseObjectCall<EmptyResponseProtocol, APIEmptyResponse> {
    public init(username: String, password: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let json = try? JSONSerialization.data(withJSONObject: ["username": username, "password": password], options: .prettyPrinted)
        super.init(httpMethod: .PUT, endpoint: "user/auth/update-username", postData: json, stubHolder: stubHolder)
    }
}
