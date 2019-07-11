//
//  VerifyUsernameCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.10.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class VerifyUsernameCall: ResponseObjectCall<VerifyUsernameResponse, APIVerifyUsernameResponse> {
    public init(username: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let obj = ["username": username]
        let json = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "user/auth/verify-username", postData: json, stubHolder: stubHolder)
        needsAuthentication = false
    }
}
