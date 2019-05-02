//
//  LocalLoginCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class LocalLoginCall: ResponseObjectCall<LoginResponseProtocol, APILoginResponse> {
    public init(username: String, password: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let json = try? JSONSerialization.data(withJSONObject: ["username": username, "password": password], options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "user/auth/local/login", postData: json, stubHolder: stubHolder)
        needsAuthentication = false
    }
}
