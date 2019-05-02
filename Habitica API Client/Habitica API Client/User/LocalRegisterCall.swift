//
//  LocalRegisterCall.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

public class LocalRegisterCall: ResponseObjectCall<LoginResponseProtocol, APILoginResponse> {
    public init(username: String, password: String, confirmPassword: String, email: String, stubHolder: StubHolderProtocol? = StubHolder(responseCode: 200, stubFileName: "user.json")) {
        let json = try? JSONSerialization.data(withJSONObject: ["username": username, "password": password, "confirmPassword": confirmPassword, "email": email], options: .prettyPrinted)
        super.init(httpMethod: .POST, endpoint: "user/auth/local/register", postData: json, stubHolder: stubHolder)
        needsAuthentication = false
    }
}
